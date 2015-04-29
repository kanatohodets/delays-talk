#!perl
use v5.20.1;
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
    $c->render_later;

    my $delay = Mojo::IOLoop->delay(
        sub ($d) {
            $c->pg->db->query('select ?::text, pg_sleep(4)',
                'Cees' => $d->begin);
            $c->pg->db->query('select ?::text, pg_sleep(2)',
                'Jos' => $d->begin);
        },
        sub ($d, $cees_err, $cees_res, $jos_err, $jos_res) {
            $c->render(json => { 
                cees => $cees_res->hashes->[0], 
                jos => $jos_res->hashes->[0] 
            });
        }
    )->wait;
};

app->start;
