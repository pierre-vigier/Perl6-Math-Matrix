use Test;
use Math::Matrix;
plan 4;

my $a = Math::Matrix.new( [[1,2,3],[2,3,4],[3,4,5]] );
my $b = Math::Matrix.new( [[7,8],[9,10]] );
my $i = Math::Matrix.new-identity( 3 );

subtest {
    plan 8;
    ok $a.move-row(0, 2) ~~ Math::Matrix.new([[2,3,4],[3,4,5],[1,2,3]]),    "move a row";
    ok $a.move-row(2=>1) ~~ Math::Matrix.new([[1,2,3],[3,4,5],[2,3,4]]),    "move a another row, pair form";
    dies-ok { ok $a.move-row(5, 1);   },                                    "source row number out of bound";
    dies-ok { ok $a.move-row(1, -3);  },                                    "target row number out of bound";

    ok $a.move-column(0, 2) ~~ Math::Matrix.new([[2,3,1],[3,4,2],[4,5,3]]), "move a column";
    ok $a.move-column(2=>1) ~~ Math::Matrix.new([[1,3,2],[2,4,3],[3,5,4]]), "move a another column, pair form";
    dies-ok { ok $a.move-column(3, 1);   },                                 "source column number out of bound";
    dies-ok { ok $a.move-column(1, -5);  },                                 "target column number out of bound";

}, "Move";


subtest {
    plan 8;
    ok $a.swap-rows(0, 2) ~~ Math::Matrix.new([[3,4,5],[2,3,4],[1,2,3]]),   "swap two rows";
    ok $a.swap-rows(2, 1) ~~ Math::Matrix.new([[1,2,3],[3,4,5],[2,3,4]]),   "swap another two rows";
    dies-ok { ok $a.swap-rows(5, 1);   },                                   "first row number out of bound";
    dies-ok { ok $a.swap-rows(1, -3);  },                                   "second row number out of bound";

    ok $a.swap-columns(0, 2) ~~ Math::Matrix.new([[3,2,1],[4,3,2],[5,4,3]]),"swap two columns";
    ok $a.swap-columns(2, 1) ~~ Math::Matrix.new([[1,3,2],[2,4,3],[3,5,4]]),"swap another two columns";
    dies-ok { ok $a.swap-columns(3, 1);   },                                "first column number out of bound";
    dies-ok { ok $a.swap-columns(1, -5);  },                                "second column number out of bound";

}, "Swap";


subtest {
    my $answer1 = Math::Matrix.new([[1,0,0],[0,1,0],[0,0,1],[1,2,3],[2,3,4],[3,4,5]]);
    my $answer2 = Math::Matrix.new([[1,0,0,1,2,3],[0,1,0,2,3,4],[0,0,1,3,4,5]]);

    plan 8;
    ok $a.prepend-vertically($i)                        ~~ $answer1,        "prepend vertically matrix";
    ok $a.prepend-vertically([[1,0,0],[0,1,0],[0,0,1]]) ~~ $answer1,        "prepend vertically data";
    dies-ok { $a.prepend-vertically($b) },                                  "can not prepend vertically matrix with different size";
    dies-ok { $a.prepend-vertically([[1]]) },                               "can not prepend vertically data matrix with different size";

    ok $a.prepend-horizontally($i)                        ~~ $answer2,      "prepend horizontally matrix";
    ok $a.prepend-horizontally([[1,0,0],[0,1,0],[0,0,1]]) ~~ $answer2,      "prepend horizontally data";
    dies-ok { $a.prepend-horizontally($b) },                                "can not prepend horizontally matrix with different size";
    dies-ok { $a.prepend-horizontally([[1]]) },                             "can not prepend horizontally data matrix with different size";

}, "Prepend";


subtest {
    my $answer1 = Math::Matrix.new([[1,2,3],[2,3,4],[3,4,5],[1,0,0],[0,1,0],[0,0,1]]);
    my $answer2 = Math::Matrix.new([[1,2,3,1,0,0],[2,3,4,0,1,0],[3,4,5,0,0,1]]);
 
    plan 8;
    ok $a.append-vertically($i)                        ~~ $answer1,         "append vertically matrix";
    ok $a.append-vertically([[1,0,0],[0,1,0],[0,0,1]]) ~~ $answer1,         "append vertically data";
    dies-ok { $a.append-vertically($b) },                                   "can not append vertically matrix with different size";
    dies-ok { $a.append-vertically([[1]]) },                                "can not append vertically data matrix with different size";

    ok $a.append-horizontally($i)                        ~~ $answer2,       "append horizontally matrix";
    ok $a.append-horizontally([[1,0,0],[0,1,0],[0,0,1]]) ~~ $answer2,       "append horizontally data";
    dies-ok { $a.append-horizontally($b) },                                 "can not append horizontally matrix with different size";
    dies-ok { $a.append-horizontally([[1]]) },                              "can not append horizontally data matrix with different size";

}, "Append";
