with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
package ML.Classification.Naivebayes is
   -----------------------------
   --          f_1      f_2      f_3
   --    x1    x_1_1    x_1_2    x_1_3    c1
   --    x2    x_2_1    x_2_2    x_2_3    c2
   --    x3    x_3_1    x_3_2    x_3_3    c1
   --    x4    x_4_1    x_4_2    x_4_3    c3
   --                                  class
   ----------------
   --  Abstract  --
   ----------------
   type Event_Type is interface;
   type Feature_Type is interface;

   procedure Train
      (Feature : in out Feature_Type; Event : Event_Type'Class) is abstract;
   procedure Done
      (Feature : in out Feature_Type) is abstract;
   procedure Predict
      (Feature : Feature_Type; Event : in out Event_Type'Class) is abstract;

   type Variable_Type is interface;
   type Priori_Type is interface;

   function Priori
      (Priori : Priori_Type; Variable : Variable_Type'Class)
      return Long_Float is abstract;
   procedure Handle
      (Priori : in out Priori_Type; Variable : Variable_Type'Class) is abstract;
   procedure Done (Priori : in out Priori_Type) is abstract;
   -----------------
   -- Exceptions  --
   -----------------
   Mismatched_Event     : exception;
   Mismatched_Variable  : exception;
   Variables_Not_Enough : exception;
end ML.Classification.Naivebayes;
