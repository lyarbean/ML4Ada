pragma License (GPL);
package body ML.Primitive is
   use ML_Elementary_Functions;
   procedure Add (a : in out Real_Array;  b : Real_Array) is
   begin
      for j in a'Range loop
         pragma Loop_Optimize (Vector);
         a (j) := a (j) + b (j);
      end loop;
   end Add;

   procedure Sub (a : in out Real_Array;  b : Real_Array) is
   begin
      for j in a'Range loop
         pragma Loop_Optimize (Vector);
         a (j) := a (j) - b (j);
      end loop;
   end Sub;

   procedure Multiply (a : in out Real_Array; b : Real) is
   begin
      for c of a loop
         pragma Loop_Optimize (Vector);
         c := c * b;
      end loop;
   end Multiply;

   procedure Divide (a : in out Real_Array; b : Real) is
   begin
      for c of a loop
         pragma Loop_Optimize (Vector);
         c := c / b;
      end loop;
   end Divide;

   function "*" (a : Real_Array; b : Real) return Real_Array is
   begin
      return r : Real_Array := a do
         for c of r loop
            pragma Loop_Optimize (Vector);
            c := c * b;
         end loop;
      end return;
   end "*";

   function Max (a : Real_Array; b : Index_Array) return Real is
      m : Real := a (b (b'First));
   begin
      for c of b loop
         if a (c) > m then
            m := a (c);
         end if;
      end loop;
      return m;
   end Max;

   function Max (a : Real_Array) return Real is
      m : Real := a (a'First);
   begin
      for c of a loop
         if c > m then
            m := c;
         end if;
      end loop;
      return m;
   end Max;

   function Min (a : Real_Array; b : Index_Array) return Real is
      m : Real := a (b (b'First));
   begin
      for c of b loop
         if a (c) < m then
            m := a (c);
         end if;
      end loop;
      return m;
   end Min;

   function Min (a : Real_Array) return Real is
      m : Real := a (a'First);
   begin
      for c of a loop
         if c < m then
            m := c;
         end if;
      end loop;
      return m;
   end Min;

   function Sum (a : Real_Array) return Real is
      m : Real := 0.0;
   begin
      for c of a loop
         m := m + c;
      end loop;
      return m;
   end Sum;

   function Mean (a : Real_Array; b : Index_Array) return Real is
      m : Real := 0.0;
   begin
      for c of b loop
         m := m + a (c);
      end loop;
      m := m / Real (b'Length);
      return m;
   end Mean;

   function Mean (a : Real_Array) return Real is
      m : Real := 0.0;
   begin
      for c of a loop
         m := m + c;
      end loop;
      m := m / Real (a'Length);
      return m;
   end Mean;

   --  E(x^2) - E(x)^2
   function Variance
      (a : Real_Array; b : Index_Array; Bessel : Boolean := True)
      return Real is
      v, m : Real := 0.0;
   begin
      for c of b loop
         m := m + a (c);
         v := v + a (c) * a (c);
      end loop;
      m := m / Real (b'Length);
      v := v / Real (b'Length) - m * m;
      if Bessel then
         v := v * Real (b'Length) / Real (b'Length - 1);
      end if;
      return v;
   end Variance;

   function Variance (a : Real_Array; Bessel : Boolean := True) return Real is
      v, m : Real := 0.0;
   begin
      for c of a loop
         m := m + c;
         v := v + c * c;
      end loop;
      m := m / Real (a'Length);
      v := v / Real (a'Length) - m * m;
      if Bessel then
         v := v * Real (a'Length) / Real (a'Length - 1);
      end if;
      return v;
   end Variance;

   function Standard_Deviation (a : Real_Array; b : Index_Array) return Real is
   begin
      return Sqrt (Variance (a, b));
   end Standard_Deviation;

   function Standard_Deviation (a : Real_Array) return Real is
   begin
      return Sqrt (Variance (a));
   end Standard_Deviation;

   function Central_Moment (a : Real_Array; b : Index_Array; n : Positive)
      return Real is
      m : Real := Mean (a, b);
      v : Real := 0.0;
   begin
      for c of b loop
         v := v + (a (c) - m) ** n;
      end loop;
      return v / Real (b'Length);
   end Central_Moment;

   function Central_Moment (a : Real_Array; n : Positive) return Real is
      m : Real := Mean (a);
      v : Real := 0.0;
   begin
      for c of a loop
         v := v + (c - m) ** n;
      end loop;
      return v / Real (a'Length);
   end Central_Moment;

   function Normalized_Moment (a : Real_Array; b : Index_Array; n : Positive)
      return Real is
      m  : Real := 0.0;
      v2 : Real := 0.0;
      vn : Real := 0.0;
   begin
      for c of b loop
         m  := m + a (c);
      end loop;
      m := m / Real (b'Length);
      for c of b loop
         v2 := v2 + (a (c) - m) * (a (c) - m);
         vn := vn + (a (c) - m) ** n;
      end loop;
      v2 := v2 / Real (b'Length);
      v2 := Sqrt (v2) ** n;
      vn := vn / Real (b'Length);
      return vn / v2;
   end Normalized_Moment;

   function Normalized_Moment (a : Real_Array; n : Positive) return Real is
      m  : Real := 0.0;
      v2 : Real := 0.0;
      vn : Real := 0.0;
   begin
      for c of a loop
         m := m + c;
      end loop;
      m := m / Real (a'Length);

      for c of a loop
         v2 := v2 + (c - m) * (c - m);
         vn := vn + (c - m) ** n;
      end loop;

      v2 := v2 / Real (a'Length);
      v2 := Sqrt (v2) ** n;
      vn := vn / Real (a'Length);
      return vn / v2;
   end Normalized_Moment;
   --------------------
   --  Distribution  --
   --------------------
   function Normal (x, m, s : Real) return Real is
   begin
      return Exp (-((x - m) / s) ** 2 / 2.0) /
         (Sqrt (2.0 * Ada.Numerics.Pi) * s);
   end Normal;

   function Log_Normal (x, m, s : Real) return Real is
   begin
      if x <= 0.0 then
         return 0.0;
      end if;
      return Exp (-((Log (x) - m) / s) ** 2 / 2.0) /
      (Sqrt (2.0 * Ada.Numerics.Pi) * s * x);
   end Log_Normal;

   ---------------
   -- Distances --
   ---------------

   function Squared_Euclidean_Distance (a, b : Element_Array) return Real is
      m : Real := 0.0;
   begin
      for j in Index_Type loop
         pragma Loop_Optimize (Vector);
         m := m + (a (j) - b (j)) ** 2;
      end loop;
      return m;
   end Squared_Euclidean_Distance;

   --  function Euclidean_Distance (a, b : Real_Array) return Real is
   --  begin
   --    return Sqrt (Squared_Euclidean_Distance (a, b));
   --  end Euclidean_Distance;

   function Manhattan_Distance (a, b : Real_Array) return Real is
      m : Real := 0.0;
   begin
      for j in a'Range loop
         pragma Loop_Optimize (Vector);
         m := m + abs (a (j) - b (j + b'First - a'First));
      end loop;
      return m;
   end Manhattan_Distance;

   function Sup_Distance (a, b : Real_Array) return Real is
      m : Real := 0.0;
      d : Real;
   begin
      for j in a'Range loop
         d := abs (a (j) - b (j + b'First - a'First));
         if d > m then
            m := d;
         end if;
      end loop;
      return m;
   end Sup_Distance;

   function Cosine_Distance (a, b : Real_Array) return Real is
      m, na, nb : Real := 0.0;
   begin
      for j in a'Range loop
         pragma Loop_Optimize (Vector);
         m  := m  + a (j) * b (j + b'First - a'First);
         na := na + a (j) * a (j);
         nb := nb + b (j) * b (j);
      end loop;

      if m = 0.0 then
         return 1.0;
      end if;

      return 1.0 - m / Sqrt (na * nb);
   end Cosine_Distance;

end ML.Primitive;
