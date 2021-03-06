Martin Escardo, started 5th May 2018

\begin{code}

module NaturalsOrder where

open import SpartanMLTT hiding (_≤_) hiding (≤-anti) public

_≤_ : ℕ → ℕ → U₀ ̇
zero ≤ n        = 𝟙
succ m ≤ zero   = 𝟘
succ m ≤ succ n = m ≤ n

zero-minimal : (n : ℕ) → zero ≤ n
zero-minimal n = *

succ-monotone : (m n : ℕ) → m ≤ n → succ m ≤ succ n
succ-monotone m n l = l

succ-order-injective : (m n : ℕ) → succ m ≤ succ n → m ≤ n 
succ-order-injective m n l = l

succ≤≡ : (m n : ℕ) → (succ m ≤ succ n) ≡ (m ≤ n)
succ≤≡ m n = refl

≤-induction : {U : Universe} (P : (m n : ℕ) (l : m ≤ n) → U ̇)
            → ((n : ℕ) → P zero n (zero-minimal n))
            → ((m n : ℕ) (l : m ≤ n) → P m n l → P (succ m) (succ n) (succ-monotone m n l)) 
            → (m n : ℕ) (l : m ≤ n) → P m n l 
≤-induction P base step zero n *            = base n
≤-induction P base step (succ m) zero ()
≤-induction P base step (succ m) (succ n) l = step m n l (≤-induction P base step m n l)

≤-refl : (n : ℕ) → n ≤ n
≤-refl zero     = *
≤-refl (succ n) = ≤-refl n

≤-trans : (l m n : ℕ) → l ≤ m → m ≤ n → l ≤ n
≤-trans zero m n p q = *
≤-trans (succ l) zero n () q
≤-trans (succ l) (succ m) zero p ()
≤-trans (succ l) (succ m) (succ n) p q = ≤-trans l m n p q

≤-anti : (m n : ℕ) → m ≤ n → n ≤ m → m ≡ n
≤-anti zero zero p q = refl
≤-anti zero (succ n) p ()
≤-anti (succ m) zero () q
≤-anti (succ m) (succ n) p q = ap succ (≤-anti m n p q)

≤-succ : (n : ℕ) → n ≤ succ n
≤-succ zero     = *
≤-succ (succ n) = ≤-succ n

unique-minimal : (n : ℕ) → n ≤ zero → n ≡ zero
unique-minimal zero l = refl
unique-minimal (succ n) ()

≤-split : (m n : ℕ) → m ≤ succ n → (m ≤ n) + (m ≡ succ n)
≤-split zero n l = inl l
≤-split (succ m) zero l = inr (ap succ (unique-minimal m l))
≤-split (succ m) (succ n) l = cases inl (inr ∘ (ap succ)) (≤-split m n l)

≤-join : (m n : ℕ) → (m ≤ n) + (m ≡ succ n) → m ≤ succ n
≤-join m n (inl l) = ≤-trans m n (succ n) l (≤-succ n)
≤-join .(succ n) n (inr refl) = ≤-refl n

_<_ : ℕ → ℕ → U₀ ̇
m < n = succ m ≤ n

not-less-bigger-or-equal : (m n : ℕ) → ¬(n < m) → m ≤ n
not-less-bigger-or-equal zero n u = zero-minimal n
not-less-bigger-or-equal (succ m) zero = double-negation-intro (zero-minimal m)
not-less-bigger-or-equal (succ m) (succ n) = not-less-bigger-or-equal m n

bounded-∀-next : ∀ {U} (A : ℕ → U ̇) (k : ℕ)
        → A k
        → ((n : ℕ) → n < k → A n)
        → (n : ℕ) → n < succ k → A n
bounded-∀-next A k a φ n l = cases f g s
 where
  s : (n < k) + (succ n ≡ succ k)
  s = ≤-split (succ n) k l
  f : n < k → A n
  f = φ n
  g : succ n ≡ succ k → A n
  g p = back-transport A (succ-injective p) a
  
\end{code}

Added 20th June 2018:

\begin{code}

open import UF-Subsingletons
open import Ordinals hiding (_≤_) hiding (<-gives-≤) hiding (≤-refl)

<-is-prop-valued : (m n : ℕ) → is-prop(m < n)
<-is-prop-valued zero     zero     = 𝟘-is-prop
<-is-prop-valued zero    (succ n)  = 𝟙-is-prop
<-is-prop-valued (succ m) zero     = 𝟘-is-prop
<-is-prop-valued (succ m) (succ n) = <-is-prop-valued m n

<-gives-≤ : (m n : ℕ) → m < n → m ≤ n
<-gives-≤ m n = ≤-trans m (succ m) n (≤-succ m)

<-trans : (l m n : ℕ) → l < m → m < n → l < n
<-trans l m n u v = ≤-trans (succ l) m n u (<-gives-≤ m n v)

<-split : (m n : ℕ) → m < succ n → (m < n) + (m ≡ n)
<-split m zero     l = inr (unique-minimal m l)
<-split m (succ n) l = ≤-split m n l

regress : ∀ {U} (P : ℕ → U ̇)
        → ((n : ℕ) → P (succ n) → P n)
        → (n : ℕ) (m : ℕ) → m ≤ n → P n → P m
regress P ρ zero m l p = back-transport P (unique-minimal m l) p
regress P ρ (succ n) m l p = cases (λ (l' : m ≤ n) → IH m l' (ρ n p))
                                    (λ (r : m ≡ succ n) → back-transport P r p) 
                                    (≤-split m n l)
 where
  IH : (m : ℕ) → m ≤ n → P n → P m
  IH = regress P ρ n 

<-is-well-founded : (m : ℕ) → is-accessible _<_ m
<-is-well-founded zero     = next zero     (λ y l → unique-from-𝟘 l)
<-is-well-founded (succ m) = next (succ m) (τ (<-is-well-founded m))
 where
  τ : is-accessible _<_ m → (n : ℕ) → n < succ m → is-accessible _<_ n
  τ a n u = cases (λ (v : n < m) → prev _<_ m a n v)
                  (λ (p : n ≡ m) → back-transport (is-accessible _<_) p a)
                  (<-split n m u)

course-of-values-induction : ∀ {U} (P : ℕ → U ̇)
                           → ((n : ℕ) → ((m : ℕ) → m < n → P m) → P n)
                           → (n : ℕ) → P n
course-of-values-induction = transfinite-induction _<_ <-is-well-founded

<-is-extensional : is-extensional _<_
<-is-extensional zero     zero     f g = refl
<-is-extensional zero     (succ n) f g = unique-from-𝟘 (g zero (zero-minimal n))
<-is-extensional (succ m) (zero)   f g = unique-from-𝟘 (f zero (zero-minimal m))
<-is-extensional (succ m) (succ n) f g = ap succ (≤-anti m n (f m (≤-refl m)) (g n (≤-refl n)))

ℕ-is-ordinal : is-ordinal _<_
ℕ-is-ordinal = <-is-prop-valued , <-is-well-founded , <-is-extensional , <-trans

\end{code}
