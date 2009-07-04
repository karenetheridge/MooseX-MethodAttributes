#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Moose::Util qw/does_role/;
use Moose::Meta::Role;

use Test::More;

unless (Moose::Meta::Role->can('_application_hook')) {
    plan skip_all => 'Your Moose does not support roles hooking the application process';
    exit 0;
}

plan tests => 4;

use MooseX::MethodAttributes ();

use ClassUsingCombinationRoleWithAttributes;

my $meta = ClassUsingCombinationRoleWithAttributes->meta;
isa_ok($meta, 'Moose::Meta::Class');
my @methods = $meta->get_all_methods_with_attributes;
ok scalar(@methods), 'Have methods with attributes';

my $foo = $meta->get_method('foo');
ok $foo, 'Got foo method';
ok does_role($foo, 'MooseX::MethodAttributes::Role::Meta::Method'),
    'foo method meta instance does the attribute decorated method role';

