use strict;
use warnings;

use Test::More;

plan skip_all => 'This test is only run for the module author'
    unless -d '.hg' || $ENV{IS_MAINTAINER};

plan 'no_plan';

require File::Find::Rule;
require Module::Info;


my %versions;
for my $pm_file ( File::Find::Rule->file->name( qr/\.pm$/ )->in('lib' ) )
{
    my $mod = Module::Info->new_from_file($pm_file);

    ( my $stripped_file = $pm_file ) =~ s{^lib/}{};

    $versions{$stripped_file} = $mod->version;
}

my $ld_ver = $versions{'Log/Dispatch.pm'};

for my $module ( grep { $_ ne 'Log/Dispatch.pm' } sort keys %versions )
{
    is( $versions{$module}, $ld_ver,
        "version for $module is the same as in Log/Dispatch.pm" );
}
