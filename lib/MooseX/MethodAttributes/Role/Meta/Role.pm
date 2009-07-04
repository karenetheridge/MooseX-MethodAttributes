package MooseX::MethodAttributes::Role::Meta::Role;
# ABSTRACT: metarole role for storing code attributes

use Moose::Util::MetaRole;
use Moose::Util qw/find_meta does_role ensure_all_roles/;
use MooseX::MethodAttributes::Role::Meta::Role::TraitFor::Combination;
use Carp qw/croak/;

use Moose::Role;

use namespace::clean -except => 'meta';

=head1 SYNOPSIS

    package MyRole;
    use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

    sub foo : Bar Baz('corge') { ... }

    package MyClass
    use Moose;

    with 'MyRole';

    my $attrs = MyClass->meta->get_method('foo')->attributes; # ["Bar", "Baz('corge')"]

=head1 DESCRIPTION

This module allows you to add code attributes to methods in Moose roles.

These attributes can then be found later once the methods are composed
into a class.

Note that currently roles with attributes cannot have methods excluded
or aliased, and will in turn confer this property onto any roles they
are composed onto.

=cut

with qw/
    MooseX::MethodAttributes::Role::Meta::Map
/;

after 'initialize' => sub {
    my ($self, $class, %args) = @_;
    ensure_all_roles($class, 'MooseX::MethodAttributes::Role::AttrContainer');
};

around method_metaclass => sub {
    my $orig = shift;
    my $self = shift;
    return $self->$orig(@_) if scalar @_;
    Moose::Meta::Class->create_anon_class(
        superclasses => [ $self->$orig ],
        roles        => [qw/
            MooseX::MethodAttributes::Role::Meta::Method
        /],
        cache        => 1,
    )->name();
};

sub _apply_metaclasses_to_target {
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
        unless (
            does_role( $thing->meta->name, __PACKAGE__ )
        ) {
            Moose::Util::MetaRole::apply_metaclass_roles(
                for_class       => $thing->name,
                metaclass_roles => [ __PACKAGE__ ],
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

around 'apply' => sub {
    my ($orig, $self, $thing, %opts) = @_;
    die("MooseX::MethodAttributes does not currently support method exclusion or aliasing.")
        if ($opts{alias} or $opts{exclude});

    $self->_apply_metaclasses_to_target($thing);

    # Note that the metaclass instance we started out with may have been turned
    # into lies by the role application process, so we explicitly re-fetch it
    # here.
    my $meta = find_meta($thing->name);

    my $ret = $self->$orig($meta);

    push @{ $meta->_method_attribute_list }, @{ $self->_method_attribute_list };
    @{ $meta->_method_attribute_map }{ (keys(%{ $self->_method_attribute_map }), keys(%{ $meta->_method_attribute_map })) }
        = (values(%{ $self->_method_attribute_map }), values(%{ $meta->_method_attribute_map }));

    return $ret;
};

# FIXME - We provide a blank method here in case we're using an old version of
#         Moose which doesn't provide this method to wrap. If this method is
#         provided by the class we're applied to, then this method is excluded
#         and just the modifier is applied.
sub _application_hook {}

around _application_hook => sub {
    my ($orig, $self) = (shift, shift);
    my $to_apply = $self->$orig(@_);
    my $new_class = Moose::Meta::Class->create_anon_class(
        superclasses => [ ref($to_apply) ],
        roles        => [qw/
            MooseX::MethodAttributes::Role::Meta::Role::TraitFor::Combination
        /],
        cache        => 1,
    )->name();
    bless $to_apply, $new_class; # FIXME - This is disgusting, I should apply
                                 #         a role to the instance, but that
                                 #         fails somehow..
    return $to_apply;
};

package # Hide from PAUSE
    Moose::Meta::Role::Custom::Trait::MethodAttributes;

sub register_implementation { 'MooseX::MethodAttributes::Role::Meta::Role' }

1;

