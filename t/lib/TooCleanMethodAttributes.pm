package TooCleanMethodAttributes;
# ABSTRACT: code attribute introspection

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;
use Moose::Util qw/find_meta does_role/;

Moose::Exporter->setup_import_methods(
    also => 'Moose',
);

sub init_meta {
    my ($class, %options) = @_;

    my $for_class = $options{for_class};
    my $meta = Moose::init_meta($class, %options);

    Moose::Util::MetaRole::apply_base_class_roles(
        for_class => $for_class,
        roles     => ['TooCleanAttrContainer'],
    );

    return $meta;
}

1;
