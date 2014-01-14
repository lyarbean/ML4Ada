generic
   type Feature_Dim is (<>);
   type Class_Type is (<>);

package ML.Classification.Naivebayes.Classifier is

   type Priori_Array is
      array (Class_Type, Feature_Dim) of access Priori_Type'Class;
   type Cell_Array is
      array (Feature_Dim) of access Variable_Type'Class;

   type Score_Type is array (Class_Type) of Long_Float;
   --  TODO Resources Management for these accesses
   --  TODO My_Event should finalize all in E
   type My_Event is new Event_Type with record
     E : Cell_Array := (others => null);
     C : Class_Type;
   end record;

   --  TODO My_Event should finalize all in F
   type My_Feature is new Feature_Type with record
      F : Priori_Array := (others => (others => null));
      P : Score_Type := (others => 0.0);  -- Apriori
   end record;
   overriding
   procedure Train (Feature : in out My_Feature; Event : Event_Type'Class);
   overriding
   procedure Done (Feature : in out My_Feature);
   overriding
   procedure Predict (Feature : My_Feature; Event : in out Event_Type'Class);

end ML.Classification.Naivebayes.Classifier;
