package MooseX::MethodAttributes::MetaclassMangler;

use Moose::Util::MetaRole;
use Moose::Util qw/find_meta does_role ensure_all_roles/;
use Carp qw/croak/;

use Moose::Role;

use namespace::clean -except => 'meta';

sub _mangle_metaclasses_for_target {
    my ($self, $thing) = @_;
    if ($thing->isa('Moose::Meta::Class')) {
        unless (
           does_role($thing, 'MooseX::MethodAttributes::Role::Meta::Class')
        && does_role($thing->method_metaclass, 'MooseX::MethodAttributes::Role::Meta::Method')
        && does_role($thing->wrapped_method_metaclass, 'MooseX::MethodAttributes::Role::Meta::Method::MaybeWrapped')) {

            Moose::Util::MetaRole::apply_metaclass_roles(
                for_class => $thing->name,
                metaclass_roles => ['MooseX::MethodAttributes::Role::Meta::Class'],
                method_metaclass_roles => ['MooseX::MethodAttributes::Role::Meta::Method'],
                wrapped_method_metaclass_roles => ['MooseX::MethodAttributes::Role::Meta::Method::MaybeWrapped'],
            );
        }
    }
    elsif ($thing->isa('Moose::Meta::Role')) {
        my $role = 'MooseX::MethodAttributes::Role::Meta::Role';
        unless (
            does_role( $thing->meta->name, $role)
        ) {
            Moose::Util::MetaRole::apply_metaclass_roles(
                for_class       => $thing->name,
                metaclass_roles => [ $role ],
            );
        }
        ensure_all_roles($thing->name,
            'MooseX::MethodAttributes::Role::AttrContainer',
        );
    }
    else {
        croak("Composing " . __PACKAGE__ . " onto instances is unsupported");
    }
}

1;

