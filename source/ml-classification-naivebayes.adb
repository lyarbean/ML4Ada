with ML.Primitive;
with ML.Primitive.Vector;
with Ada.Unchecked_Deallocation;
with Ada.Text_IO;
use Ada.Text_IO;
package body ML.Classification.Naivebayes is
   package MLP is new ML.Primitive (Scalar_Type);
   package MLPV is new MLP.Vector (Feature_Type, Feature_Array);
   package Scalar_IO is new Ada.Text_IO.Float_IO (Scalar_Type);
   use Scalar_IO;
   type Matrix_Type is array (Class_Type, Feature_Type) of Scalar_Type;
   type Priori_Type is array (Class_Type) of Integer;

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
      n : Positive;
      f : Feature_Array;
      c : Class_Type;
   begin
      if Length = 0 then
         return;
      end if;

      n := Positive (Length);

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
            o.Means (j, jj) := o.Means (j, jj) / Scalar_Type (o.Priori (j));
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
               o.SDs (j, jj) := MLP.GEF.Sqrt
                  (o.SDs (j, jj) / Scalar_Type (o.Priori (j) - 1));
            end loop;
         end if;
         --  TODO if o.Proiri (j) < 2
      end loop;
   end Train;

   procedure Put (o : Object) is
      tmp : Scalar_Type    := 0.0;
      w   : Integer := Class_Type'Width;
   begin
      Put_Line ("A-priori probabilities : ");
      for c in Class_Type loop
         tmp := tmp + Scalar_Type (o.Priori (c));
         Set_Col ((Scalar_Type'Width - 1) * (Class_Type'Pos (c) + 1) + 1 -
         String (c'Img)'Length);
         Put (c'Img);
      end loop;

      New_Line;

      for c in Class_Type loop
         Put (Scalar_Type (o.Priori (c)) / Scalar_Type (tmp),
         Fore => 2, Exp => 4);
      end loop;

      New_Line;
      Put_Line ("Conditional probabilities :");
      Put ("Means");

      for f in Feature_Type loop
         Set_Col ((Scalar_Type'Width - 1) * (Feature_Type'Pos (f) + 2) +
            1 - String (f'Img)'Length);
         Put (f'Img);
      end loop;

      New_Line;

      for c in Class_Type loop
         Put ("  " & c'Img);
         Set_Col (Count ((Scalar_Type'Width)));

         for f in Feature_Type loop
            Put (o.Means (c, f), Fore => 2, Exp => 4);
         end loop;
         New_Line;
      end loop;

      Put ("Standard deviations");

      for f in Feature_Type loop
         Set_Col ((Scalar_Type'Width - 1) * (Feature_Type'Pos (f) + 2) +
            1 - String (f'Img)'Length);
         Put (f'Img);
      end loop;

      New_Line;

      for c in Class_Type loop
         Put ("  " & c'Img);
         Set_Col (Count ((Scalar_Type'Width)));
         for f in Feature_Type loop
            Put (o.SDs (c, f), Fore => 2, Exp => 4);
         end loop;
         New_Line;
      end loop;
   end Put;

   type Prediction is array (Class_Type) of Scalar_Type;
   procedure Predict
      (o : Object; x : Feature_Array; d : Distribution_Type := Normal) is
   begin
      if Length = 0 then
         return;
      end if;

      declare
         p  : Prediction := (others => 1.0);
         ps : Scalar_Type       := 0.0;
      begin
         for c in Class_Type loop
            case d is
               when Normal =>
                  for f in Feature_Type loop
                     p (c) := p (c) *
                     MLP.Normal (x (f), o.Means (c, f), o.SDs (c, f));
                  end loop;
               when Log_Normal =>
                  for f in Feature_Type loop
                     p (c) := p (c) *
                     MLP.Log_Normal (x (f), o.Means (c, f), o.SDs (c, f));
                  end loop;
               when others =>
                  raise Not_Implemented_Distribution;
            end case;
            p (c) := p (c) * Scalar_Type (o.Priori (c)) / Scalar_Type (Length);
            ps := ps + p (c);
         end loop;

         for c in Class_Type loop
            p (c) := p (c) / ps;
            Set_Col ((Scalar_Type'Width - 1) * (Class_Type'Pos (c) + 1) +
               1 - String (c'Img)'Length);
            Put (c'Img);
         end loop;

         New_Line;

         for c in Class_Type loop
            Put (p (c), Fore => 2, Exp => 4);
         end loop;
      end;
   end Predict;

   function Predict
      (o : Object; x : Feature_Array; d : Distribution_Type := Normal)
      return Class_Type is
   begin
      if Length = 0 then
         return Class_Type'First;
      end if;

      declare
         p  : Prediction := (others => 1.0);
         ps : Scalar_Type       := 0.0;
         r  : Class_Type;
      begin
         for c in Class_Type loop
            case d is
               when Normal =>
                  for f in Feature_Type loop
                     p (c) := p (c) *
                     MLP.Normal (x (f), o.Means (c, f), o.SDs (c, f));
                  end loop;
               when Log_Normal =>
                  for f in Feature_Type loop
                     p (c) := p (c) *
                     MLP.Log_Normal (x (f), o.Means (c, f), o.SDs (c, f));
                  end loop;
               when others =>
                  raise Not_Implemented_Distribution;
            end case;
            p (c) := p (c) * Scalar_Type (o.Priori (c)) / Scalar_Type (Length);
            ps := ps + p (c);
         end loop;

         for c in Class_Type loop
            p (c) := p (c) / ps;
         end loop;

         ps := Scalar_Type'First;

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
