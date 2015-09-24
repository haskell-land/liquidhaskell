-- |   A first example in equalional reasoning.
-- |  From the definition of append we should be able to
-- |  semi-automatically prove the two axioms.

-- | Note for soundness we need
-- | totallity: all the cases should be covered
-- | termination: we cannot have diverging things into proofs

{-@ LIQUID "--totality"       @-}
{-@ LIQUID "--no-termination"  @-}

module Append where

import Language.Haskell.Liquid.Prelude

data L a = N |  C a (L a) deriving (Eq)


{-@ N :: {v:L a | llen v == 0 && v == N } @-}
{-@ C :: x:a -> xs:L a -> {v:L a | llen v == llen xs + 1 && v == C x xs } @-}

{-@ measure append :: L a -> L a -> L a @-}
{-@ assume append :: xs:L a -> ys:L a -> {v:L a | v == append xs ys } @-}

append :: L a -> L a -> L a
append N xs        = xs
append (C y ys) xs = C y (append ys xs)

{-@ data L [llen] @-}
{-@ invariant {v: L a | llen v >= 0} @-}

{-@ measure llen :: L a -> Int @-}
llen :: L a -> Int
llen N = 0
llen (C x xs) = 1 + llen xs


-- | All the followin will be autocatically generated by the definition of append
-- |  and a liquid annotation
-- |
-- |  axiomatize append
-- |

{-@ assume axiom_append_nil
    :: xs:L a -> Equal {append N xs} xs @-}
axiom_append_nil :: L a -> Proof
axiom_append_nil xs = Proof

{-@ assume axiom_append_cons
    :: x:a -> xs: L a -> ys: L a -> Equal {append (C x xs) ys} {C x (append xs ys)}
  @-}
axiom_append_cons :: a -> L a -> L a -> Proof
axiom_append_cons x xs ys = Proof

-- | Proof library:

data Proof = Proof

{-@ invariant {v:Proof | v == Proof }   @-}

{-@ type Equal X Y = {v:Proof | X == Y} @-}
{-@ type Refl X = Equal X X             @-}

{-@ bound chain @-}
chain :: (Proof -> Bool) -> (Proof -> Bool) -> (Proof -> Bool) -> Proof -> Bool
chain p q r = \ v -> p v ==> q v ==> r v


{-@  by :: forall <p :: Proof -> Prop, q :: Proof -> Prop, r :: Proof -> Prop>.
             (Chain p q r) => Proof<p> -> Proof<q> -> Proof<r>
@-}
by :: Proof -> Proof -> Proof
by _ r = r

{-@ refl :: x:a -> Refl x @-}
refl :: a -> Proof
refl x = Proof

{-@ prop_app_nil :: ys:L a -> {v:Proof | append N N == N } @-}
prop_app_nil N
  = axiom_append_nil N

{-
prop_app_nil (C x xs)
  = refl (append (C x xs) N)
                                      -- (C x xs) ++ N
      `by` (axiom_append_cons x xs N)
                                      -- == C x (xs ++ N)
      `by` (prop_app_nil xs)
                                      -- == C x xs
-}

{-
prop_app_nil (C x xs)
  = refl (append (C x xs) N)
                                      -- (C x xs) ++ N
      `by` (axiom_append_cons x xs N)
                                      -- == C x (xs ++ N)
      `by` (prop_app_nil xs)
                                      -- == C x xs

-}


{-@ toProof :: l:a -> r:{a|l = r} -> {v:Proof | l = r } @-}
toProof :: a -> a -> Proof
toProof x y = Proof


{-@ (===) :: l:a -> r:a -> {v:Proof | l = r} -> {v:a | v = l } @-}
(===) :: a -> a -> Proof -> a
(===) x y _ = y