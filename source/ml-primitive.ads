pragma License (GPL);
with Ada.Numerics.Generic_Elementary_Functions;
package ML.Primitive is
   --  Math functions for Real
   package ML_Elementary_Functions is new
      Ada.Numerics.Generic_Elementary_Functions (Real);

   procedure Add (a : in out Real_Array; b : Real_Array)
      with Pre => a'First in b'Range and a'Last in b'Range;
   procedure Sub (a : in out Real_Array; b : Real_Array);
   procedure Multiply (a : in out Real_Array; b : Real);
   procedure Divide (a : in out Real_Array; b : Real);
   function "*" (a : Real_Array; b : Real) return Real_Array;

   function Max (a : Real_Array; b : Index_Array) return Real with Inline;
   function Max (a : Real_Array) return Real with Inline;
   function Min (a : Real_Array; b : Index_Array) return Real with Inline;
   function Min (a : Real_Array) return Real with Inline;
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
   --------------------
   --  Distribution  --
   --------------------
   function Normal (x, m, s : Real) return Real with Inline;
   function Log_Normal (x, m, s : Real) return Real with Inline;

   -----------------
   --  Distances  --
   -----------------
   function Squared_Euclidean_Distance
      (a, b : Real_Array) return Real with Inline;

   function Euclidean_Distance (a, b : Real_Array) return Real with Inline;

   function Manhattan_Distance (a, b : Real_Array) return Real with Inline;

   function Sup_Distance (a, b : Real_Array) return Real with Inline;

   function Cosine_Distance (a, b : Real_Array) return Real with Inline;

   --  hamming_distance
   --  simple_matching_distance

end ML.Primitive;
