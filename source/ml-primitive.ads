pragma License (GPL);
with Ada.Numerics.Generic_Elementary_Functions;
package ML.Primitive is
   --  Math functions for Real
   package Elementary_Functions is new
   Ada.Numerics.Generic_Elementary_Functions (Real);

   Index_mismatched : exception;

   function Max (a : Real_Array; b : Index_Array) return Real with inline;
   function Max (a : Real_Array) return Real with inline;
   function Min (a : Real_Array; b : Index_Array) return Real with inline;
   function Min (a : Real_Array) return Real with inline;
   ------------------
   --  Statistics  --
   ------------------

   function Sum (a : Real_Array) return Real;
   --  1st raw moment
   function Mean (a : Real_Array; b : Index_Array) return Real;
   function Mean (a : Real_Array) return Real;

   --  2nd central moment
   function Variance
      (a : Real_Array; b : Index_Array; Bessel : Boolean := True) return Real;
   function Variance (a : Real_Array; Bessel : Boolean := True) return Real;

   function Standard_Deviation (a : Real_Array; b : Index_Array) return Real;
   function Standard_Deviation (a : Real_Array) return Real;

   function Central_Moment
      (a : Real_Array; b : Index_Array; n : Positive) return Real;
   function Central_Moment (a : Real_Array; n : Positive) return Real;

   function Normalized_Moment
      (a : Real_Array; b : Index_Array; n : Positive) return Real;
   function Normalized_Moment (a : Real_Array; n : Positive) return Real;
   --  mode

   ---------------
   -- Distances --
   ---------------
   function Squared_Euclidean_Distance
      (a, b : Real_Array) return Real with inline;

   function Euclidean_Distance (a, b : Real_Array) return Real with inline;

   function Manhattan_Distance (a, b : Real_Array) return Real with inline;

   function Sup_Distance (a, b : Real_Array) return Real with inline;

   function Cosine_Distance (a, b : Real_Array) return Real with inline;

   --  hamming_distance
   --  simple_matching_distance

end ML.Primitive;
