Martin Escardo 29 April 2014.

\begin{code}

{-# OPTIONS --without-K --exact-split --safe #-}

open import SpartanMLTT
open import UF-FunExt
open import UF-Embedding

module ExtendedSumSearchable (fe : ∀ U V → funext U V) where

open import SearchableTypes
open import UF-InjectiveTypes (fe)
open import PropTychonoff (fe)

extended-sum-searchable : ∀ {U V W} {X : U ̇} {K : V ̇} {Y : X → W ̇} (j : X → K) → is-embedding j
                        → ((x : X) → searchable(Y x)) → searchable K → searchable(Σ(Y / j))
extended-sum-searchable j e ε δ = sums-preserve-searchability δ (λ k → prop-tychonoff (e k) (ε ∘ pr₁))

\end{code}
