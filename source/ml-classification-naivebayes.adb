with ML.Primitive;
with Ada.Unchecked_Deallocation;
with Ada.Text_IO;
use Ada.Text_IO;
package body ML.Classification.Naivebayes is
   package MLP renames ML.Primitive;
   package Real_IO is new Ada.Text_IO.Float_IO (Real);
   use Real_IO;
   procedure Initialize (o : in out Object) is
   begin
      o.Means      := new Matrix_Type;
      o.Means.all  := (others => (others => 0.0));
      o.SDs        := new Matrix_Type;
      o.SDs.all    := (others => (others => 0.0));
      o.Priori     := new Priori_Type;
      o.Priori.all := (others => 0);
   end Initialize;

   procedure Finalize   (o : in out Object) is
      procedure Free is
         new Ada.Unchecked_Deallocation (Matrix_Type, Matrix_Access);
      procedure Free is
         new Ada.Unchecked_Deallocation (Priori_Type, Priori_Access);
   begin
      Free (o.Means);
      Free (o.SDs);
      Free (o.Priori);
   end Finalize;

   procedure Train (o : Object) is
      n : Index_Type;
      f : Feature_Array;
      c : Class_Type;
   begin
      if Length = 0 then
         return;
      end if;

      n := Index_Type (Length);

      for j in 1 .. n loop
         f := Element (j);
         c := Belong (j);
         o.Priori (c) := o.Priori (c) + 1;

         for jj in Feature_Type loop
            o.Means (c, jj) := o.Means (c, jj) + f (jj);
         end loop;
      end loop;

      for j in Class_Type loop
         for jj in Feature_Type loop
            o.Means (j, jj) := o.Means (j, jj) / Real (o.Priori (j));
         end loop;
      end loop;

      for j in 1 .. n loop
         f := Element (j);
         c := Belong (j);

         for jj in Feature_Type loop
            o.SDs (c, jj) := o.SDs (c, jj) + (o.Means (c, jj) - f (jj)) ** 2;
         end loop;
      end loop;

      for j in Class_Type loop
         if o.Priori (j) > 1 then
            for jj in Feature_Type loop
               o.SDs (j, jj) := MLP.ML_Elementary_Functions.Sqrt
                  (o.SDs (j, jj) / Real (o.Priori (j) - 1));
            end loop;
         end if;
         --  TODO if o.Proiri (j) < 2
      end loop;
   end Train;

   procedure Put (o : Object) is
      tmp : Real    := 0.0;
      w   : Integer := Class_Type'Width;
   begin
      Put_Line ("A-priori probabilities : ");
      for c in Class_Type loop
         tmp := tmp + Real (o.Priori (c));
         Set_Col ((Real'Width - 1) * (Class_Type'Pos (c) + 1) + 1 -
         String (c'Img)'Length);
         Put (c'Img);
      end loop;

      New_Line;

      for c in Class_Type loop
         Put (Real (o.Priori(c)) /  Real (tmp), Fore => 2, Exp => 4);
      end loop;

      New_Line;
      Put_Line ("Conditional probabilities :");
      Put ("Means");

      for f in Feature_Type loop
         Set_Col ((Real'Width - 1) * (Feature_Type'Pos (f) + 2) + 1 -
         String (f'Img)'Length);
         Put (f'Img);
      end loop;

      New_Line;

      for c in Class_Type loop
         Put ("  " & c'Img);
         Set_Col (Count ((Real'Width)));

         for f in Feature_Type loop
            Put (o.Means (c, f), Fore => 2, Exp => 4);
         end loop;
         New_Line;
      end loop;

      Put ("Standard deviations");

      for f in Feature_Type loop
         Set_Col ((Real'Width - 1) * (Feature_Type'Pos (f) + 2) + 1 -
         String (f'Img)'Length);
         Put (f'Img);
      end loop;

      New_Line;

      for c in Class_Type loop
         Put ("  " & c'Img);
         Set_Col (Count ((Real'Width)));
         for f in Feature_Type loop
            Put (o.SDs (c, f), Fore => 2, Exp => 4);
         end loop;
         New_Line;
      end loop;
   end Put;

   type Prediction is array (Class_Type) of Real;
   procedure Predict (o : Object; x : Feature_Array) is
   begin
      if Length = 0 then
         return;
      end if;

      declare
         p  : Prediction := (others => 1.0);
         ps : Real       := 0.0;
      begin
         for c in Class_Type loop
            for f in Feature_Type loop
               p (c) := p (c) *
                  MLP.Normal (x (f), o.Means (c, f), o.SDs (c, f));
            end loop;

            p (c) := p (c) * Real (o.Priori (c)) / Real (Length);
            ps := ps + p (c);
         end loop;

         for c in Class_Type loop
            p (c) := p (c) / ps;
            Set_Col ((Real'Width - 1) * (Class_Type'Pos (c) + 1) + 1 -
            String (c'Img)'Length);
            Put (c'Img);
         end loop;

         New_Line;

         for c in Class_Type loop
            Put (p (c), Fore => 2, Exp => 4);
         end loop;
      end;
   end Predict;

   function Predict (o : Object; x : Feature_Array) return Class_Type is
   begin
      if Length = 0 then
         return Class_Type'First;
      end if;

      declare
         p  : Prediction := (others => 1.0);
         ps : Real       := 0.0;
         r  : Class_Type;
      begin
         for c in Class_Type loop
            for f in Feature_Type loop
               p (c) := p (c) * MLP.Normal (x (f), o.Means (c, f), o.SDs (c, f));
            end loop;

            p (c) := p (c) * Real (o.Priori (c)) / Real (Length);
            ps := ps + p (c);
         end loop;

         for c in Class_Type loop
            p (c) := p (c) / ps;
         end loop;

         ps := Real'First;

         for c in Class_Type loop
            if p (c) > ps then
               ps := p (c);
               r  := c;
            end if;
         end loop;
         return r;
      end;
   end Predict;
end ML.Classification.Naivebayes;
