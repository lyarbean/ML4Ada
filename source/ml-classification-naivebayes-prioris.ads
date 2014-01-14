with Ada.Unchecked_Deallocation;
package ML.Classification.Naivebayes.Prioris is
   ---------------------
   --  Normal Priori  --
   ---------------------
   type Long_Float_Variable is new Variable_Type with
      record
         V : Long_Float := 0.0;
      end record;

   package Long_Float_Vectors is
      new Ada.Containers.Vectors (Positive, Long_Float);

   type Normal_Priori is new Priori_Type with record
      Mean : Long_Float := 0.0;
      SD   : Long_Float := 0.0;
      Variables : Long_Float_Vectors.Vector;
   end record;

   overriding function Priori
      (Priori : Normal_Priori; Variable : Variable_Type'Class)
      return Long_Float;
   overriding procedure Handle
      (Priori : in out Normal_Priori; Variable : Variable_Type'Class);
   overriding procedure Done (Priori : in out Normal_Priori);

end ML.Classification.Naivebayes.Prioris;
