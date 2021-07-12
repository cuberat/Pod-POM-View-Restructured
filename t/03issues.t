#!perl

use strict;
use warnings;

use Test::More;
use File::Slurp 'read_file';
use Test::Differences;

use Pod::POM::View::Restructured;
my $conv = Pod::POM::View::Restructured->new();
isa_ok($conv, 'Pod::POM::View::Restructured');

for my $pod (glob('t/issues/*.pod')) {
    my ($issue) = $pod =~ m|^t/issues/(.*)\.pod$|;
    my $rv = $conv->convert_file($pod);
    ok($rv);

    my $expected = read_file("t/issues/$issue.rst");
    eq_or_diff($rv->{content}, $expected, "issue $issue");
}

done_testing();
