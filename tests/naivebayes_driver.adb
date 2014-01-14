pragma Ada_2012;
with Ada.Text_IO;
with ML.Classification.Naivebayes.Classifier;
with ML.Classification.Naivebayes.Prioris;
procedure Naivebayes_Driver is
   use ML.Classification.Naivebayes;
   type Dim_Type is (Sepal_Length, Sepal_Width, Petal_Length, Petal_Width);
   type Cat_Type is (Setosa, Versicolor, Virginica);
   package IRIS is new Classifier (Dim_Type, Cat_type);
   use IRIS;

   package TIO renames Ada.Text_IO;
   package AF is new  Ada.Text_IO.Float_IO (Long_Float);
   package AE is new  Ada.Text_IO.Enumeration_IO (Cat_Type);

   function To (SL, SW, PL, PW : Long_Float) return Cell_Array;
   function To (SL, SW, PL, PW : Long_Float) return Cell_Array is
   begin
      return Cell_Array'(
         new Prioris.Long_Float_Variable'(V => SL),
         new Prioris.Long_Float_Variable'(V => SW),
         new Prioris.Long_Float_Variable'(V => PL),
         new Prioris.Long_Float_Variable'(V => PW));
   end To;

   F_1 : My_Feature;
   sl, sw, pl, pw : Long_Float;

   file : TIO.File_Type;
   s    : Cat_Type;

   E_1 : My_Event := (To (6.2, 3.4, 5.4, 2.3), Setosa); --  was Virginica);
   E_2 : My_Event := (To (5.9, 3.0, 5.1, 1.8), Versicolor); --  was Virginica);
begin
   -- Setup
   F_1.F := (others => (others => new Prioris.Normal_Priori));
   
   --  Train
   TIO.Open
      (File => file, Mode => TIO.In_File, Name => "iris.tab");
   Process :
   while not TIO.End_Of_File (file) loop
      AF.Get (file, sl);
      AF.Get (file, sw);
      AF.Get (file, pl);
      AF.Get (file, pw);
      AE.Get (file, s);
      F_1.Train (My_Event'(To (sl, sw, pl, pw), s));
   end loop Process;
   TIO.Close (file);
   --  Done
   F_1.Done;
   --  Predict
   F_1.Predict (E_1);
   F_1.Predict (E_2);
   Ada.Text_IO.Put_Line (E_1.C'Img);
   Ada.Text_IO.Put_Line (E_2.C'Img);
end Naivebayes_Driver;
