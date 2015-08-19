#!perl
use v5.22.0;
use warnings;

use Mojolicious::Lite;
use Mojo::Pg;
use Mojo::IOLoop;
use experimental qw(signatures postderef);

helper pg =>
    sub { state $pg = Mojo::Pg->new('postgresql://btyler@localhost/my_cool_db') };

# and now, for something completely different: you can execute multiple
# asynchronous tasks concurrently in a single step of a delay.
#
# the next step will be called only when all actions from the preceding step
# complete. the arguments to the next step will be given in call order (-not-
# return order).
get '/multi_query' => sub ($c) {
    my $delay = Mojo::IOLoop->delay(
        sub ($d) {
            $c->pg->db->query('select ?::text, pg_sleep(4)',
                'Obama' => $d->begin);
            $c->pg->db->query('select ?::text, pg_sleep(2)',
                'Putin' => $d->begin);
        },
        sub ($d, $obama_err, $obama_res, $putin_err, $putin_res) {
            $c->render(json => {
                obama => $obama_res->hashes->[0],
                putin => $putin_res->hashes->[0]
            });
        }
    )->wait;
};

app->start;
