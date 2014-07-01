package Log::Dispatch::Null;

use strict;
use warnings;

use Log::Dispatch::Output;

use parent qw( Log::Dispatch::Output );

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    my $self = bless {}, $class;

    $self->_basic_init(@_);

    return $self;
}

sub log_message { }

1;

# ABSTRACT: Object that accepts messages and does nothing

__END__

=head1 SYNOPSIS

  use Log::Dispatch;

  my $null
      = Log::Dispatch->new( outputs => [ [ 'Null', min_level => 'debug' ] ] );

  $null->emerg( "I've fallen and I can't get up" );

=head1 DESCRIPTION

This class provides a null logging object. Messages can be sent to the
object but it does nothing with them.

=cut

