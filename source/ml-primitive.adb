pragma License (GPL);
package body ML.Primitive is
   use GEF;
   --------------------
   --  Distribution  --
   --------------------
   function Normal (x, m, s : Scalar_Type) return Scalar_Type is
   begin
      if s <= 0.0 then
         if x = m then
            return 1.0;
         else
            return 0.0;
         end if;
      end if;
      return Exp (-((x - m) / s) ** 2 / 2.0) /
      (Sqrt (2.0 * Ada.Numerics.Pi) * s);
   end Normal;

   function Log_Normal (x, m, s : Scalar_Type) return Scalar_Type is
   begin
      if x <= 0.0 then
         return 0.0;
      end if;
      return Exp (-((Log (x) - m) / s) ** 2 / 2.0) /
      (Sqrt (2.0 * Ada.Numerics.Pi) * s * x);
   end Log_Normal;
end ML.Primitive;
