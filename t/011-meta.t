use v6;
use lib 'lib';
use Test;
plan 1;

constant PERL6_TEST_META = ?%*ENV<PERL6_TEST_META>;

if PERL6_TEST_META {
    require Test::META <&meta-ok>;
    meta-ok;
    done-testing;
}
else {
     skip-rest "Skipping meta test";
     exit;
}
