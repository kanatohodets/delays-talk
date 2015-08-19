#!/usr/bin/env perl
use 5.22.0;
use strict;
use IO::Select;
use IO::Socket::IP;
use experimental qw(signatures postderef);

my $listen = IO::Socket::IP->new(Listen => 1, LocalPort => 8080, ReuseAddr => 1)
    or die "can't bind listen socket: $!";
my $select = IO::Select->new( $listen );

# ABSTRACT: A super simple non-blocking event loop 'chat' server. Connect with telnet or nc,
# e.g. 'telnet localhost 8080' or 'nc localhost 8080' -- ideally with multiple
# clients.
#
# Also, take a look at the process CPU usage: note that the loop isn't
# pegging your CPU, but the chat is still pretty responsive.
#
# For **maximum scalability** I could have used EV.pm, but that would obscure the
# 'loop' bit somewhat.
my (@broadcast, %handlers);
while (1) {
    for my $sock ($select->can_read(1)) {
        if ($sock == $listen) {
            my $new = $listen->accept;
            $select->add($new);
            $handlers{$new->fileno} = {
                on_read => sub ($data) { push @broadcast, $new->fileno . ": $data" }
            };
            push @broadcast, sprintf("* %s connected\n", $new->fileno);
        } else {
            if ($sock->sysread(my $buffer, 4096, 0)) {
                $handlers{$sock->fileno}->{on_read}->($buffer);
            } else {
                push @broadcast, sprintf("* %s disconnected\n", $sock->fileno);
                $select->remove($sock) and $sock->close;
            }
        }
    }
    if (my @writable = $select->can_write(1)) {
        if (my $message = shift @broadcast) {
            $_->print($message) for @writable;
        }
    }
}
