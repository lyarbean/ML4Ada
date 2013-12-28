with Ada.Strings.Unbounded;
with Ada.Containers.Vectors;
package ML.Classification.Types is
   -----------------------------
   --          f_1      f_2      f_3
   --    x1    x_1_1    x_1_2    x_1_3    c1
   --    x2    x_2_1    x_2_2    x_2_3    c2
   --    x3    x_3_1    x_3_2    x_3_3    c1
   --    x4    x_4_1    x_4_2    x_4_3    c3
   --                                  class
   --  x_i_j could be a string, integer, float or others, which is of
   --  Event_type and Xi is of Feature_Type
   --  Given a dataset, associated with a Feature_Type and  distribution list,
   --  we can create a list of Priori_Types to handle them.

   ----------------
   --  Abstract  --
   ----------------

   type Event_Type is interface;
   type Feature_Type is interface;

   function Event (f : Feature_Type'Class; j : Positive)
      return Event_Type'Class is abstract;

   type Priori_Type is interface;
   --  TODO A better name
   procedure See (p : in out Priori_Type'Class;
                  f : Feature_Type'Class;
                  j : Positive) is abstract;
   procedure Run (p : in out Priori_Type) is abstract;
   function Priori (p : Priori_Type'Class; e : Event_Type'Class)
      return Long_Float is abstract;

   ------------------
   --  Predefined  --
   ------------------

   -----------------
   -- Exceptions  --
   -----------------
   Mismatched_Event     : exception;
   Variables_Not_Enough : exception;

   -------------------
   --  Event_Types  --
   -------------------
   type String_Event is new Event_Type with record
      E : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   type Integer_Event is new Event_Type with record
      E : Integer;
   end record;

   type Float_Event is new Event_Type with record
      E : Float;
   end record;

   type Long_Float_Event is new Event_Type with record
      E : Long_Float;
   end record;

   --------------------
   --  Priori_Types  --
   --------------------
   package Long_Float_Vectors is
      new Ada.Containers.Vectors (Positive, Long_Float);
   type Normal_Priori (count : Positive) is new Priori_Type with record
      Mean : Long_Float;
      SD   : Long_Float;
      Variables : Long_Float_Vectors.Vector;
   end record;
   procedure See (np : in out Normal_Priori; e : Event_Type'Class);
   procedure Run (np : in out Normal_Priori);
   function Priori (np : Normal_Priori; e : Event_Type'Class)
      return Long_Float;

   --  type My_Feature is new Feature_Type with Record
   --     a : Integer;
   --     b : Float;
   --     c : String;
   --  end My_Feature;
   --  function Event (f : Feature_Type; j : integer) return Event_Type is
   --  begin
   --      case j is
   --      when 1 => return Float_Event '(a => f.a);
   --      ...
   --  end Event;
end ML.Classification.Types;
