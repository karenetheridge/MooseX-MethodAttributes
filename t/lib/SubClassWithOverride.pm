package SubClassWithOverride;

use Moose;
use MooseX::MethodAttributes;

extends qw/TestClass/;

override foo => sub {};

override bar => sub {};

1;

