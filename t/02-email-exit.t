#!/usr/bin/perl -w

use strict;

use Test::More;

unless ( -d '.svn' )
{
    plan skip_all => 'This test only runs for the maintainer';
    exit;
}

plan tests => 1;

system( 't/email-exit-helper.pl' );

is( $? >> 8, 5, 'exit code of helper was 5' );

