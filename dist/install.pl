#!/usr/bin/perl

use strict;
use FindBin;
use Config::JSON;
use File::Temp;

sub get_param {
	my $name = shift;
	my $param = shift;
	my $default = $param->{default};
	my $possible = $param->{possible};
	my $required = $param->{required};
	my $check_perm = $param->{check_perm};
	my $check_file = $param->{check_file};
	my $pos_str = "(".join("|", @$possible).")" if $possible;
	my $ok = 0;
	my $ret;
	while( !$ok ){
		print "$name$pos_str [$default]: ";
		$ret = <STDIN>;
		chomp( $ret );
		$ret ||= $default;
		if( !$ret && $required ){
			print "$name is required".$/;
		}
		elsif( $possible && !grep {$ret eq $_} @$possible ){
			print "Value $ret for $name is impossible".$/;
		}
		elsif( $check_file && !-r $ret){
			print "File $ret not found".$/;
		}
		elsif( $check_perm && !-w $ret){
			print "Dir $ret not writable".$/;
		}
		else {
			$ok = 1;
		}
	}	
	return $ret;
}

sub info { print join "",$/x2,$_[0],$/ }

info( "Database connection param for margarita:" );
my $type_db = get_param( "What database have you", { default => "psql", possible => [qw/psql mysql/]} );
my $dbhost = get_param( "DB host", { default => 'localhost' });
my $dbname = get_param( "DB name", { default => 'margarita' });
my $dbuser = get_param( "DB user", { default => 'margarita' });
my $dbpass = get_param( "DB password", { default => '', required => 1} );

info( "Memcache connection param for margarita:" );
my $memcache = {};
if( get_param( "Use mamcache", { possible => [qw/yes no/], default => 'no'} ) eq 'yes'){
	$memcache->{host} = get_param( "Memcache host", { default => '127.0.0.1' });
	$memcache->{port} = get_param( "Memcache post", { default => '30000' });
	$memcache->{val_max_size} = get_param( "Memcache max value size", { default => '1024' });
}

info( "Database param for install" );
my $have_admin_pass = get_param( "Do you have admin password to database?", { default => 'yes', possible => [qw/yes no/]} );
my $db_root = get_param(  "Admin username for db", { default => "", required => 1} ) if $have_admin_pass eq 'yes';
my $pg_template = get_param( "Template for createdb", { default => "template0"} ) if $type_db eq 'psql';

info( "Margarita server param:" );
my $daemon_user = get_param( "Enter username for start daemon", { default => 'www-data'} );
my $listen_h = get_param( "Listen host", { default => '127.0.0.1'} );
my $listen_p = get_param( "Listen port", { default => '3000'} );
my $email_from = get_param( "Email from", { default => '', required => 1} );
my $app_mode = get_param( "App mode", { default => 'production', possible => [qw/production development/]} );

info( "Parametrs for wrapper and init script" );
my $path_prog = $FindBin::Bin;
$path_prog =~ s{/[^/]+$}{};
$path_prog .= '/script';
$path_prog = get_param( "Path to prog", { default => $path_prog, check_file => 1} );
my $hypno_path = get_param( "Path to hypnotoad", { default => '/usr/local/bin/hypnotoad', check_file => 1} );
my $path_to_wrapper = get_param( "Path to wrapper", { default => '/usr/local/sbin/', check_perm => 1} );
my $path_to_init = get_param( "Path to init script", { default => '/etc/init.d/', check_perm => 1} );
my $admin_email = get_param( "Admin email", { default => '', required => 1} );

info( "Parametrs for nginx config" );
my $path_to_nginx_config_avail = get_param( "Path to nginx config available sites", {default => '/etc/nginx/sites-available', check_perm => 1} );
my $path_to_nginx_config_enabled = get_param( "Path to nginx config enabled sites", {default => '/etc/nginx/sites-enabled', check_perm => 1} );
my $hostname = get_param( "Web server hostname", {required => 1} );
my $listen_ip = get_param( "Ip which nginx listen", {} );
my $path_to_nginx_log = get_param( "Path no nginx log", {default => '/var/log/nginx/'} );
my $upload_module = get_param( "Use upload module", {default => 'yes'} );

my $cfg = Config::JSON->create( '../margarita.cfg' );
$cfg->set( "hypnotoad", {"listen" => [ "http://$listen_h:$listen_p" ]} );
$cfg->set( "app_mode", $app_mode);
$cfg->set( "db", { "name" => $dbname, "host" => $dbhost, "user" => $dbuser, "pass" => $dbpass });
$cfg->set( "MAIL_FROM", $email_from );
$cfg->set( "memcache", $memcache ) if keys %$memcache; 

