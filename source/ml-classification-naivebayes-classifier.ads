generic
   type Feature_Type is (<>);
   type Class_Type is (<>);

package ML.Classification.Naivebayes.Classifier is

   type Priori_Array is
      array (Class_Type, Feature_Type) of access Priori_Type'Class;
   type Cell_Array is
      array (Feature_Type) of access Variable_Type'Class;

   type Score_Type is array (Class_Type) of Long_Float;

   type My_Event is new Event_Type with record
     E : Cell_Array := (others => null);
     C : Class_Type;
   end record;

   type My_Classifier is new Classifier_Type with record
      F : Priori_Array := (others => (others => null));
      P : Score_Type := (others => 0.0);  -- Apriori
   end record;
   overriding
   procedure Train
      (Classifier : in out My_Classifier; Event : Event_Type'Class);
   overriding
   procedure Done (Classifier : in out My_Classifier);
   overriding
   procedure Predict
      (Classifier : My_Classifier; Event : in out Event_Type'Class);

   procedure Predict (Classifier : My_Classifier;
      Event : in out Event_Type'Class; Score : out Score_Type);

   function Predict (Classifier : My_Classifier; Event : Event_Type'Class)
      return Score_Type;
end ML.Classification.Naivebayes.Classifier;
