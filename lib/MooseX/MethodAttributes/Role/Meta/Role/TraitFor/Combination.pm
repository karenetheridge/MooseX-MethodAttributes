package MooseX::MethodAttributes::Role::Meta::Role::TraitFor::Combination;
use Moose::Role;
use Moose::Util qw/find_meta/;
use namespace::clean -except => [qw/ meta /];

around 'apply' => sub {
    my ($orig, $self, $thing, %opts) = @_;

    $self->MooseX::MethodAttributes::Role::Meta::Role::_apply_metaclasses_to_target($thing);

    my $meta = find_meta($thing->name);

    my $ret = $self->$orig($meta, %opts);

    my @roles_with_attributes = grep { $_->can('_method_attribute_list') }
        @{ $self->{roles} };

    push @{ $meta->_method_attribute_list },
        map { @{ $_->_method_attribute_list } } @roles_with_attributes;
    @{ $meta->_method_attribute_map }{ keys(%{$_->_method_attribute_map}) }
        = values(%{$_->_method_attribute_map})
        for @roles_with_attributes;

    return $ret;
};

1;

