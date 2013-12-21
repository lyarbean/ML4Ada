with Ada.Finalization;
generic
   type Feature_Type is (<>);
   type Class_Type is (<>);
   type Feature_Array is array (Feature_Type) of Real;
   with function Length return Natural;
   with function Belong (x : Index_Type) return Class_Type;
   with function Element (x : Index_Type) return Feature_Array;
package ML.Classification.Naivebayes is
   type Object (d : Distribution_Type) is
      new Ada.Finalization.Limited_Controlled with private;
   procedure Train   (o : Object);
   procedure Put     (o : Object);
   procedure Predict (o : Object; x : Feature_Array);
   function  Predict (o : Object; x : Feature_Array) return Class_Type;

private
   type Matrix_Type is array (Class_Type, Feature_Type) of Real;
   type Matrix_Access is access Matrix_Type;
   type Priori_Type is array (Class_Type) of Integer;
   type Priori_Access is access Priori_Type;
   type Object (d : Distribution_Type) is
      new Ada.Finalization.Limited_Controlled with
      record
         Means   : Matrix_Access;
         SDs     : Matrix_Access;
         Priori  : Priori_Access;
      end record;
   overriding procedure Initialize (o : in out Object);
   overriding procedure Finalize   (o : in out Object);
end ML.Classification.Naivebayes;
