{-# language
    TemplateHaskell
  , Rank2Types
  , ExistentialQuantification
  , ScopedTypeVariables
  , OverloadedStrings
  #-}

module Rasa.Internal.Editor
  (
  -- * Accessing/Storing state
  Editor
  , HasEditor(..)
  , buffers
  , exiting
  , BufRef(..)
  ) where

import Rasa.Internal.Buffer
import Rasa.Internal.Extensions

import Data.Default
import Data.IntMap
import qualified Data.Map as M
import Control.Lens
import Data.List

-- | This is the primary state of the editor.
data Editor = Editor
  { _buffers' :: IntMap Buffer
  , _exiting' :: Bool
  , _extState' :: ExtMap
  }
makeLenses ''Editor

instance Show Editor where
  show ed =
    "Buffers==============\n" ++ bufferText ++ "\n\n"
    ++ "Editor Extensions==============\n" ++ extText ++ "\n\n"
    ++ "---\n\n"
    where
      bufferText = intercalate "\n" $ zipWith ((++) . (++ ": ") .  show) [(1::Integer)..] (ed^..buffers.traverse.to show)
      extText = intercalate "\n" $ show <$> ed^.exts.to M.toList


-- | This allows polymorphic lenses over anything that has access to an Editor context
class HasEditor a where
  editor :: Lens' a Editor

-- | A lens over the map of available buffers
buffers :: HasEditor e => Lens' e (IntMap Buffer)
buffers = editor.buffers'

-- | A lens over the exiting status of the editor
exiting :: HasEditor e => Lens' e Bool
exiting = editor.exiting'

instance HasEditor Editor where
  editor = lens id (flip const)

instance HasExts Editor where
  exts = extState'

instance Default Editor where
  def =
    Editor
    { _extState'=def
    , _buffers'=empty
    , _exiting'=False
    }
