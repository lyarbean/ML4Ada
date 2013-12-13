pragma License (GPL);
with Ada.Numerics.Generic_Elementary_Functions;
package AI.Primitive is
   type Real is new Long_Long_Float;
   type Index is new Integer;
   type Real_Array is array (Index range <>) of Real;
   type Index_Array is array (Index range <>) of Index;

   --  Math functions for Real
   package Elementary_Functions is new
   ada.numerics.generic_elementary_functions (Real);

   Index_mismatched : exception;

   function max (a : Real_Array; b : Index_Array) return Real with inline;
   function max (a : Real_Array) return Real with inline;
   function min (a : Real_Array; b : Index_Array) return Real with inline;
   function min (a : Real_Array) return Real with inline;
   ------------------
   --  Statistics  --
   ------------------

   --  1st raw moment
   function mean (a : Real_Array; b : Index_Array) return Real;
   function mean (a : Real_Array) return Real;

   --  2nd central moment
   function variance (a : Real_Array; b : Index_Array) return Real;
   function variance (a : Real_Array) return Real;

   function standard_deviation (a : Real_Array; b : Index_Array) return Real;
   function standard_deviation (a : Real_Array) return Real;

   function central_moment
      (a : Real_Array; b : Index_Array; n : Positive) return Real;
   function central_moment (a : Real_Array; n : Positive) return Real;

   function normalized_moment
      (a : Real_Array; b : Index_Array; n : Positive) return Real;
   function normalized_moment (a : Real_Array; n : Positive) return Real;
   --  mode

   ---------------
   -- Distances --
   ---------------
   function squared_euclidean_distance
      (a, b : Real_Array) return Real with inline;

   function euclidean_distance (a, b : Real_Array) return Real with inline;

   function manhattan_distance (a, b : Real_Array) return Real with inline;

   function sup_distance (a, b : Real_Array) return Real with inline;

   function cosine_distance (a, b : Real_Array) return Real with inline;

   --  hamming_distance
   --  simple_matching_distance

end AI.Primitive;
