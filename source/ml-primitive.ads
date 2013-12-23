pragma License (GPL);
with Ada.Numerics.Generic_Elementary_Functions;

generic
   type Scalar_Type is digits <>;
package ML.Primitive is
   package GEF is new Ada.Numerics.Generic_Elementary_Functions (Scalar_Type);
   --------------------
   --  Distribution  --
   --------------------
   function Normal (x, m, s : Scalar_Type) return Scalar_Type with Inline;
   function Log_Normal (x, m, s : Scalar_Type) return Scalar_Type with Inline;
end ML.Primitive;
