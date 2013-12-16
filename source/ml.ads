pragma License (GPL);
with Ada.Containers.Indefinite_Vectors;
with Ada.Containers.Vectors;

package AI is
   type Real is new Long_Long_Float;
   subtype Index_Type is Positive;
   type Real_Array is array (Index_Type range <>) of Real;
   procedure Add (a : in out Real_Array; b : in Real_Array);
   procedure Sub (a : in out Real_Array; b : in Real_Array);
   procedure Multiply (a : in out Real_Array; b : in Real);
   procedure Divide (a : in out Real_Array; b : in Real);
   function "*" (a : Real_Array; b : Real) return Real_Array;
   type Real_Array_Access is access all Real_Array;
   type Index_Array is array (Index_Type range <>) of Index_Type;

   package Real_Array_Vector_Package is new
   Ada.Containers.Indefinite_Vectors (Index_Type, Real_Array);
   subtype Real_Array_Vector is Real_Array_Vector_Package.Vector;
   type Real_Array_Vector_Access is access all Real_Array_Vector'Class;
end AI;
