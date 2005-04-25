-- -*-haskell-*-
--  GIMP Toolkit (GTK) GObject Properties
--
--  Author : Duncan Coutts
--
--  Created: 16 April 2005
--
--  Version $Revision: 1.1 $ from $Date: 2005/04/19 02:21:27 $
--
--  Copyright (C) 2005 Duncan Coutts
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2.1 of the License, or (at your option) any later version.
--
--  This library is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Lesser General Public License for more details.
--
-- |
-- Maintainer  : gtk2hs-users@lists.sourceforge.net
-- Stability   : provisional
-- Portability : portable (depends on GHC)
--
-- Functions for getting and setting GObject properties
--
module System.Glib.Properties (
  objectSetPropertyInt,
  objectGetPropertyInt,
  objectSetPropertyBool,
  objectGetPropertyBool,
  objectSetPropertyEnum,
  objectGetPropertyEnum,
--  objectSetPropertyFlags,
--  objectGetPropertyFlags,
  objectSetPropertyFloat,
  objectGetPropertyFloat,
  objectSetPropertyDouble,
  objectGetPropertyDouble,
  
  objectSetPropertyInternal,
  objectGetPropertyInternal,
  ) where

import Monad (liftM)

import System.Glib.FFI
import System.Glib.UTFString
{#import System.Glib.Types#}
{#import System.Glib.GValue#}	(GValue(GValue), valueInit, allocaGValue)
import System.Glib.GObject	(makeNewGObject)
import System.Glib.GValueTypes

{# context lib="glib" prefix="g" #}

objectSetPropertyInternal :: GObjectClass gobj => (GValue -> a -> IO ()) -> String -> gobj -> a -> IO ()
objectSetPropertyInternal valueSet prop obj val =
  withUTFString prop $ \propPtr ->
  allocaGValue  $ \gvalue -> do
  valueSet gvalue val
  {# call unsafe g_object_set_property #}
    (toGObject obj)
    propPtr
    gvalue

objectGetPropertyInternal :: GObjectClass gobj => (GValue -> IO a) -> String -> gobj -> IO a
objectGetPropertyInternal valueGet prop obj =
  withUTFString prop $ \propPtr ->
  allocaGValue $ \gvalue -> do
  {# call unsafe g_object_get_property #}
    (toGObject obj)
    propPtr
    gvalue
  valueGet gvalue

objectSetPropertyInt :: GObjectClass gobj => String -> gobj -> Int -> IO ()
objectSetPropertyInt = objectSetPropertyInternal valueSetInt

objectGetPropertyInt :: GObjectClass gobj => String -> gobj -> IO Int
objectGetPropertyInt = objectGetPropertyInternal valueGetInt

objectSetPropertyBool :: GObjectClass gobj => String -> gobj -> Bool -> IO ()
objectSetPropertyBool = objectSetPropertyInternal valueSetBool

objectGetPropertyBool :: GObjectClass gobj => String -> gobj -> IO Bool
objectGetPropertyBool = objectGetPropertyInternal valueGetBool

objectSetPropertyEnum :: (GObjectClass gobj, Enum enum) => String -> gobj -> enum -> IO ()
objectSetPropertyEnum = objectSetPropertyInternal (\gv v -> valueSetInt gv (fromEnum v))

objectGetPropertyEnum :: (GObjectClass gobj, Enum enum) => String -> gobj -> IO enum
objectGetPropertyEnum = objectGetPropertyInternal (\gv -> liftM toEnum $ valueGetInt gv)

--objectSetPropertyFlags :: (GObjectClass gobj, Flags flags) => String -> gobj -> flags -> IO ()
--objectSetPropertyFlags = objectSetPropertyInternal valueSetInt

--objectGetPropertyFlags :: (GObjectClass gobj, Flags flags) => String -> gobj -> IO flags
--objectGetPropertyFlags = objectGetPropertyInternal valueGetInt

objectSetPropertyFloat :: GObjectClass gobj => String -> gobj -> Float -> IO ()
objectSetPropertyFloat = objectSetPropertyInternal valueSetFloat

objectGetPropertyFloat :: GObjectClass gobj => String -> gobj -> IO Float
objectGetPropertyFloat = objectGetPropertyInternal valueGetFloat

objectSetPropertyDouble :: GObjectClass gobj => String -> gobj -> Double -> IO ()
objectSetPropertyDouble = objectSetPropertyInternal valueSetDouble

objectGetPropertyDouble :: GObjectClass gobj => String -> gobj -> IO Double
objectGetPropertyDouble = objectGetPropertyInternal valueGetDouble

{-
objectSetProperty :: GObjectClass gobj => String -> gobj -> Int -> IO ()
objectSetProperty = objectSetPropertyInternal valueSet

objectGetProperty :: GObjectClass gobj => String -> gobj -> IO Int
objectGetProperty = objectGetPropertyInternal valueGet
-}

objectSetPropertyGObject :: (GObjectClass gobj, GObjectClass gobj') => String -> gobj -> gobj' -> IO ()
objectSetPropertyGObject = objectSetPropertyInternal valueSetGObject

objectGetPropertyGObject :: (GObjectClass gobj, GObjectClass gobj') => String -> gobj -> IO gobj'
objectGetPropertyGObject = objectGetPropertyInternal valueGetGObject