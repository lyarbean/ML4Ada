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

   ----------
   --  IO  --
   ----------
   package TIO renames Ada.Text_IO;
   package AF is new  TIO.Float_IO (Long_Float);
   package AE is new  TIO.Enumeration_IO (Cat_Type);

   -----------------
   --  Variables  --
   -----------------
   F_1 : My_Classifier;
   --  Accessable Variable_Type
   sl, sw, pl, pw : aliased Prioris.Long_Float_Variable;
   file : TIO.File_Type;
   s    : Cat_Type;
begin
   --  Setup
   F_1.F := (others => (others => new Prioris.Normal_Priori));

   --  Train
   TIO.Open
      (File => file, Mode => TIO.In_File, Name => "iris.tab");
   Train :
   while not TIO.End_Of_File (file) loop
      AF.Get (file, sl.V);
      AF.Get (file, sw.V);
      AF.Get (file, pl.V);
      AF.Get (file, pw.V);
      AE.Get (file, s);
      declare
         e : My_Event :=
            (Cell_Array'(sl'Access, sw'Access, pl'Access, pw'Access), s);
      begin
         F_1.Train (e);
      end;
   end loop Train;
   TIO.Close (file);

   --  Done
   F_1.Done;
   --  Predict

   TIO.Open
      (File => file, Mode => TIO.In_File, Name => "iris.tab");
   Predict :
   while not TIO.End_Of_File (file) loop
      AF.Get (file, sl.V);
      AF.Get (file, sw.V);
      AF.Get (file, pl.V);
      AF.Get (file, pw.V);
      AE.Get (file, s);
      declare
         e : My_Event :=
            (Cell_Array'(sl'Access, sw'Access, pl'Access, pw'Access), s);
      begin
         F_1.Predict (e);
         Ada.Text_IO.Put_Line (e.C'Img);
      end;
   end loop Predict;
   TIO.Close (file);
end Naivebayes_Driver;
