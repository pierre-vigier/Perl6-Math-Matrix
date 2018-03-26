use Test;
use Math::Matrix;
plan 4;

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
    ok $a.elems == 6,           "right number of elements";
    ok $i.elems == 9,           "right number of elements too";
}, "Elems";


subtest {
    plan 5;
    ok $a.map( * - 1 )              ~~ Math::Matrix.new([[0,1,2],[3,4,5]]), "simple mapping";
    ok $a.map({$^v %% 2 ?? 1 !! 0}) ~~ Math::Matrix.new([[0,1,0],[1,0,1]]), "constructing binary map";
    ok $a.map-row(1, {$_ + 1})      ~~ Math::Matrix.new([[1,2,3],[5,6,7]]), "mapping row";
    ok $a.map-column(0, {0})        ~~ Math::Matrix.new([[0,2,3],[0,5,6]]), "mapping column";
    ok $a.map-cell(0, 2, {$_*2})    ~~ Math::Matrix.new([[1,2,6],[4,5,6]]), "mapping cell";
}, "Map";


subtest {
    plan 4;
    ok $a.reduce( &[+] )      == (21),                "simple cell sum";
    ok $a.reduce-rows( &[+] ) == (6,15),              "simple row sum";
    ok $a.reduce-columns(&[*])== (4,10,18),           "simple column product";
    ok $i.reduce-rows( &[>] ) == (True, False, False),"question if row is sorted";
}, "Reduce";