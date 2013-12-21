with ML.Clustering.Kmeans;
with Ada.Text_IO;
with Ada.Containers.Vectors;

procedure kmeans_driver3 is
   package AF is new  Ada.Text_IO.Float_IO (ML.Real);
   package TIO renames Ada.Text_IO;

   type My_Dim is (x, y);
   type My_Point is array (My_Dim) of ML.Real;
   package My_Vector is new  Ada.Containers.Vectors (Positive, My_Point);

   data : My_Vector.Vector;

   function Length return Natural;
   function Element (x : Positive) return My_Point;

   function Length return Natural is
   begin
      if data.Is_Empty then
         return 0;
      end if;
      return Natural (data.Length);
   end Length;

   function Element (x : Positive) return My_Point is
   begin
      return data.Element (x);
   end Element;

   package Kmeans is new ML.Clustering.Kmeans
      (My_Dim, My_Point, Length, Element);
   kmeans_obj : Kmeans.Object (3);

   file : TIO.File_Type;
      z : My_Point;
begin
   --  read from file m.t, two Real each line
   TIO.Open
      (File => file, Mode => TIO.In_File, Name => "m.t");
   Process :
   while not TIO.End_Of_File (file) loop
      AF.Get (file, z (x));
      AF.Get (file, z (y));
      data.Append (z);
   end loop Process;
exception
   when TIO.End_Error => null; --  In case of blank lines
   TIO.Close (file);
   Kmeans.Run (kmeans_obj, 1000);
   Kmeans.Put (kmeans_obj);
end kmeans_driver3;
