use strict;
use Test::More;

{
    package BaseClass;
    use Moose;
    BEGIN { extends 'MooseX::MethodAttributes::Inheritable'; }
    no Moose;

    sub moo : Foo {}
}
{
    package NoAttributes::CT;
    use Moose;
    BEGIN { extends qw/BaseClass/; };

    sub test {}
}
{
    package NoAttributes::RT;
    use Moose;
    extends qw/BaseClass/;

    sub test {}
}

foreach my $class (qw/ CT RT /) {
    my $class_name = 'NoAttributes::' . $class;
    my $meta = $class_name->meta;
    my $meth = $meta->find_method_by_name('test');
    ok $meth->can('attributes'), 'method metaclass has ->attributes method for ' . $class;;
}

done_testing;

