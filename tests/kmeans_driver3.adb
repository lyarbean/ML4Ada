with ML.Clustering.Kmeans;
with Ada.Text_IO;

procedure kmeans_driver3 is
   package AF is new  Ada.Text_IO.Float_IO (ML.Real);
   package TIO renames Ada.Text_IO;
   data : ML.Real_Array_Vector;
   --  Functions to access data
   function Length return Integer;
   function Element (x : ML.Index_Type) return ML.Real_Array;

   function Length return Integer is
   begin
      if data.Is_Empty then
         return 0;
      end if;
      return Integer (data.Length);
   end Length;

   function Element (x : ML.Index_Type) return ML.Real_Array is
   begin
      return data.Element (x);
   end Element;

   package Kmeans is new ML.Clustering.Kmeans (Length, Element);
   kmeans_obj : Kmeans.Object (3);

   file : TIO.File_Type;
   x, y : ML.Real;
begin
   --  read from file m.t, two Real each line
   TIO.Open
      (File => file, Mode => TIO.In_File, Name => "m.t");
   Process :
   while not TIO.End_Of_File (file) loop
      AF.Get (file, x);
      AF.Get (file, y);
      data.Append ((x, y));
   end loop Process;
exception
   when TIO.End_Error => null; --  In case of blank lines
   TIO.Close (file);
   Kmeans.Run (kmeans_obj, 1000);
   Kmeans.Put (kmeans_obj);
end kmeans_driver3;
