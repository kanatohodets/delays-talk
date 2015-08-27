#!/usr/bin/env perl
use 5.22.0;
use strict;
use IO::Socket::IP;
use HTTP::Parser;
use Data::Dumper qw(Dumper);
use experimental qw(signatures postderef);

my $listen = IO::Socket::IP->new(Listen => 1, LocalPort => 8080, ReuseAddr => 1)
    or die "can't bind listen socket: $!";

while (my $sock = $listen->accept) {
    my $http = HTTP::Parser->new();
    if ($sock->sysread(my $buffer, 4096, 0)) {
        if ($http->add($buffer) == 0) {
            my $req = $http->request;
            if ($req->method eq 'GET' && $req->uri eq '///') {
                my $res = HTTP::Response->new(200, 'OK', [], 'you are cool!');
                my $message = "HTTP/1.1 " . $res->as_string;
                $sock->syswrite($message, length $message);
            }
        }
    }
}

