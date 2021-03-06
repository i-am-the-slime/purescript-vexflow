module Vex.VexFlowFFI 
--(
--   onload,
--   getElement,
--   createRendererSVG,
--   createRendererCanvas,
--   resize,
--   getContext,
--   formatAndDraw,

--   newStave,
--   addClef,
--   addKeySignature,
--   addTimeSignature,
--   setContextStave,
--   drawStave,

--   newStaveNote,
--   addAccidental,
--   addArticulation,
--   --addAnnotation,
--   addDot,
--   addDotToAll,

--   newVoice,
--   addTickable,
--   addTickables,
--   setContextVoice,
--   setStave,
--   drawVoice
-- ) 
where

import Prim.Row
import Effect
import Foreign
import Prelude
import Simple.JSON
import Vex.Types
import Vex.Builder

import Control.Monad.State (StateT(..))
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..))
import Effect.Console (log)


-- Abstract data types for dealing with JS objects
foreign import data VexContext    :: Type
foreign import data VexFormatter  :: Type
foreign import data VexRenderer   :: Type
foreign import data VexVoice      :: Type
foreign import data VexStaveNote  :: Type
foreign import data VexStave      :: Type
foreign import data VexBeam       :: Type


--Boilerplate functions
foreign import onload 
  :: forall a. Effect a -> Effect a

foreign import getElement 
  :: String -> Effect HTMLElement

foreign import createRendererSVG 
  :: HTMLElement -> Effect VexRenderer

foreign import createRendererCanvas 
  :: HTMLElement -> Effect VexRenderer

foreign import resize 
  :: Foreign -> VexRenderer -> Effect VexRenderer


--Formatter functions#
foreign import newFormatter
  :: Effect VexFormatter

foreign import format
  :: Array VexVoice -> Number -> VexFormatter -> Effect VexFormatter

-- foreign import formatToStave
--   :: Array VexVoice -> VexStave -> VexFormatter -> Effect VexFormatter

foreign import formatAndDraw
  :: VexContext -> VexStave -> Array VexStaveNote -> Effect Unit

foreign import joinVoices
  :: Array VexVoice -> VexFormatter -> Effect VexFormatter

foreign import getContextRenderer 
  :: VexRenderer -> Effect VexContext


--Stave functions
foreign import newStave
  :: Foreign -> Effect VexStave

foreign import addClef
  :: Foreign -> VexStave -> Effect VexStave

foreign import addKeySignature
  :: Foreign -> VexStave -> Effect VexStave

foreign import addTimeSignature
  :: Foreign -> VexStave -> Effect VexStave

foreign import getContextStave
  :: VexStave -> Effect VexContext

foreign import setContextStave
  :: VexContext -> VexStave -> Effect VexStave

foreign import drawStave
  :: VexStave -> Effect Unit


--StaveNote functions
foreign import newStaveNote
  :: Foreign -> Effect VexStaveNote

foreign import addAccidental
  :: Int -> Foreign -> VexStaveNote -> Effect VexStaveNote

foreign import addArticulation
  :: Int -> Foreign -> VexStaveNote -> Effect VexStaveNote

-- foreign import addAnnotation
--   :: forall annotation
--    . AswriteImpl Annotation annotation
--   => Int -> annotation -> VexStaveNote -> Effect VexStaveNote

foreign import addDot :: Int -> VexStaveNote -> Effect VexStaveNote

foreign import addDotToAll :: VexStaveNote -> Effect VexStaveNote


--Voice function
foreign import newVoice
  :: Foreign -> Effect VexVoice

foreign import addTickable
  :: VexStaveNote -> VexVoice -> Effect VexVoice

foreign import addTickables
  :: Array VexStaveNote -> VexVoice -> Effect VexVoice

foreign import getContextVoice
 :: VexVoice -> Effect VexContext

foreign import setContextVoice
  :: VexContext -> VexVoice -> Effect VexVoice

foreign import getStaveVoice
  :: VexVoice -> Effect VexStave

foreign import setStaveVoice
  :: VexStave -> VexVoice -> Effect VexVoice

foreign import drawVoice
  :: VexVoice -> Effect Unit


--Beam functions
foreign import newBeam
  :: Array VexStaveNote -> Effect VexBeam

foreign import getContextBeam
 :: VexBeam -> Effect VexContext

foreign import setContextBeam
  :: VexContext -> VexBeam -> Effect VexBeam

foreign import generateBeams
  :: Array VexStaveNote -> Effect (Array VexBeam)

foreign import drawBeam
  :: VexBeam -> Effect Unit


--Class Functions
class GetContext v where
  getContext
    :: forall s 
     . Builder (HasContext s) v -> Effect VexContext

class SetContext v where
  setContext
    :: forall s1 s2
     . Nub (HasContext s1) s2
     => VexContext -> BuildStep s1 s2 v

class GetStave v where
  getStave
    :: forall s
     . Builder (HasStave s) v -> Effect VexStave

class SetStave v where
  setStave
    :: forall s1 s2 vexStave
     . Nub (HasStave s1) s2
     => Buildable vexStave VexStave
     => vexStave -> BuildStep s1 s2 v

--Instances for vextypes
--  Voice instances
instance getContextVexVoice :: GetContext VexVoice where
  getContext = getContextVoice <<< build
instance setContextVexVoice :: SetContext VexVoice where
  setContext ctx voice = Builder <$> setContextVoice ctx (build voice)
instance getStaveVexVoice :: GetStave VexVoice where
  getStave = getStaveVoice <<< build
instance setStaveVexVoice :: SetStave VexVoice where
  setStave stave voice = Builder <$> setStaveVoice (build stave) (build voice)

--  Stave instances
instance getContextVexStave :: GetContext VexStave where
  getContext = getContextStave <<< build
instance setContextVexStave :: SetContext VexStave where
  setContext ctx stave = Builder <$> setContextStave ctx (build stave)

--  Renderer instances
instance getContextVexRenderer :: GetContext VexRenderer where
  getContext = getContextRenderer <<< build

--  Beams instances
instance getContextVexBeam :: GetContext VexBeam where
  getContext = getContextBeam <<< build
instance setContextVexBeam :: SetContext VexBeam where
  setContext ctx beam = Builder <$> setContextBeam ctx (build beam)