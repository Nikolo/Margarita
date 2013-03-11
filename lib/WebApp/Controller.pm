package WebApp::Controller;

use strict;
use base 'Mojolicious::Controller';
use MIME::Lite;
use Mojolicious::Plugin::TtRenderer::Engine;
use Template;
use utf8;
use FindBin;
use PDF::API2;
use File::Temp;
use File::Type;
use Sphinx::Search;
use File::Copy;
use LWP::UserAgent;
use MIME::Base64;
use Mail::CheckUser qw(check_email);

$Mail::CheckUser::Helo_Domain ='corp.medclub.ru';

sub isPOST { shift->tx->req->{method} eq 'POST' ? 1 : 0 }
sub isGET  { shift->tx->req->{method} eq 'GET'  ? 1 : 0 }

sub send_mail {
	my $self = shift;
	my $param = shift;
	die "Field 'To' must be set" unless $param->{to};
	die "Template name not set" unless $param->{template};
	$self->app->mtt->process( $param->{template}, {SUBJECT => 1, %{$self->stash}}, \$param->{subject} );
	$self->app->mtt->process( $param->{template}, {TEXT => 1, %{$self->stash}, h => Mojolicious::Plugin::TtRenderer::Helper->new(ctx => $self)}, \$param->{text} ) || $self->app->log->warn( $self->app->mtt->error );
	$param->{$_} = Encode::encode( 'utf8', $param->{$_} ) for qw/text/;
	$param->{subject} =~ s/[\r\n]//sg;
	$param->{$_} = Encode::encode( 'MIME-B', $param->{$_} ) for qw/subject/;
	$param->{subject} =~ s/\r?\n/\r\n/sg;
	$param->{subject} =~ s/^(?:\r?\n)+//s;
	$param->{subject} =~ s/^\s+/\t/mg;
	die "Mail template ".$param->{template}." have not subject" unless $param->{subject};
	die "Mail template ".$param->{template}." have not text" unless $param->{text};
	my $email = MIME::Lite->new(
		From     => $self->app->config->{MAIL_FROM},
		To       => $param->{to},
		CC       => $param->{cc},
		BCC      => $param->{bcc},
		Subject  => $param->{subject},
		Data     => $param->{text},
		Type     => $param->{contenttype}||'text/html',
		Encoding => 'base64',
	);
	$email->attr("content-type.charset" => 'UTF-8' );
	if( $param->{pdf_template} ){
		my $pdf = $self->make_pdf( $param->{pdf_template} );
		$email->attach(
			Type        => 'application/pdf',
			Filename    => $pdf->{name},
			Disposition => 'attachment',
			Data		=> $pdf->{file}->stringify()
		);
	}
	foreach ( @{$param->{attachments}} ){
		$email->attach(
			Type        => $_->{type},
			Path        => $_->{path},
			Filename    => $_->{filename}||$_->{path},
			Disposition => 'attachment'
		);
	}
	eval {
		$email->send( "sendmail",
			Sendmail   => "/usr/sbin/sendmail",
			SetSender  => 0,
			FromSender => $self->app->config->{MAIL_FROM}
		);
	};
	die $@ if $@ && $@ !~ /error closing \/usr\/sbin\/sendmail/;
	return undef;
}

