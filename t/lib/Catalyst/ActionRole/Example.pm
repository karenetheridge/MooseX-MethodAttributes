package Catalyst::ActionRole::Example;
use Moose::Role;
use namespace::clean -except => 'meta';

around 'execute' => sub {
    my ($orig, $self, @args) = @_;
    $self->$orig(@args);
};

1;

