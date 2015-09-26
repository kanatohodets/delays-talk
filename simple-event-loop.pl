#!/usr/bin/env perl
use 5.22.0;
use strict;
use IO::Select;
use IO::Socket::IP;
use HTTP::Parser;
use experimental qw(signatures postderef);

my $listen = IO::Socket::IP->new(Listen => 1, LocalPort => 8080, ReuseAddr => 1)
    or die "can't bind listen socket: $!";
my $select = IO::Select->new( $listen );

# ABSTRACT: A super simple non-blocking HTTP server that serves a single route: get /
#
# For **maximum scalability** I could have used EV.pm, but that would obscure the
# 'loop' bit somewhat.

my @events;
my %to_write;
my %watchers;
%watchers = (
  'get /' => sub ($sock) {
    my $res = HTTP::Response->new(
      200, 'OK', [], "you're cool!");
    $to_write{$sock->fileno} =
      "HTTP/1.1 " . $res->as_string;
  },
  read => sub ($sock) {
    my $http = HTTP::Parser->new();
    if ($sock->sysread(my $buffer, 4096, 0)) {
      if ($http->add($buffer) == 0) {
        my $req = $http->request;
        if ($req->method eq 'GET' && $req->uri eq '///') {
          $watchers{'get /'}->($sock);
        }
      }
    } else {
      $select->remove($sock) && $sock->close;
    }
  }
);

say "listening...";
while (1) {
  for my $sock ($select->can_read(1)) {
    if ($sock == $listen) {
      $select->add($listen->accept);
    } else {
      push @events, [ read => $sock ];
    }
  }
  while (my $evt = shift @events) {
    my ($event, $data) = @$evt;
    $watchers{$event}->($data);
  }
  for my $sock ($select->can_write(1)) {
    if (my $res = delete $to_write{$sock->fileno}) {
      $sock->syswrite($res, length $res);
      $select->remove($sock) && $sock->close;
    }
  }
}