sub redirect_back {
	my $self = shift;
	my $url = '/'.$self->stash->{controller}.'/'.$self->stash->{action}.'/'.$self->stash->{id};
	if( $self->param('back_url') && ($self->param('back_url') =~ m{https?://[^/]*analizmarket.ru} || $self->param('back_url') !~ m{://}) ){
		$url = $self->param('back_url');
	}
	elsif( $self->tx->req->headers->referrer ){
		$url = $self->tx->req->headers->referrer;
	}
	$self->app->log->info( "Redirect to back url: ".$url );
	return $self->redirect_to( $url ); 
}

sub clean_extended_editor_text {
	my $self =shift;
	my $ref = shift;
	my $before = $$ref;
	local $_ = $$ref;
	s{<(style|xml)>.*</\1>}{}sg;
	s{(?:\x1B|\x1E|\x14|\x13)}{}sg;
	s{<!--\[if gte mso \d+\]>[\r\n\s]*<!\[endif\]-->}{}sg;
	s{^\s+$}{}mg;
	s{^\s+}{}mg;
	s{\n+}{\n}sg;
	s{(?:style|class)="[^"]*"\s*}{}sg;
	s{\n*<(p|span)\s*>([\s\n]*(&nbsp;)*[\s\n]*)</\1>}{}sg;
	s{\n*<(p|strong|span|h1|div)\s*>([\s\n]*(&nbsp;)*[\s\n]*)</\1>}{$2}esg;
	s{</?(span|h1|div)\s*>}{}sg;
	s{<br\s*/>\s*(</p>)}{$1}esg;
	s{\x1B|\x1E}{-}sg;
	s{([:;])\s*(-|(?:\d+(?:\.|\))))}{$1."<br>".$2}esg;
	s{([^\s>])<br\s*/>([^\s<])}{$1."<br /><br />".$2}esg;
	s{(?:<br\s*/>)*(&bull;)}{"<br />".$1}esg;
	$self->session( 'WARNING', 'Системой были внесены изменения в текст проверьте, что он правильно отображается!' ) if $_ ne $before;
	$$ref = $_;
	return;
}

sub frequency_collect {
	my $self = shift;
	my $index = shift;
	my $param = shift;
	my @content = (); 
	my $freq_dict;
	my @wall_of_text =  qw/text prepared indication excess decrease referential synonyms finds_out research_object research_method not_informative qual_quant/;
	my $published_data;
	if ( $index eq 'confirmed' ) {
		$published_data = $self->app->schema->resultset('CollectionsDesc')->find({ collection_id => $param });
		$freq_dict = $FindBin::Bin.'/../../bin/freq_dict.txt'; 
	} elsif ( $index eq 'diagnostics') {
		$published_data = $self->app->schema->resultset('Diagnostic')->find({ id => $param });
		$freq_dict = $FindBin::Bin.'/../../bin/freq_dict_diagnostics.txt'; 
		@wall_of_text =  qw/name full_name prepared contraindication duration process result indication criteria save_info/;
	} else {
		$published_data = $self->app->schema->resultset('Collection')->find({ id => $param });
		$freq_dict = $FindBin::Bin.'/../../bin/freq_dict.txt'; 
	}
	open (FREQ_DICT, '<'.$freq_dict);
	while( <FREQ_DICT> ){ chomp $_; push @content, $_ }
	close (FREQ_DICT);
	my $str = join " ", map { $published_data->$_ } @wall_of_text;
	$str =~ s/<[^>]+>/ /sg;
	$str =~ s/&[^\s;](?:\s|;|$)/ /sg;
	$str =~ s/[\*\+\!\?]\"|\/|\\|\%|\&|\,|\d+|\.|\;|\:|\'|>|<|\(|\)|-|=/ /g;
	my $keywrd = {};
	foreach my $word (grep { length($_) > 4 } split(/\s+/,$str)){
		next if grep { $word eq $_ } @content;
		$keywrd->{$word}++;
	}
	return my $freq = join " ", grep {$_} (sort {$keywrd->{$b} <=> $keywrd->{$a} } keys %$keywrd)[0..7];
}

sub upload_file {
	my $self = shift;
	my $type = shift;
	my $name = shift;
	my $keyword = shift;
	my $path = shift;
	my (undef,undef,undef,undef,$pre_path) = split ('/',$path);
	copy("$path","$FindBin::Bin/../public/$type/$pre_path$name") or die "Copy failed: $!";
	my $p_save = $pre_path.$name;
	my $ft = File::Type->checktype_filename("$FindBin::Bin/../public/$type/$p_save");
	$ft =~ s/\/\w+//; 
	my %param  = ( 
			name => $p_save,
			owner_id => $self->stash->{user}->id,
			date => DateTime->now->set_time_zone( 'Europe/Moscow' ), 
			file_media_type => $ft,
			obj_id => $self->stash->{id},
			obj_name => $type,
			tmpl_keyword => $keyword);
	if ( ($type eq 'networks') && ($keyword eq 'logo') ) {
		$self->app->schema->resultset('Upload')->search({ obj_id => $self->stash->{id}, obj_name => $type, tmpl_keyword => $keyword })->delete;
	}
	$self->app->schema->resultset('Upload')->create({%param});
	$self->session('MESSAGE' => 'Файл загружен успешно<br>');
}

sub add_user {
	my $self = shift;
	my $email = shift;
        my $ret = {};
        if( $self->app->schema->resultset( 'User' )->search({ 'email' => lc($email)})->all()){
		$ret = { status => 'Error', mtype => 'ERROR', text => 'Пользователь существует. Регистрация невозможна.' };
        }
        elsif( !Mail::CheckUser::check_email($email) ){
        	$ret = { status => 'Invalid', mtype => 'ERROR', text => 'Введён неправильный адрес.' };
        }
        else{
        	my $new_user = $self->app->schema->resultset( 'User' )->create({email => lc($email), activationid => Data::UUID->new->create_str()});
                $new_user->set_grps( {'grp.name' => 'users'} );
                $self->stash->{activationid} = $new_user->activationid;
                $self->stash->{email} = $new_user->email;
                $self->send_mail({to => $email, template => 'mail/register.html.tt'});
                $ret = { status => 'Ok', mtype => 'MESSAGE', text => 'User added', new_user => $new_user};
	}
	return $ret;
}

sub user_auth {
	my $self = shift;
	my $email = shift;
	my $password = shift;
    my $usr = $self->app->schema->resultset( 'User' )->search({ 'email' => lc($email), 'password' => \[ ' = crypt( ?, "password" )', [password => $password]] })->first;
	return 1 unless $usr;
    $self->session('user_id', $usr->id);
	$self->stash( 'user', $usr );
	return 0;
}

sub send_order_by_email {
	my $self = shift;
	my $order = shift;
    if( $order && $order->user_id == $self->stash->{user}->id ){
		$self->stash('order', $order);
		foreach( qw/collection diagnostic/){
			next if( ($_ eq 'collection' and !$order->sum_collection) || ($_ eq 'diagnostic' && !$order->sum_diagnostic_min));
			$self->stash('WHERE', $_);
			$self->send_mail({
				to           => $self->stash->{user}->email, 
				template     => 'mail/order.html.tt',
				pdf_template => 'pdf/order.html.tt',
			});
		}
		return 1;
	}
	return 0;
}

sub make_pdf {
	my $self = shift;
	my $template = shift;
	my $ret = {};
	$ret->{file} = PDF::API2->new();
	$ret->{path} = $FindBin::Bin.'/..';
	$ret->{fetcher} = sub {
		my $url = shift;
		my $temp_file = File::Temp->new;
		my $lwp = LWP::UserAgent->new();
$self->app->log->info( $url );
		my $response = $lwp->get( $url );
    		$temp_file->print( $response->content );
    		$temp_file->close;
		return $temp_file;#->filename;
	};
	$self->stash( 'PDF', $ret );
	my $tmp_out = '';
	my $tmpl = $self->app->mtt;
	$tmpl->process( $template, { %{$self->stash}, h => Mojolicious::Plugin::TtRenderer::Helper->new(ctx => $self)}, \$tmp_out ) || die $tmpl->error;
	return $ret;
}

sub _get_units_for_cart {
	my $self = shift;
	my $obj_name = shift;
	my $unit_id = shift;
	die "Obj name must be only collection or diagnostic" unless $obj_name =~ /^(?:collection|diagnostic)$/;
	my $field_name = $obj_name."_id";
	my $table_name = $obj_name."s";
	my $table_price = $obj_name."_price";
	my $table_micropanel = $obj_name."_micropanel";
	my $device_field = $obj_name eq 'diagnostic' ? "p.device_id as device" : "0 as device";
	my $all_prices = $self->app->schema->storage->dbh->selectall_arrayref("
		(
			SELECT cm.link_to as cid, b.$field_name as bcid, p.unit_id as uid, p.price as pr, p.currency as curr, $device_field from basket b
			LEFT JOIN $table_micropanel cm on cm.link_from = b.$field_name
			INNER JOIN $table_name c on c.id = cm.link_to or c.link_id = cm.link_to
			INNER JOIN $table_price p ON p.$field_name = c.id
			INNER JOIN units u ON u.id = p.unit_id
			WHERE b.session_id = ? and b.$field_name is not null and ST_DWithin(u.coords,ST_GeographyFromText(?),?) ".( $unit_id ? "and p.unit_id = $unit_id" : "")."
		) union (
			SELECT b.$field_name as cid, b.$field_name as bcid, p.unit_id as uid, p.price as pr, p.currency as curr, $device_field from basket b
			INNER JOIN $table_name c on c.id = b.$field_name or c.link_id = b.$field_name
			INNER JOIN $table_price p ON p.$field_name = c.id
			INNER JOIN units u ON u.id = p.unit_id
			WHERE b.session_id = ? and b.$field_name is not null and ST_DWithin(u.coords,ST_GeographyFromText(?),?) ".( $unit_id ? "and p.unit_id = $unit_id" : "")."
		)
	", {}, $self->session->{id}, "SRID=4326;POINT(".$self->session->{position}.")", $self->app->config->{distance}, $self->session->{id}, "SRID=4326;POINT(".$self->session->{position}.")", $self->app->config->{distance});
	my $units = {};
	my $unit_dev = [];
	foreach my $pr ( @$all_prices ){
		if( $pr->[0] == $pr->[1] ){
			$units->{$pr->[2]}->{sum} -= $units->{$pr->[2]}->{coll}->{$pr->[1]}->{sum} if !$pr->[5] || grep {$pr->[1]." ".$pr->[5] eq $_} @$unit_dev;
			$units->{$pr->[2]}->{coll}->{$pr->[1]} = {sum => $pr->[3], curr => $pr->[4]};
			$units->{$pr->[2]}->{sum} += $pr->[3];# if !$pr->[5] || !grep {$pr->[1]." ".$pr->[5] eq $_} @$unit_dev;
			$units->{$pr->[2]}->{curr} ||= $pr->[4];
			push @$unit_dev, $pr->[1]." ".$pr->[5] if $pr->[5];
		}
		else {
			if( !exists $units->{$pr->[2]}->{coll}->{$pr->[1]} ){
				$units->{$pr->[2]}->{coll}->{$pr->[1]} ||= {sum => $pr->[3], curr => $pr->[4]};
				$units->{$pr->[2]}->{sum} += $pr->[3] if !$pr->[5] || !grep {$pr->[1]." ".$pr->[5] eq $_} @$unit_dev;
				$units->{$pr->[2]}->{curr} ||= $pr->[4];
				push @$unit_dev, $pr->[1]." ".$pr->[5] if $pr->[5];
			}
		}
	}
	my $bask_elems = [$self->app->schema->resultset('Basket')->search({ session_id => $self->session->{id}, $field_name => {"is not" => undef}  },{select => [$field_name], as => ["obj_id"], group_by => $field_name})->all()];
	if( $unit_id ){
		my $ret = $units->{(keys %$units)[0]};
		foreach my $be ( @$bask_elems ){
			if( grep {$_ == $be->get_column( "obj_id" )} keys %{$ret->{coll}} ){
				$ret->{coll}->{$be->get_column( "obj_id" )}->{name} = $obj_name eq 'collection'
					? $self->get_collection_for_unit($unit_id, $be->get_column( "obj_id" ))->real_name
					: $self->get_diagnostic_for_unit($unit_id, $be->get_column( "obj_id" ))->name; 
			}
			else {
				$ret->{coll}->{$be->get_column( "obj_id" )} = {
					sum => 0, 
					name => $obj_name eq 'collection'
						? $self->app->schema->resultset(ucfirst($obj_name))->find({id => $be->get_column( "obj_id" )})->real_name
						: $self->app->schema->resultset(ucfirst($obj_name))->find({id => $be->get_column( "obj_id" )})->name,
				};
			}
		}
		return $ret;
	}
	else {
		return {map {$_ => { sum => $units->{$_}->{sum}, currency => $units->{$_}->{curr}, colls => $units->{$_}->{coll}}} grep {scalar keys %{$units->{$_}->{coll}} == @$bask_elems} keys %$units};
	}
}

sub delete_unit {
	my $self = shift;
	my $unit = shift;
	$unit = $self->app->schema->resultset('Unit')->find({id => $unit}) unless ref $unit;
	return undef if !$unit || $unit->status eq 'deleted';
	$unit->collection_prices->delete();
	$unit->diagnostic_prices->delete();
	$unit->device_to_units->delete();
	$unit->inspect_materials_prices->delete();
	$unit->research_to_units->delete();
	$unit->work_times->delete();
	if( $unit->orders_unit_diagnostics->count || $unit->ratings->count || $unit->rating_comments->count || $unit->orders_units->count ){
		$unit->update({status => 'deleted'});
	}
	else {
		$unit->delete();
	}
	return 1;
}

sub _save_search_result {
	my $self = shift;
	my $res = shift;
	my $term = shift;
	my $type = shift;
	if ( $term && ( length($term) > 2 ) ) {
		my $id = $self->app->schema->resultset('SQuery')->create({ 
				query => $term, 
				date  => DateTime->now->set_time_zone( 'Europe/Moscow' ), 
				status => 'new',
				type => $type
			});
		my $q_id = $id->id;
		my $res_c = scalar @$res;
		if ( $res_c ) {
			foreach (@$res) {
					$self->app->schema->resultset('SResult')->create({
					query_id => $q_id,
					$type."_id" => $_->{id}
				});
			}
		}
	}
}

sub searchd {
	my $self = shift;
	my $params = shift;
	my $grp = shift;
	my $tick = []; shift;
	$self->app->log->info("Search: $params->{input}") if $params->{input};
	if ( $params->{type} eq 'collection' ) { 
		$params->{index} = 'analiz', $params->{c_diag_id} = 'collection_id', $params->{tbl} = 'Collection', $params->{index_suggest} = 'collection_suggest', $params->{tbl_suggest} = 'CollectionSuggest', $params->{group_id} = 'collection_group_id', $params->{search_in_grp} = $grp
	} elsif ( $params->{type} eq 'diagnostic' ) {
		$params->{index} = 'diagnostic', $params->{c_diag_id} = 'diagnostic_id', $params->{tbl} = 'Diagnostic', $params->{index_suggest} = 'diagnostic_suggest', $params->{tbl_suggest} = 'DiagnosticSuggest', $params->{group_id} = 'diagnostic_group_id', $params->{search_in_grp} = $grp
	} elsif ( $params->{type} eq 'rating' ) {
		$params->{index} = 'units', $params->{tbl} = 'Unit', $params->{index_suggest} = 'unit_suggest', $params->{tbl_suggest} = 'UnitSuggest', $params->{set_limit} = 50
	} 
	elsif ( $params->{type} eq 'c_linker' ) {
		$params->{index}          = 'analiz';
		$params->{c_diag_id}      = 'collection_id';
		$params->{tbl}            = 'Collection';
		$params->{index_suggest}  = 'collection_suggest';
		$params->{tbl_suggest}    = 'CollectionSuggest';
		$params->{sph_match_mode} = SPH_MATCH_ANY;
		$params->{set_limit}      = 12;
		$params->{group_id}       = 'collection_group_id';
	}
	elsif ( $params->{type} eq 'd_linker' ) {
		$params->{index}          = 'diagnostic';
		$params->{c_diag_id}      = 'diagnostic_id';
		$params->{tbl}            = 'Diagnostic';
		$params->{index_suggest}  = 'diagnostic_suggest';
		$params->{tbl_suggest}    = 'DiagnosticSuggest';
		$params->{sph_match_mode} = SPH_MATCH_ANY;
		$params->{group_id}       = 'diagnostic_group_id';
	}
	
	my $page = $self->param('page') || 0;
	if ( $params->{input}) {
		$self->stash->{term} = $params->{input};
		$params->{input} =~ s/^\s*$//;
		$params->{input} =~ s/\s+\-\w+\s+/ /g;
		$params->{input} =~ s/\w\(-\d+.*\)\w/ /g;
		$params->{input} =~ s/[\)\(\"\'\/\\+\,]/ /g;
		$params->{input} =~ s/\s+\-+\s+/ /g;
		$params->{input} =~ s/\s+\.+\s+/ /g;
		$params->{input} =~ s/\s+/ /g;
		my $results = $self->_return_search_results($params->{sph_match_mode},$params->{set_limit} || 100,$params->{input},$params->{index});

		if ( $results->{total_found} == 0 ) {
			my @qchar_ = ();
			my %_alfa = ( "а" => "f", "б" => "\,", "в" => "d", "г" => "u", "д" => "l", "е" => "t", "ж" => ";", "з" => "p", "и" => "b", "й" => "q", "к" => "r", "л" => "k", "м" => "v", "н" => "y", "о" => "j", "п" => "g", "р" => "h", "с" => "c", "т" => "n", "у" => "e", "ф" => "a", "х" => "[", "ц" => "w", "ч" => "x", "ш" => "i", "щ" => "o", "ъ" => "]", "ы" => "s", "ь" => "m", "э" => "'", "ю" => ".", "я" => "z", "А" => "F", "Б" => "<", "В" => "D", "Г" => "U", "Д" => "L", "Е" => "T", "Ж" => ":", "З" => "P", "И" => "B", "Й" => "Q", "К" => "R", "Л" => "K", "М" => "V", "Н" => "Y", "О" => "J", "П" => "G", "Р" => "H", "С" => "C", "Т" => "N", "У" => "E", "Ф" => "A", "Х" => "{", "Ц" => "W", "Ч" => "X", "Ш" => "I", "Щ" => "O", "Ъ" => "}", "Ы" => "S", "Ь" => "M", "Э" => "\"", "Ю" => ">", "Я" => "Z", " " => " ", "|" => "|", "^" => "^", "\$" => "\$"
			);                
			foreach my $qch ( split '', $params->{input} ) {
				foreach ( keys %_alfa ) { if ( $qch eq $_alfa{$_} ) { push (@qchar_, $_); last } } 
			}
			my $split_symbol = join('', @qchar_);

			$results = $self->_return_search_results($params->{sph_match_mode},$params->{set_limit} || 200,$split_symbol,$params->{index});
		}

		if ( $results->{total_found} == 0 ) {
			my $split_w;
			my $tr; my $trigr;
			my $q_query;
			my @arr_inpt = split /\s+/, $params->{input};
			foreach my $wrd (@arr_inpt) {
				if (length $wrd >= 3 ) {
					$results = $self->_return_search_results($params->{sph_match_mode},1,$wrd,$params->{index});
					if ($results->{total_found} == 0) {
						my $len = length($wrd);
						my $input_q = "__".$wrd."__";
						my @sort_by_relevance;
						@{$split_w} = split '', $input_q;
						for (my $j = 0; $j < scalar @{$split_w} -2;$j++) {
							for ( my $i = 0; $i < 3; $i++ ) { $trigr .= ${$split_w}[$i+$j]; };	
							($j > 0) ? ($tr .= " ".$trigr) : ($tr .= $trigr);
							$trigr = undef; 
						}
						if ($len > 8 ) {
							$tr = "\"".$tr."\""."\/5";
							$len += 4;
						} elsif ($len > 6) {
							$tr = "\"".$tr."\""."\/4";
						} else {
							$tr = "\"".$tr."\""."\/2";
						}
						$results = Sphinx::Search->new->SetServer('localhost' , 3312)
													  ->SetFilterRange( "len", $len-7, $len+7 )
										  			  ->SetMatchMode( $params->{sph_match_mode} || $self->app->config->{sphinx}->{match_mode} )
													  #->SetRankingMode(SPH_RANK_EXPR, "sum(lcs*user_weight)*1000+bm25")
													  ->SetRankingMode(SPH_RANK_WORDCOUNT)
													  ->SetSelect( "*,2+2-abs(len-$len) AS myrank" )
													  ->SetSortMode ( SPH_SORT_EXTENDED, "myrank DESC, freq DESC" )
										  			  ->SetLimits(0,$params->{set_limit} || 200)
													  ->Query($tr,$params->{index_suggest});
						@sort_by_relevance = sort { $$b{'weight'} <=> $$a{'weight'} } @{$results->{matches}};
						my $more_relevance = $sort_by_relevance[0];
						my $keyword = $self->app->schema->resultset($params->{tbl_suggest})->find($more_relevance->{doc});
						$wrd = $keyword->get_column('keyword') if $keyword;
						
					}
				}
				$tr = undef;
				$q_query .= $wrd . " ";
			}
			$q_query =~ s/\s+?$//;
			$results = $self->_return_search_results($params->{sph_match_mode},$params->{set_limit} || 50,$q_query,$params->{index});
		}
		
		my $q = $self->session('position');
		$self->app->log->info("Search: $params->{input}, Position: $q");

		if (($params->{type} eq 'collection') || ($params->{type} eq 'diagnostic') || ($params->{type} eq 'c_linker') || ($params->{type} eq 'd_linker')) {
			my @Sugg = (map {my $res = $self->app->schema->resultset($params->{tbl})->search( { id => $_->{doc}, status => 'active' })->first; $res ? {id=>$res->id, group_id => '' || ( $params->{group_id} eq 'collection_group_id' ? $res->collection_group_id : $res->diagnostic_group_id ), value => $params->{type} eq 'collection' ? $res->real_name : $res->name} : () } @{$results->{matches}});
			if ($params->{json}) {
				foreach ( @Sugg ) {
					if ( $params->{search_in_grp} ) {
						next unless ( $_->{group_id} eq $params->{search_in_grp} )
					}
					$self->app->schema->resultset('Basket')->find( { $params->{c_diag_id} => $_->{id}, session_id => $self->session->{id}} ) ?  ( push(@{$tick}, { id => $_->{id}, group_id => $_->{group_id}, inbasket => 1, value => $_->{value}, panels => [] }) ) : ( push (@{$tick}, { id => $_->{id}, inbasket => 0, value => $_->{value}, panel => [] }) )
				}
				if ( $page != 0 ) {
					( ($page+1)*12 <= scalar @{$tick} ) ? ( @{$tick} = @{$tick}[$page*12..($page+1)*12-1] ) : ( @{$tick} = @{$tick}[$page*12..scalar @{$tick}-1] );
				}
			} elsif ( $params->{type} eq 'c_linker' ) {
				my $lim = 11;
				my $coll_cnt =  scalar @Sugg;
				my @sug;
				if ( $coll_cnt > $lim ) {
					$self->stash->{coll_cnt} = $lim;
					@sug = splice(@Sugg,0,$lim)
				} else { 
					$self->stash->{coll_cnt} = $coll_cnt;
					@sug = splice(@Sugg,0,$coll_cnt)
				}
				push @{$tick}, { id => $_->{id}, $params->{type} eq 'collection' ? (real_name => $_->{value}) : (name => $_->{value}), panel => [] } foreach @sug;
			} else {
				my $pager;
				my $coll_cnt =  scalar @Sugg;
				if ( $coll_cnt > 11 ) { $pager = 11 } else { $pager = $coll_cnt - 1 };
				if ( $pager != 0 ) { @Sugg = @Sugg[0..$pager] };
				$self->stash->{coll_cnt} = $coll_cnt;
				foreach ( @Sugg ) {
					if ( $params->{search_in_grp} ) {
						next unless ( $_->{group_id} eq $params->{search_in_grp} )
					}
					$self->app->schema->resultset('Basket')->find( { $params->{c_diag_id} => $_->{id}, session_id => $self->session->{id}} ) ?  ( push(@{$tick}, { id => $_->{id}, group_id => $_->{group_id}, inbasket => 1, $params->{type} eq 'collection' ? (real_name => $_->{value}) : (name => $_->{value}), panels => [] }) ) : ( push (@{$tick}, { id => $_->{id}, group_id => $_->{group_id}, inbasket => 0, $params->{type} eq 'collection' ? (real_name => $_->{value}) : (name => $_->{value}), panel => [] }) )
				}
			}
			my $ptc = [];
			foreach my $cc (@{$tick}) {
				foreach ($self->app->schema->resultset('PanelToCollection')->search( { 'me.collection_id' => $cc->{id}, 'panel.flag' => 0 }, { join => 'panel', select => [ "panel.id", "panel.name"], as => ["id", "name"] } )->all) {
					push (@{$ptc},{ id => $_->get_column('id'), name => $_->get_column('name') });
				}
				$cc->{panel} = $ptc;
				$ptc = [];
			}
		} elsif ($params->{type} eq 'rating') {
			my $res; my $net; my $sth;
			my $sugg = [];
			my $dist_sugg = [];
			my $cnt_sugg = 5;
			foreach ( @{$results->{matches}} ) {
				$res = $self->app->schema->resultset($params->{tbl})->find($_->{doc}); 
				$net = $self->app->schema->resultset('Network')->search(
					{ 'units.id' => $_->{doc} },
					{
						join => 'units',
						select => ['me.name'],
						as => ['name'],
					})->first;
				$sth = $self->app->schema->storage->dbh->selectall_arrayref("SELECT ST_DISTANCE(ST_GeographyFromText(?), u.coords) AS dist FROM units u WHERE id = ? and status != 'deleted'",{Slice => {}},'SRID=4326;POINT('.$self->stash->{position_lon}.' '.$self->stash->{position_lat}.')', $_->{doc})->[0]->{dist};
				push (@{$sugg}, { id => $_->{doc}, value => $res->name, network => $net->name, dist => $sth });
			}
			@{$dist_sugg} =  sort { $a->{dist} <=> $b->{dist} } @{$sugg};
			my $arr = scalar @{$dist_sugg};
			if ( $arr >= $cnt_sugg ) { 
				@{$tick} = @{$dist_sugg}[0..$cnt_sugg-1]
			} elsif ($arr > 0 && $arr < $cnt_sugg) {
				@{$tick} = @{$dist_sugg}[0..$arr]
			} else {
				$tick = []
			}
		}
	}
	$self->app->log->info("Search result query: ".$self->stash->{term}) if $self->stash->{term};
	return $tick;
}

sub _return_search_results {
	my $self = shift;
	return Sphinx::Search->new->SetServer('localhost' , 3312)
				 ->SetMatchMode( shift || $self->app->config->{sphinx}->{match_mode} )
				 ->SetRankingMode( $self->app->config->{sphinx}->{rank_mode} )
				 ->SetSortMode ( $self->app->config->{sphinx}->{sort_mode} )
				 ->SetLimits(0, shift)
				 ->Query(shift,shift);
}

1;
