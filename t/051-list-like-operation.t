use lib "lib";
use Test;
use Math::Matrix :ALL;
plan 5;

my $morecols = Math::Matrix.new( [[1,2,3],[4,5,6]] );
my $morerows = Math::Matrix.new( [[7,8],[9,10],[11,12]] );
my $id = Math::Matrix.new-identity( 3 );

subtest {
    plan 2;
    ok $morecols.elems == 6,           "right number of elements";
    ok $id.elems == 9,           "right number of elements too";
}, "Elems";


subtest {
    plan 3;
    ok $morecols.elem(1..6),      "All cell values are cells within asked range";
    ok $morerows.elem(1..22),     "All cell values are cells within way larger range";
    nok $morecols.elem(7..12),    "There are cells not within asked range";
}, "Elem";

subtest {
    plan 4;
    ok $morecols.cont( 3 ),            "value 3 is in a matrix cell";
    nok $morecols.cont( 7 ),           "value 7 is in a matrix cell";
    ok $morecols.cont(2..4),           "There are cells within asked range";
    nok $morecols.cont(7..12),         "There are no cells within asked range";
}, "Cont";


subtest {
    plan 4;
    ok $morecols.map( * - 1 )              ~~ MM[[0,1,2],[3,4,5]], "simple mapping";
    ok $morecols.map({$^v %% 2 ?? 1 !! 0}) ~~ MM[[0,1,0],[1,0,1]], "constructing binary map";
    ok $morecols.map(rows=>1..1, {$_ + 1}) ~~ MM[[1,2,3],[5,6,7]], "mapping row";
    ok $morecols.map(columns => 0..0, {0}) ~~ MM[[0,2,3],[0,5,6]], "mapping column";
}, "Map";


subtest {
    plan 4;
    ok $morecols.reduce( &[+] )      == (21),           "simple cell sum";
    ok $morecols.reduce-rows( &[+] ) == (6,15),         "simple row sum";
    ok $morecols.reduce-columns(&[*])== (4,10,18),      "simple column product";
    ok $id.reduce-rows( &[>] ) == (True, False, False), "question if row is sorted";
}, "Reduce";
