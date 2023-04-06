package Log::Dispatch::Types;

use strict;
use warnings;
use namespace::autoclean;

our $VERSION = '2.72';

use parent 'Specio::Exporter';

use Log::Dispatch::Vars qw( %CanonicalLevelNames );
use Specio 0.32;
use Specio::Declare;
use Specio::Library::Builtins -reexport;
use Specio::Library::Numeric -reexport;
use Specio::Library::String -reexport;

any_can_type(
    'ApacheLog',
    methods => ['log'],
);

declare(
    'ArrayOfAddresses',
    parent => t( 'ArrayRef', of => t('NonEmptySimpleStr') ),
);

coerce(
    t('ArrayOfAddresses'),
    from   => t('NonEmptySimpleStr'),
    inline => sub {"[ $_[1] ]"},
);

declare(
    'Callbacks',
    parent => t( 'ArrayRef', of => t('CodeRef') ),
);

coerce(
    t('Callbacks'),
    from   => t('CodeRef'),
    inline => sub {"[ $_[1] ]"},
);

any_can_type(
    'CanPrint',
    methods => ['print'],
);

{
    my $level_names_re = join '|', keys %CanonicalLevelNames;
    declare(
        'LogLevel',
        parent => t('Value'),
        inline => sub {
            sprintf( <<'EOF', $_[1], $level_names_re );
%s =~ /\A(?:[0-7]|%s)\z/
EOF
        },
    );
}

declare(
    'SyslogSocket',
    parent => t(
        'Maybe',
        of => union( of => [ t('NonEmptyStr'), t('ArrayRef'), t('HashRef') ] )
    ),
);

1;

# ABSTRACT: Types used for parameter checking in Log::Dispatch

__END__

=pod

=for Pod::Coverage .*

=head1 DESCRIPTION

This module has no user-facing parts.

=cut
