package Log::Dispatch::File::Locked;

use strict;
use warnings;

use base qw( Log::Dispatch::File );

our $VERSION = '2.54';

use Fcntl qw(:DEFAULT :flock);

sub _open_file {
    my $self = shift;

    $self->SUPER::_open_file();

    my $fh = $self->{fh};

    flock( $fh, LOCK_EX )
        or die "Cannot lock '$self->{filename}' for writing: $!";

    # just in case there was an append while we waited for the lock
    seek( $fh, 0, 2 )
        or die "Cannot seek to end of '$self->{filename}': $!";
}

sub log_message {
    my $self = shift;

    $self->SUPER::log_message(@_);
    return if $self->{close};

    flock( $self->{fh}, LOCK_UN );
}

1;

# ABSTRACT: Subclass of Log::Dispatch::File to facilitate locking

__END__

=head1 SYNOPSIS

  use Log::Dispatch;

  my $log = Log::Dispatch->new(
      outputs => [
          [
              'File::Locked',
              min_level => 'info',
              filename  => 'Somefile.log',
              mode      => '>>',
              newline   => 1
          ]
      ],
  );

  $log->emerg("I've fallen and I can't get up");

=head1 DESCRIPTION

This module acts exactly like L<Log::Dispatch::File> except that it
obtains an exclusive lock on the file while opening it.

Note that if you are using this output because you want to write to a file
from multiple processes, you should open the file with the append C<mode>
(C<<< >> >>>), or else it's quite likely that one process will overwrite
another.

=head1 SEE ALSO

L<perlfunc/flock>

=cut

