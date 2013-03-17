#!/bin/sh
/bin/grep -r "config_site" ./templates/ | /bin/sed "s/^.*\.config_site\.\([^ ;]*\).*/\1/" | /usr/bin/sort | /usr/bin/uniq | /usr/bin/perl -MConfig::JSON -e '
my $cfg = Config::JSON->new("margarita.cfg"); 
my $config_site = $cfg->get("site"); 
while(<>){ 
	chomp($_); 
	next if exists $config_site->{$_}; 
	$config_site->{$_} = "";
}; 
$cfg->set('site', $config_site);
'