if( $have_admin_pass ){
	if( $type_db eq 'psql' ){
		info( "Create user in DB".$/."Enter database admin password" );
		system( "psql -h $dbhost -U $db_root template1 -c \"CREATE ROLE $dbuser PASSWORD '$dbpass' NOSUPERUSER NOCREATEDB NOCREATEROLE INHERIT LOGIN;\"" );
		info( "Create base in DB".$/."Enter database admin password" );
		system( "createdb -e -E UTF8 -l ru_RU.UTF8 -T $pg_template -O $dbuser -h $dbhost -U $db_root $dbname margaritaCMS" );
		info( "Create extensions in database".$/."Enter database admin password" );
		system( "cat margarita_admin_setup.sql | psql -h $dbhost -U $db_root $dbname" );
	}
	elsif( $type_db eq 'mysql' ){
		info( "Create base in DB".$/."Enter database admin password" );
		system( "mysqladmin -u $dbuser -p --default-character-set=utf8 -h $dbhost create $dbname" );
		info( "Create user in DB".$/."Enter database admin password" );
		system( "mysql -u $db_root -p -h $dbhost -e \"GRANT ALL ON ".$dbname.".* TO '".$dbuser."'\@'localhost' IDENTIFIED BY '".$dbpass."'\"" );
	}
	else {
		die "DB type $type_db not supported".$/;
	}
}
else {
	info( "View doc for create user and database. After create press Enter." );
	my $ret = <STDIN>;
}
system( "cp margarita_setup.sql margarita_setup_tmp.sql" );
my $SQL;
open $SQL, ">> margarita_setup_tmp.sql";
printf $SQL <<EOF_SQL;
INSERT INTO users (id, email, activationid) VALUES (1, '$admin_email', 'firstlogin'); 
INSERT INTO grps (id, name, description) VALUES (0, 'unauthorized', 'Неавторизованные пользователи'); 
INSERT INTO grps (id, name, description) VALUES (1, 'admin', 'Администраторы'); 
INSERT INTO pages (id, controller, action) VALUES (0, 'auth', 'activationlink'); 
INSERT INTO pages (id, controller, action) VALUES (1, 'page', 'edit'); 
INSERT INTO pages (id, controller, action) VALUES (2, 'page', 'upload'); 
INSERT INTO pages (id, controller, action) VALUES (3, 'auth', 'login'); 
INSERT INTO pages (id, controller, action) VALUES (4, 'auth', 'logout'); 
INSERT INTO pages (id, controller, action) VALUES (5, 'user', 'welcome'); 
INSERT INTO pages (id, controller, action) VALUES (6, 'page', 'list'); 
INSERT INTO pages (id, controller, action) VALUES (7, 'admin', 'welcome'); 
INSERT INTO pages (id, controller, action) VALUES (8, 'page', 'menu_delete'); 
INSERT INTO acls (grp_id, page_id) VALUES (1,6); 
INSERT INTO acls (grp_id, page_id) VALUES (1,1); 
INSERT INTO acls (grp_id, page_id) VALUES (1,2); 
INSERT INTO acls (grp_id, page_id) VALUES (0,3); 
INSERT INTO acls (grp_id, page_id) VALUES (0,4); 
INSERT INTO acls (grp_id, page_id) VALUES (0,0); 
INSERT INTO acls (grp_id, page_id) VALUES (1,5); 
INSERT INTO acls (grp_id, page_id) VALUES (1,8); 
INSERT INTO roles (user_id, grp_id) VALUES (1,1);
INSERT INTO menu_types (id, name) VALUES (0, 'admin');
INSERT INTO menu_types (id, name) VALUES (1, 'top');
INSERT INTO menu (menu_type_id,page_id,name,position) VALUES (0,6,'Список страниц',1000);
INSERT INTO menu (menu_type_id,page_id,name, position) VALUES (1,7,'Админка',1000);
EOF_SQL

info( "Create tables in db".$/."WARNING!!! No admin password, new user password" );
system( "cat margarita_setup_tmp.sql | psql -h $dbhost -U $dbuser $dbname" );
unlink( "margarita_setup_tmp.sql" );
info( "Generatin DBIx::Class schema" );
system( "dbicdump -o dump_directory=../lib -o components='[\"InflateColumn::DateTime\"]' Schema 'dbi:Pg:dbname=$dbname;host=$dbhost' $dbuser $dbpass 2>&1" );
my $cfg_file_name = $hostname;
$cfg_file_name =~ s/\./_/g;
info( "Create init script" );
my $INIT;
open $INIT, "> $path_to_init/$cfg_file_name";

printf $INIT <<EOF_INIT;
#!/bin/sh
### BEGIN INIT INFO
# Provides:          margaritaCMS
# Required-Start:    \$local_fs \$remote_fs \$network \$syslog \$named
open $INIT, "> $path_to_init/margarita";

printf $INIT <<EOF_INIT;
#!/bin/sh
### BEGIN INIT INFO
# Provides:          margaritaCMS
# Required-Start:    \$local_fs \$remote_fs \$network \$syslog \$named
# Required-Stop:     \$local_fs \$remote_fs \$network \$syslog \$named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     true
# Short-Description: Start/stop margarita web server
### END INIT INFO

PROG_PATH="$path_prog";
NAME=margarita
DAEMON="\$PROG_PATH/\$NAME"
DESC="Margarita CMS"
PIDFILE="\$PROG_PATH/hypnotoad.pid"

