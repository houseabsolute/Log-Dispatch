package Log::Dispatch::File::Locked;

use strict;
use warnings;

use base qw( Log::Dispatch::File );

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

=head1 CAVEATS

B<DANGER!> Use very carefully in multi-process environments. Because the lock
is obtained at file open time, not at write time, you may experience deadlocks
in your system.  You should also seriously consider using the
C<close_after_write> option.  The C<syswrite> option might also be a reasonable
alternative to using this module (see L<Log::Dispatch::File>).

=head1 SEE ALSO

L<perlfunc/flock>

=cut

