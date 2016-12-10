# $Id$

package AnotherDatabase::Plugin;

use strict;
use warnings;

sub plugin {
  return MT->component('AnotherDatabase');
}

sub _log {
  my ($msg) = @_;
  return unless defined($msg);
  my $prefix = sprintf "%s:%s:%s: %s", caller();
  $msg = $prefix . $msg if $prefix;
  use MT::Log;
  my $log = MT::Log->new;
  $log->message($msg);
  $log->save or die $log->errstr;
  return;
}

1;
