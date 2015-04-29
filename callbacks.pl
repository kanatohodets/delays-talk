#!perl
use v5.20.1;
use warnings;

use Mojolicious::Lite;
use Mojo::Pg;
use experimental qw(signatures);

# ABSTRACT: JSON API for supermarkets to determine how much you pay for beer. 
# spoiler: the more you buy, the more you pay 
#
# if this sounds weird, .NL recently celebrated King's Day, where supermarkets
# limited customers to 1 unit of booze each. 

helper pg =>
    sub { state $pg = Mojo::Pg->new('postgresql://btyler@localhost/my_cool_db') };

# callbacks are concise, BUT
# 1) they encourage tight coupling (note the casual use of closed-over values from previous async actions)
# 2) error handling is tricky: what would you do if the second query returned an error?
# 3) callback mountain -- the flow gets hard to follow and read as the number of sequential async actions goes up

get '/booze_check' => sub ($c) {
    my $name = $c->param('name');
    $c->render_later;

    my $customer_sql = 'SELECT id FROM customers WHERE name = ?'; 
    $c->pg->db->query($customer_sql, $name => sub ($db, $err, $res) {
        my $customer_id = $res->expand->hashes->[0]->{id};

        my $count_sql = 'SELECT COUNT(1) FROM beer_log WHERE customer_id = ?';
        $c->pg->db->query($count_sql, $customer_id => sub ($db, $err, $res) {
            my $count = $res->hashes->[0]->{count};

            my $price_sql = 'SELECT MAX(price) FROM beer_price_scale WHERE ? >= range_start';
            $c->pg->db->query($price_sql, $count => sub ($db, $err, $res) {
                my $price = $res->array->[0];

                $c->render(json => { name => $name, id => $customer_id, beers => $count, price => $price });
            });
        });
    });
};

app->start;
