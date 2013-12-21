with ML.Classification.Naivebayes;
with Ada.Containers.Vectors;
with Ada.Text_IO;
procedure naivebayes_driver is
   package AF is new  Ada.Text_IO.Float_IO (ML.Real);
   package TIO renames Ada.Text_IO;
   type My_Feature is (Sepal_Length, Sepal_Width, Petal_Length, Petal_Width);
   type My_Class is (Setosa, Versicolor, Virginica);
   type My_Array is array (My_Feature) of ML.Real;
   package My_Array_Vector_Package is new
   Ada.Containers.Vectors (ML.Index_Type, My_Array);
   use My_Array_Vector_Package;

   data : Vector;

   function Length return Natural;
   function Element (x : ML.Index_Type) return My_Array;
   function Belong (x : ML.Index_Type) return My_Class;

   function Length return Natural is
   begin
      if data.Is_Empty then
         return 0;
      end if;
      return Natural (data.Length);
   end Length;

   function Element (x : ML.Index_Type) return My_Array is
   begin
      return My_Array '(data.Element (x));
   end Element;

   function Belong (x : ML.Index_Type) return My_Class is
      use ML;
   begin
      if x <= 50 then
         return Setosa;
      end if;
      if x > 100 then
         return Virginica;
      end if;
      return Versicolor;
   end Belong;

   package NB is new ML.Classification.Naivebayes
      (My_Feature, My_Class, My_Array, Length, Belong, Element);

   NB_Obj : NB.Object;
   file : TIO.File_Type;
   f : My_Array;
   x : ML.Real;
begin
   TIO.Open
      (File => file, Mode => TIO.In_File, Name => "iris.t");
   Process :
   while not TIO.End_Of_File (file) loop
      for c in My_Feature loop
         AF.Get (file, x);
         f (c) := x;
      end loop;
      data.Append (f);
   end loop Process;
   TIO.Close (file);
   NB_Obj.Train;
   NB_Obj.Put;
   NB_Obj.Predict (Element (52));
   NB_Obj.Predict (Element (52), ML.Log_Normal);
   TIO.New_Line;
   for c of data loop
      TIO.Put (NB_Obj.Predict (c)'Img & "   ");
   end loop;
exception
   when TIO.End_Error => null; --  In case of blank lines
end naivebayes_driver;
