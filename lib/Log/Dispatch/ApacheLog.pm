package Log::Dispatch::ApacheLog;

use strict;
use warnings;

our $VERSION = '2.68';

use Log::Dispatch::Types;
use Params::ValidationCompiler qw( validation_for );

BEGIN {
    if ( $ENV{MOD_PERL} && $ENV{MOD_PERL} =~ /2\./ ) {
        require Apache2::Log;
    }
    else {
        require Apache::Log;
    }
}

use base qw( Log::Dispatch::Output );

{
    my $validator = validation_for(
        params => { apache => { type => t('ApacheLog') } },
        slurpy => 1,
    );

    sub new {
        my $class = shift;
        my %p     = $validator->(@_);

        my $self = bless { apache_log => ( delete $p{apache} )->log }, $class;
        $self->_basic_init(%p);

        return $self;
    }
}

{
    my %methods = (
        emergency => 'emerg',
        critical  => 'crit',
        warning   => 'warn',
    );

    sub log_message {
        my $self = shift;
        my %p    = @_;

        my $level = $self->_level_as_name( $p{level} );

        my $method = $methods{$level} || $level;

        $self->{apache_log}->$method( $p{message} );
    }
}

1;

# ABSTRACT: Object for logging to Apache::Log objects

__END__

=head1 SYNOPSIS

  use Log::Dispatch;

  my $log = Log::Dispatch->new(
      outputs => [
          [ 'ApacheLog', apache => $r ],
      ],
  );

  $log->emerg('Kaboom');

=head1 DESCRIPTION

This module allows you to pass messages to Apache's log object,
represented by the L<Apache::Log> class.

=head1 CONSTRUCTOR

The constructor takes the following parameters in addition to the standard
parameters documented in L<Log::Dispatch::Output>:

=over 4

=item * apache ($)

An object of either the L<Apache> or L<Apache::Server> classes. Required.

=back

=cut
