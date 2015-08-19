use Mojolicious::Lite;

get '/' => sub {
	my $c = shift;
	$c->render(text => "HELLO");
};

app->start;
