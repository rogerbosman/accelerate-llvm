{-# LANGUAGE GADTs               #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
-- |
-- Module      : Data.Array.Accelerate.LLVM.PTX.Foreign
-- Copyright   : [2016] Trevor L. McDonell
-- License     : BSD3
--
-- Maintainer  : Trevor L. McDonell <tmcdonell@cse.unsw.edu.au>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)
--

module Data.Array.Accelerate.LLVM.PTX.Foreign (

  -- Foreign functions
  ForeignAcc(..),
  ForeignExp(..),

  -- useful re-exports
  PTX,
  liftIO,

) where

import qualified Data.Array.Accelerate.Array.Sugar                  as S

import Data.Array.Accelerate.LLVM.State
import Data.Array.Accelerate.LLVM.CodeGen.Sugar

import Data.Array.Accelerate.LLVM.Foreign
import Data.Array.Accelerate.LLVM.PTX.Target                        ( PTX )
import Data.Array.Accelerate.LLVM.PTX.Execute.Async                 ( Stream )

import Control.Monad.State
import Data.Typeable


instance Foreign PTX where
  foreignAcc _ (ff :: asm (a -> b))
    | Just (ForeignAcc _ asm :: ForeignAcc (a -> b)) <- cast ff = Just asm
    | otherwise                                                 = Nothing

  foreignExp _ (ff :: asm (x -> y))
    | Just (ForeignExp _ asm :: ForeignExp (x -> y)) <- cast ff = Just asm
    | otherwise                                                 = Nothing

instance S.Foreign ForeignAcc where
  strForeign (ForeignAcc s _) = s

instance S.Foreign ForeignExp where
  strForeign (ForeignExp s _) = s


-- Foreign functions in the PTX backend.
--
data ForeignAcc f where
  ForeignAcc :: String
             -> (Stream -> a -> LLVM PTX b)
             -> ForeignAcc (a -> b)

-- Foreign expressions in the PTX backend.
--
data ForeignExp f where
  ForeignExp :: String
             -> IRFun1 PTX () (x -> y)
             -> ForeignExp (x -> y)

