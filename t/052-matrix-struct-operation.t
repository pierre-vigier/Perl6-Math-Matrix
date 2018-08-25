use lib "lib";
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
    my $answer2 = Math::Matrix.new([[1,2,3],[1,0,0],[0,1,0],[0,0,1],[2,3,4],[3,4,5]]);
    my $answer3 = Math::Matrix.new([[1,2,3],[1,0,0],[0,1,0],[0,0,1],[3,4,5]]);
    my $answer4 = Math::Matrix.new([[1,2,3],[2,3,4],[3,4,5],[1,0,0],[0,1,0],[0,0,1]]);

    plan 12;
    ok $a.splice-rows(0,0,$i)                        ~~ $answer1,       "prepend rows of a matrix";
    ok $a.splice-rows(0,0,[[1,0,0],[0,1,0],[0,0,1]]) ~~ $answer1,       "prepend rows of data";

    dies-ok { $a.splice-rows(10) },                                     "splicing from out of bound index";
    dies-ok { $a.splice-rows(1,-20) },                                  "try to splice too little";
    dies-ok { $a.splice-rows(0,0,$b) },                                 "can not splice rows with matrix with different size";
    dies-ok { $a.splice-rows(0,0,[[1]])},                               "can not splice rows with data matrix with different size";

    ok $a.splice-rows(1,0,$i)                         ~~ $answer2,      "insert rows of matrix";
    ok $a.splice-rows(1,0,[[1,0,0],[0,1,0],[0,0,1]])  ~~ $answer2,      "insert rows of data";
    ok $a.splice-rows(1,1,$i)                         ~~ $answer3,      "replace rows of matrix";
    ok $a.splice-rows(1,1,[[1,0,0],[0,1,0],[0,0,1]])  ~~ $answer3,      "replace rows of data";
    ok $a.splice-rows(-1,0,$i)                        ~~ $answer4,      "append rows of matrix";
    ok $a.splice-rows(-1,0,[[1,0,0],[0,1,0],[0,0,1]]) ~~ $answer4,      "append rows of data";

}, "Splice Rows";


subtest {
    my $answer1 = Math::Matrix.new([[1,0,0,1,2,3],[0,1,0,2,3,4],[0,0,1,3,4,5]]);
    my $answer2 = Math::Matrix.new([[1,1,0,0,2,3],[2,0,1,0,3,4],[3,0,0,1,4,5]]);
    my $answer3 = Math::Matrix.new([[1,1,0,0,  3],[2,0,1,0,  4],[3,0,0,1,  5]]);
    my $answer4 = Math::Matrix.new([[1,2,3,1,0,0],[2,3,4,0,1,0],[3,4,5,0,0,1]]);

    plan 12;
    ok $a.splice-columns(0,0,$i)                        ~~ $answer1,    "prepend columns of a matrix";
    ok $a.splice-columns(0,0,[[1,0,0],[0,1,0],[0,0,1]]) ~~ $answer1,    "prepend columns of data";

    dies-ok { $a.splice-columns(10) },                                  "splicing from out of bound index";
    dies-ok { $a.splice-columns(1,-20) },                               "try to splice too little";
    dies-ok { $a.splice-columns(0,0,$b) },                              "can not splice columns with matrix with different size";
    dies-ok { $a.splice-columns(0,0,[[1]])},                            "can not splice columns with data matrix of different size";

    ok $a.splice-columns(1,0,$i)                         ~~ $answer2,   "insert columns of matrix";
    ok $a.splice-columns(1,0,[[1,0,0],[0,1,0],[0,0,1]])  ~~ $answer2,   "insert columns of data";
    ok $a.splice-columns(1,1,$i)                         ~~ $answer3,   "replace columns of matrix";
    ok $a.splice-columns(1,1,[[1,0,0],[0,1,0],[0,0,1]])  ~~ $answer3,   "replace columns of data";
    ok $a.splice-columns(-1,0,$i)                        ~~ $answer4,   "append columns of matrix";
    ok $a.splice-columns(-1,0,[[1,0,0],[0,1,0],[0,0,1]]) ~~ $answer4,   "append columns of data";

}, "Splice Columns";
