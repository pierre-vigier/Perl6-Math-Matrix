use v6.c;

unit role Math::Matrix::Operators;


multi sub infix:<+>(::?CLASS $a, ::?CLASS $b --> ::?CLASS:D ) is export {
    $a.add($b);
}

multi sub infix:<+>(::?CLASS $a, Real $r --> ::?CLASS:D ) is export {
    $a.add( $r );
}
multi sub infix:<+>(Real $r, ::?CLASS $a --> ::?CLASS:D ) is export {
    $a.add( $r );
}

