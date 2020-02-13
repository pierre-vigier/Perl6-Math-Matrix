use v6.c;

unit module Math::Matrix::Type;

subset PosInt of Int is export where * > 0;
subset NumList of List is export where { .all ~~ (Numeric & .defined) };
subset NumArray of Array is export where { .all ~~ (Numeric & .defined) };
