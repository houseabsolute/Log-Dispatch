package Log::Dispatch::Base;

use strict;
use vars qw($VERSION @EXPORT_OK);

$VERSION = sprintf "%d.%02d", q$Revision: 1.9 $ =~ /: (\d+)\.(\d+)/;

1;

sub _get_callbacks
{
    shift;
    my %p = @_;

    return unless exists $p{callbacks};

    # If it's not an array ref of some sort its a code ref and this'll
    # cause an error.
    my @cb = eval { @{ $p{callbacks} }; };

    # Must have been a code ref.
    @cb = ($p{callbacks}) unless @cb;

    return @cb;
}

sub _apply_callbacks
{
    my $self = shift;
    my %p = @_;

    my $msg = delete $p{message};
    foreach my $cb ( @{ $self->{callbacks} } )
    {
	$msg = $cb->( message => $msg, %p );
    }

    return $msg;
}

__END__

=head1 NAME

Log::Dispatch::Base - Code shared by dispatch and output objects.

=head1 SYNOPSIS

  use Log::Dispatch::Base;

  ...

  @ISA = qw(Log::Dispatch::Base);

=head1 DESCRIPTION

Unless you are me, you probably don't need to know what this class
does.

=head1 AUTHOR

Dave Rolsky, <autarch@urth.org>

=cut
