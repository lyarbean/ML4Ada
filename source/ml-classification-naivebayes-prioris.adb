pragma Ada_2012;
with Ada.Numerics.Generic_Elementary_Functions;
with ML.Primitive;
with Ada.Text_IO;
package body ML.Classification.Naivebayes.Prioris is
   ---------------------
   --  Normal Priori  --
   ---------------------
   package MLP is new ML.Primitive (Long_Float);
   use MLP;
   procedure Handle
      (Priori : in out Normal_Priori; Variable : Variable_Type'Class) is
   begin
      if Variable not in Long_Float_Variable'Class then
         raise Mismatched_Variable;
      end if;
      Priori.Variables.Append (Long_Float_Variable (Variable).V);
   end  Handle;

   procedure Done (Priori : in out Normal_Priori) is
   begin
      if Priori.Variables.Is_Empty or
         Integer (Priori.Variables.Length) < 2 then
         raise Variables_Not_Enough;
      end if;
      Priori.Mean := 0.0;
      Priori.SD   := 0.0;
      for c of Priori.Variables loop
         Priori.Mean := Priori.Mean + c;
      end loop;
      Priori.Mean := Priori.Mean / Long_Float (Priori.Variables.Length);
      for c of Priori.Variables loop
         Priori.SD := Priori.SD + (Priori.Mean - c) ** 2;
      end loop;
      --  Sample Variance
      Priori.SD := Priori.SD / (Long_Float (Priori.Variables.Length) - 1.0);
      Priori.SD := GEF.Sqrt (Priori.SD);
      if Priori.SD < 1.0e-12 then
         Priori.SD := 1.0e-12;
      end if;
   end Done;

   function Priori (Priori : Normal_Priori; Variable : Variable_Type'Class)
      return Long_Float is
   begin
      if Variable not in Long_Float_Variable'Class then
         raise Mismatched_Variable;
      end if;
      return Normal (Long_Float_Variable (Variable).V, Priori.Mean, Priori.SD);
   end Priori;
end ML.Classification.Naivebayes.Prioris;
