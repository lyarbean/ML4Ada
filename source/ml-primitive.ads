pragma License (GPL);
with Ada.Numerics.Generic_Elementary_Functions;

generic
   type Index_Type is (<>);
   type Element_Type is array (Index_Type) of Real;
package ML.Primitive is
   --  Math functions for Real
   package GEF is new Ada.Numerics.Generic_Elementary_Functions (Real);

   procedure Add (a : in out Element_Type; b : Element_Type);
   procedure Sub (a : in out Element_Type; b : Element_Type);
   procedure Multiply (a : in out Element_Type; b : Real);
   procedure Divide (a : in out Element_Type; b : Real);
   function "*" (a : Element_Type; b : Real) return Element_Type;

   function Max (a : Element_Type) return Real with Inline;
   function Min (a : Element_Type) return Real with Inline;
   ------------------
   --  Statistics  --
   ------------------

   function Sum (a : Element_Type) return Real;
   --  1st raw moment
   function Mean (a : Element_Type) return Real;

   --  2nd central moment
   function Variance (a : Element_Type; Bessel : Boolean := True) return Real;

   function Standard_Deviation (a : Element_Type) return Real;

   function Central_Moment (a : Element_Type; n : Positive) return Real;

   function Normalized_Moment (a : Element_Type; n : Positive) return Real;
   --  mode

   --  TODO Migrate
   --------------------
   --  Distribution  --
   --------------------
   function Normal (x, m, s : Real) return Real with Inline;
   function Log_Normal (x, m, s : Real) return Real with Inline;

   -----------------
   --  Distances  --
   -----------------
   function Squared_Euclidean_Distance
      (a, b : Element_Type) return Real with Inline;

   --  function Euclidean_Distance (a, b : Element_Type)
   --     return Real with Inline;

   function Manhattan_Distance (a, b : Element_Type) return Real with Inline;

   function Sup_Distance (a, b : Element_Type) return Real with Inline;

   function Cosine_Distance (a, b : Element_Type) return Real with Inline;

   --  hamming_distance
   --  simple_matching_distance

end ML.Primitive;
