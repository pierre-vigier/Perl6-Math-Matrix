use v6.c;

subset PosInt of Int where * > 0;
subset NumList of List where { .all ~~ (Numeric & .defined) };
subset NumArray of Array where { .all ~~ (Numeric & .defined) };
