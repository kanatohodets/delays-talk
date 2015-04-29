#!perl
use v5.20.1;
use warnings;

use Mojolicious::Lite;
use Mojo::Pg;
use Mojo::IOLoop;
use experimental qw(signatures postderef);

# ABSTRACT: JSON API for supermarkets to determine how much you pay for beer. 
# spoiler: the more you buy, the more you pay 
#
# if this sounds weird, .NL recently celebrated King's Day, where supermarkets
# limited customers to 1 unit of booze each. 

helper pg =>
    sub { state $pg = Mojo::Pg->new('postgresql://btyler@localhost/my_cool_db') };

# using Delay to manage flow gives us:
# 1) nice error handling with ->catch
# 2) modularity (data is explicitly passed from step to step with $d->data)
# 3) better readability -- no creeping towards the right margin

get '/booze_check' => sub ($c) {
    my $name = $c->param('name');
    $c->render_later;

    my $delay = Mojo::IOLoop->delay(
        sub ($d) {
            $d->data(name => $name);
            $c->pg->db->query('SELECT id FROM customers WHERE name = ?', $name => $d->begin);
        },
        sub ($d, $err, $res) {
            die $err if $err;
            my $customer_id = $res->array->[0];

            $d->data(customer_id => $customer_id);
            $c->pg->db->query('SELECT COUNT(1) FROM beer_log WHERE customer_id = ?', $customer_id => $d->begin);
        },
        sub ($d, $err, $res) {
            die $err if $err;
            my $count = $res->array->[0];

            $d->data(count => $count);
            $c->pg->db->query('SELECT MAX(price) FROM beer_price_scale WHERE ? >= range_start', $count => $d->begin);
        },
        sub ($d, $err, $res) {
            die $err if $err;
            my $price = $res->array->[0];

            my ($name, $customer_id, $count) = $d->data->@{qw(name customer_id count)};
            $c->render(json => { name => $name, id => $customer_id, beers => $count, price => $price });
        })->catch(sub ($d, $err) { 
            $c->render(text => "blorg error! $err", code => 500);
    })->wait;
};

app->start;
