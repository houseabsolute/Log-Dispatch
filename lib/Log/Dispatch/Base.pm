package Log::Dispatch::Base;

use strict;
use warnings;
use Scalar::Util qw( refaddr );

our $VERSION = '2.57';

sub _get_callbacks {
    shift;
    my %p = @_;

    return unless exists $p{callbacks};

    return @{ $p{callbacks} }
        if ref $p{callbacks} eq 'ARRAY';

    return $p{callbacks}
        if ref $p{callbacks} eq 'CODE';

    return;
}

sub _apply_callbacks {
    my $self = shift;
    my %p    = @_;

    my $msg = delete $p{message};
    foreach my $cb ( @{ $self->{callbacks} } ) {
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
    my $self  = shift;
    my $value = shift;

    Carp::carp("given value $value is not a valid callback")
        unless ref $value eq 'CODE';

    my $cb_id = refaddr $value;
    my $cbs   = $self->{callbacks};
    my ($i) = grep { refaddr $cbs->[$_] eq $cb_id } 0 .. $#$cbs;
    splice @{ $self->{callbacks} }, $i, 1;

    return;
}

1;

# ABSTRACT: Code shared by dispatch and output objects.

__END__

=for Pod::Coverage add_callback

=for Pod::Coverage remove_callback

=head1 SYNOPSIS

  use Log::Dispatch::Base;

  ...

  @ISA = qw(Log::Dispatch::Base);

=head1 DESCRIPTION

Unless you are me, you probably don't need to know what this class
does.

=cut
