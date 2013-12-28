with Ada.Numerics.Generic_Elementary_Functions;
with ML.Primitive;
package body ML.Classification.Types is
   package MLP is new ML.Primitive (Long_Float);
   use MLP;
   procedure See (np : in out Normal_Priori; e : Event_Type'Class) is
   begin
      if not (e in  Long_Float_Event) then
         raise Mismatched_Event;
      end if;
      np.Variables.Append (Long_Float_Event (e).E);
   end  See;

   procedure Run (np : in out Normal_Priori) is
   begin
      if np.Variables.Is_Empty or Integer (np.Variables.Length) < 2 then
         raise Variables_Not_Enough;
      end if;
      np.Mean := 0.0;
      np.SD   := 0.0;
      for c of np.Variables loop
         np.Mean := np.Mean + c;
      end loop;
      np.Mean := np.Mean / Long_Float (np.Variables.Length);
      for c of np.Variables loop
         np.SD := np.SD + (np.Mean - c) ** 2;
      end loop;
      --  Sample Variance
      np.SD := np.SD / (Long_Float (np.Variables.Length) - 1.0);
      np.SD := GEF.Sqrt (np.SD);
   end Run;
   function Priori (np : Normal_Priori; e : Event_Type'Class)
      return Long_Float is
   begin
      return Normal (Long_Float_Event (e).E, np.Mean, np.SD);
   end Priori;
end ML.Classification.Types;
