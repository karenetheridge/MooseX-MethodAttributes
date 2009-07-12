package RoleWithAttributes;
use Moose::Role -traits => 'MethodAttributes';
use namespace::clean -except => 'meta';

sub foo
    :AnAttr
    :Does('Example')
{
    'foo'
}

1;

