use v6.c;

unit role Math::Matrix::Operators;

multi sub infix:<+>(::?CLASS $a, ::?CLASS $b --> ::?CLASS:D ) is export { $a.add($b) }
multi sub infix:<+>(::?CLASS $a, Numeric $n  --> ::?CLASS:D ) is export { $a.add($n) }
multi sub infix:<+>(Numeric $n, ::?CLASS $a  --> ::?CLASS:D ) is export { $a.add($n) }
