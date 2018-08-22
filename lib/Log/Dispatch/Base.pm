package Log::Dispatch::Base;

use strict;
use warnings;

use Carp ();
use Log::Dispatch::Vars
    qw( %CanonicalLevelNames %LevelNamesToNumbers @OrderedLevels );
use Scalar::Util qw( refaddr );

our $VERSION = '2.68';

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _level_as_number {
    my $self  = shift;
    my $level = shift;

    my $level_name = $self->level_is_valid($level);
    return unless $level_name;

    return $LevelNamesToNumbers{$level_name};
}
## use critic

sub level_is_valid {
    shift;
    my $level = shift;

    if ( !defined $level ) {
        Carp::croak('Logging level was not provided');
    }

    if ( $level =~ /\A[0-9]+\z/ && $level <= $#OrderedLevels ) {
        return $OrderedLevels[$level];
    }

    return $CanonicalLevelNames{$level};
}

## no critic (Subroutines::ProhibitUnusedPrivateSubroutines)
sub _apply_callbacks {
    my $self = shift;
    my %p    = @_;

    my $msg = delete $p{message};
    for my $cb ( @{ $self->{callbacks} } ) {
        $msg = $cb->( message => $msg, %p );
    }

    return $msg;
}

sub add_callback {
    my $self  = shift;
    my $value = shift;

    Carp::carp("given value $value is not a valid callback")
        unless ref $value eq 'CODE';

    $self->{callbacks} ||= [];
    push @{ $self->{callbacks} }, $value;

    return;
}

sub remove_callback {
    my $self = shift;
    my $cb   = shift;

    Carp::carp("given value $cb is not a valid callback")
        unless ref $cb eq 'CODE';

    my $cb_id = refaddr $cb;
    $self->{callbacks}
        = [ grep { refaddr $_ ne $cb_id } @{ $self->{callbacks} } ];

    return;
}

1;

# ABSTRACT: Code shared by dispatch and output objects.

__END__

=for Pod::Coverage .*

=head1 SYNOPSIS

  use Log::Dispatch::Base;

  ...

  @ISA = qw(Log::Dispatch::Base);

=head1 DESCRIPTION

Unless you are me, you probably don't need to know what this class
does.

=cut