test -f \$DAEMON || exit 0

case "\$1" in
  start)
	echo "Starting \$DESC: \$NAME"
	[ -f $path_to_wrapper/margarita_wrapper.sh ] && $path_to_wrapper/margarita_wrapper.sh & 
	;;
  stop)
	echo "Stopping \$DESC: \$NAME"
	kill `ps ax | grep margarita_wrapper | grep -v grep | awk '{print \$1}'` >> /dev/null 2>&1
	if [ -f "\$PIDFILE" ]; then
		PID=`cat \$PIDFILE`;
		kill \$PID >> /dev/null 2>&1
	else
		echo "No pid file!"
	fi;
	;;
  restart|force-reload)
	\$0 stop
	\$0 start
	;;
  *)
	N=/etc/init.d/\$NAME
	echo "Usage: \$N {start|stop|restart}" >&2
	exit 1
	;;
esac

exit 0
EOF_INIT

close( $INIT );
system( "chmod a+x $path_to_init/$cfg_file_name" );

info( "Create wrapper" );
my $WRAPPER;
open $WRAPPER, "> $path_to_wrapper/${cfg_file_name}_wrapper.sh";

printf $WRAPPER <<EOF_WRAPPER;
#!/bin/bash
#

USER=$daemon_user;
PATH_PROG=$path_prog;
HYPNO=$hypno_path;
WEB_APP="\$PATH_PROG/margarita";
PID="\$PATH_PROG/hypnotoad.pid";

while :;
do
	if [ -f "\$PID" ]; then
		pid=`cat \$PID`
		if ! ps -p "\$pid" >/dev/null; then
			echo "Stale pidfile removed";
			rm "\$PID";
		fi
	fi
    [ ! -f \$PID ] && /bin/su - \$USER -c "cd \$PATH_PROG; \$HYPNO \$WEB_APP > /dev/null 2>&1" && echo "margaritaCMS proccess restarted" | /usr/bin/mail -s "margarita wrapper" $admin_email
    /bin/sleep 0.5
done
EOF_WRAPPER

close( $WRAPPER );
system( "chmod a+x $path_to_wrapper/${cfg_file_name}_wrapper.sh" );

info( "Create nginx config" );
my $NGINX;
open $NGINX, "> $path_to_nginx_config_avail/$cfg_file_name";
my $redir_host = $hostname;
if( $redir_host =~ /^www/ ){
	$redir_host =~ s/^www.//;
}
else {
	$redir_host = "www.$redir_host";
}
$listen_ip .= ':' if $listen_ip;
printf $NGINX <<EOF_NGINX;
server {
	listen ${listen_ip}80;
	server_name $redir_host;
	rewrite ^ http://$hostname\$request_uri? permanent;
}

server {
	listen ${listen_ip}80;
	server_name $hostname;
	access_log  $path_to_nginx_log/margarita.access.log;
	location / {
		proxy_pass http://$listen_h:$listen_p;
		proxy_set_header Host \$host;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header X-Real-IP \$remote_addr;
	}
EOF_NGINX
if( $upload_module ){
	printf $NGINX <<EOF_NGINX;
	location ~ /(\w+)/(\w+)_upfast/(.*) {
		# Store files to this location
		upload_pass  /\$1/\$2/\$3;
		upload_store /tmp/margarita_upload/;

		client_max_body_size 10m;

		# Set specified fields in request body
		upload_set_form_field \$upload_field_name.name "\$upload_file_name";
		upload_set_form_field \$upload_field_name.content_type "\$upload_content_type";
		upload_set_form_field \$upload_field_name.path "\$upload_tmp_path";

		# Pass matching fields from client to backend
		upload_pass_form_field ".*";

		 # set permissions on the uploaded files
		upload_store_access user:rw group:rw all:r;

		upload_cleanup 400 404 499 500-505;

		error_page 405 = \@fallback;
	}
EOF_NGINX
}
my $static_path = $FindBin::Bin;
$static_path =~ s{/[^/]+$}{};
$static_path .= '/public';
for (qw/img js css bootstrap/){
	printf $NGINX <<EOF_NGINX;
	location /$_/ {
		root $static_path;
		access_log $path_to_nginx_log/margarita-static.access.log;
	}
EOF_NGINX
}

printf $NGINX <<EOF_NGINX;
	location \@fallback {
		proxy_pass http://$listen_h:$listen_p;
		proxy_set_header Host \$host;
		proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		proxy_set_header X-Real-IP \$remote_addr;
	}
}
EOF_NGINX

close($NGINX);
system( "ln -s $path_to_nginx_config_avail/$cfg_file_name $path_to_nginx_config_enabled/001-$cfg_file_name.conf" );

info( "Installetion complete.".$/."- start margarita CMS $path_to_init/$cfg_file_name start".$/."- reload nginx /etc/init.d/nginx reload".$/."- go to link http://$hostname/auth/activationlink/firstlogin?email=$admin_email");


