use Test;
use Math::Matrix;
plan 3;

my $a = Math::Matrix.new( [[1,2,3],[4,5,6]] );
my $b = Math::Matrix.new( [[7,8],[9,10],[11,12]] );
my $i = Math::Matrix.new-identity( 3 );


subtest {
    plan 4;

    ok $a.elem( 3 ),            "value 3 is in a matrix cell";
    nok $a.elem( 7 ),           "value 7 is in a matrix cell";
    ok $a.elem(2..4),           "There are cells within asked range";
    nok $a.elem(7..12),         "There are no cells within asked range";
}, "Elem";

subtest {
    plan 2;
    ok $a.map( * - 1 )              ~~ Math::Matrix.new([[0,1,2],[3,4,5]]), "simple mapping";
    ok $a.map({$^v %% 2 ?? 1 !! 0}) ~~ Math::Matrix.new([[0,1,0],[1,0,1]]), "constructing binary map";
}, "Map";

subtest {
    plan 3;

    ok $a.reduce-rows( &[+] ) == (6,15),            "simple row sum";
    ok $a.reduce-columns( &[*] ) == (4,10,18),       "simple column product";
    ok $i.reduce-rows( &[>] ) == (True, False, False), "question if row is sorted";
}, "Reduce";