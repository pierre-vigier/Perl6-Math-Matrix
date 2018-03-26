use Test;
use Math::Matrix;
plan 4;


subtest {
    plan 2;
    my $a = Math::Matrix.new( [[1,2,3],[4,5,6]] );
    my $b = Math::Matrix.new( [[7,8],[9,10],[11,12]] );

    ok $a.map( * - 1 ) ~~ Math::Matrix.new([[0,1,2],[3,4,5]]),            "simple mapping";
    ok $a.map({$^v %% 2 ?? 1 !! 0}) ~~ Math::Matrix.new([[0,1,0],[1,0,1]]), "constructing binary map";
}, "Move";

subtest {
    plan 2;
    my $a = Math::Matrix.new( [[1,2,3],[4,5,6]] );
    my $b = Math::Matrix.new( [[7,8],[9,10],[11,12]] );

    ok $a.map( * - 1 ) ~~ Math::Matrix.new([[0,1,2],[3,4,5]]),            "simple mapping";
    ok $a.map({$^v %% 2 ?? 1 !! 0}) ~~ Math::Matrix.new([[0,1,0],[1,0,1]]), "constructing binary map";
}, "Swap";

subtest {
    plan 2;
    my $a = Math::Matrix.new( [[1,2,3],[4,5,6]] );
    my $b = Math::Matrix.new( [[7,8],[9,10],[11,12]] );

    ok $a.map( * - 1 ) ~~ Math::Matrix.new([[0,1,2],[3,4,5]]),            "simple mapping";
    ok $a.map({$^v %% 2 ?? 1 !! 0}) ~~ Math::Matrix.new([[0,1,0],[1,0,1]]), "constructing binary map";
}, "Prepend";


subtest {
    plan 3;
    my $a = Math::Matrix.new( [[1,2,3],[4,5,6]] );
    my $i = Math::Matrix.new-identity( 3 );

    ok $a.reduce-rows( &[+] ) == (6,15),            "simple row sum";
    ok $a.reduce-columns( &[*] ) == (4,10,18),       "simple column product";
    ok $i.reduce-rows( &[>] ) == (True, False, False), "question if row is sorted";
}, "Append";