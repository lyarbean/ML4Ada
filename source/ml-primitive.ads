pragma License (GPL);
with Ada.Numerics.Generic_Elementary_Functions;

generic
   type Scalar_Type is digits <>;
   type Index_Type is (<>);
   type Element_Type is array (Index_Type) of Scalar_Type;
package ML.Primitive is
   package GEF is new Ada.Numerics.Generic_Elementary_Functions (Scalar_Type);

   procedure Add (a : in out Element_Type; b : Element_Type) with Inline;
   procedure Sub (a : in out Element_Type; b : Element_Type) with Inline;
   procedure Multiply (a : in out Element_Type; b : Scalar_Type);
   procedure Divide (a : in out Element_Type; b : Scalar_Type) with Inline;
   function "*" (a : Element_Type; b : Scalar_Type)
      return Element_Type with Inline;
   function Max (a : Element_Type) return Scalar_Type with Inline;
   function Min (a : Element_Type) return Scalar_Type with Inline;
   ------------------
   --  Statistics  --
   ------------------

   function Sum (a : Element_Type) return Scalar_Type;
   --  1st raw moment
   function Mean (a : Element_Type) return Scalar_Type;

   --  2nd central moment
   function Variance (a : Element_Type; Bessel : Boolean := True)
      return Scalar_Type;

   function Standard_Deviation (a : Element_Type) return Scalar_Type;

   function Central_Moment (a : Element_Type; n : Positive) return Scalar_Type;

   function Normalized_Moment (a : Element_Type; n : Positive)
      return Scalar_Type;
   --  mode

   --  TODO Migrate
   --------------------
   --  Distribution  --
   --------------------
   function Normal (x, m, s : Scalar_Type) return Scalar_Type with Inline;
   function Log_Normal (x, m, s : Scalar_Type) return Scalar_Type with Inline;

   -----------------
   --  Distances  --
   -----------------
   function Squared_Euclidean_Distance
      (a, b : Element_Type) return Scalar_Type with Inline;

   --  function Euclidean_Distance (a, b : Element_Type)
   --     return Scalar_Type with Inline;

   function Manhattan_Distance (a, b : Element_Type)
      return Scalar_Type with Inline;

   function Sup_Distance (a, b : Element_Type) return Scalar_Type with Inline;

   function Cosine_Distance (a, b : Element_Type)
      return Scalar_Type with Inline;

   --  hamming_distance
   --  simple_matching_distance

end ML.Primitive;
