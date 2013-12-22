pragma License (GPL);
package body ML.Primitive is
   use GEF;
   procedure Add (a : in out Element_Type;  b : Element_Type) is
   begin
      for j in Index_Type loop
         pragma Loop_Optimize (Vector);
         a (j) := a (j) + b (j);
      end loop;
   end Add;

   procedure Sub (a : in out Element_Type;  b : Element_Type) is
   begin
      for j in Index_Type loop
         pragma Loop_Optimize (Vector);
         a (j) := a (j) - b (j);
      end loop;
   end Sub;

   procedure Multiply (a : in out Element_Type; b : Scalar_Type) is
   begin
      for c of a loop
         pragma Loop_Optimize (Vector);
         c := c * b;
      end loop;
   end Multiply;

   procedure Divide (a : in out Element_Type; b : Scalar_Type) is
   begin
      for c of a loop
         pragma Loop_Optimize (Vector);
         c := c / b;
      end loop;
   end Divide;

   function "*" (a : Element_Type; b : Scalar_Type) return Element_Type is
   begin
      return r : Element_Type := a do
         for c of r loop
            pragma Loop_Optimize (Vector);
            c := c * b;
         end loop;
      end return;
   end "*";

   --   function Max (a : Element_Type; b : Index_Array) return Scalar_Type is
   --      m : Scalar_Type := a (b (b'First));
   --   begin
   --      for c of b loop
   --         if a (c) > m then
   --            m := a (c);
   --         end if;
   --      end loop;
   --      return m;
   --   end Max;

   function Max (a : Element_Type) return Scalar_Type is
      m : Scalar_Type := a (a'First);
   begin
      for c of a loop
         if c > m then
            m := c;
         end if;
      end loop;
      return m;
   end Max;

   --   function Min (a : Element_Type; b : Index_Array) return Scalar_Type is
   --      m : Scalar_Type := a (b (b'First));
   --   begin
   --      for c of b loop
   --         if a (c) < m then
   --            m := a (c);
   --         end if;
   --      end loop;
   --      return m;
   --   end Min;

   function Min (a : Element_Type) return Scalar_Type is
      m : Scalar_Type := a (a'First);
   begin
      for c of a loop
         if c < m then
            m := c;
         end if;
      end loop;
      return m;
   end Min;

   function Sum (a : Element_Type) return Scalar_Type is
      m : Scalar_Type := 0.0;
   begin
      for c of a loop
         m := m + c;
      end loop;
      return m;
   end Sum;

   --   function Mean (a : Element_Type; b : Index_Array) return Scalar_Type is
   --      m : Scalar_Type := 0.0;
   --   begin
   --      for c of b loop
   --         m := m + a (c);
   --      end loop;
   --      m := m / Scalar_Type (b'Length);
   --      return m;
   --   end Mean;

   function Mean (a : Element_Type) return Scalar_Type is
      m : Scalar_Type := 0.0;
   begin
      for c of a loop
         m := m + c;
      end loop;
      m := m / Scalar_Type (a'Length);
      return m;
   end Mean;

   --  E(x^2) - E(x)^2
   --   function Variance
   --      (a : Element_Type; b : Index_Array; Bessel : Boolean := True)
   --      return Scalar_Type is
   --      v, m : Scalar_Type := 0.0;
   --   begin
   --      for c of b loop
   --         m := m + a (c);
   --         v := v + a (c) * a (c);
   --      end loop;
   --      m := m / Scalar_Type (b'Length);
   --      v := v / Scalar_Type (b'Length) - m * m;
   --      if Bessel then
   --         v := v * Scalar_Type (b'Length) / Scalar_Type (b'Length - 1);
   --      end if;
   --      return v;
   --   end Variance;

   function Variance (a : Element_Type; Bessel : Boolean := True)
      return Scalar_Type is
      v, m : Scalar_Type := 0.0;
   begin
      for c of a loop
         m := m + c;
         v := v + c * c;
      end loop;
      m := m / Scalar_Type (a'Length);
      v := v / Scalar_Type (a'Length) - m * m;
      if Bessel then
         v := v * Scalar_Type (a'Length) / Scalar_Type (a'Length - 1);
      end if;
      return v;
   end Variance;

   --   function Standard_Deviation (a : Element_Type; b : Index_Array)
   --      return Scalar_Type is
   --   begin
   --      return Sqrt (Variance (a, b));
   --   end Standard_Deviation;

   function Standard_Deviation (a : Element_Type) return Scalar_Type is
   begin
      return Sqrt (Variance (a));
   end Standard_Deviation;

   --   function Central_Moment
   --      (a : Element_Type; b : Index_Array; n : Positive)
   --      return Scalar_Type is
   --      m : Scalar_Type := Mean (a, b);
   --      v : Scalar_Type := 0.0;
   --   begin
   --      for c of b loop
   --         v := v + (a (c) - m) ** n;
   --      end loop;
   --      return v / Scalar_Type (b'Length);
   --   end Central_Moment;

   function Central_Moment (a : Element_Type; n : Positive)
      return Scalar_Type is
      m : Scalar_Type := Mean (a);
      v : Scalar_Type := 0.0;
   begin
      for c of a loop
         v := v + (c - m) ** n;
      end loop;
      return v / Scalar_Type (a'Length);
   end Central_Moment;

   --   function Normalized_Moment
   --      (a : Element_Type; b : Index_Array; n : Positive)
   --      return Scalar_Type is
   --      m  : Scalar_Type := 0.0;
   --      v2 : Scalar_Type := 0.0;
   --      vn : Scalar_Type := 0.0;
   --   begin
   --      for c of b loop
   --         m  := m + a (c);
   --      end loop;
   --      m := m / Scalar_Type (b'Length);
   --      for c of b loop
   --         v2 := v2 + (a (c) - m) * (a (c) - m);
   --         vn := vn + (a (c) - m) ** n;
   --      end loop;
   --      v2 := v2 / Scalar_Type (b'Length);
   --      v2 := Sqrt (v2) ** n;
   --      vn := vn / Scalar_Type (b'Length);
   --      return vn / v2;
   --   end Normalized_Moment;

   function Normalized_Moment (a : Element_Type; n : Positive)
      return Scalar_Type is
      m  : Scalar_Type := 0.0;
      v2 : Scalar_Type := 0.0;
      vn : Scalar_Type := 0.0;
   begin
      for c of a loop
         m := m + c;
      end loop;
      m := m / Scalar_Type (a'Length);

      for c of a loop
         v2 := v2 + (c - m) * (c - m);
         vn := vn + (c - m) ** n;
      end loop;

      v2 := v2 / Scalar_Type (a'Length);
      v2 := Sqrt (v2) ** n;
      vn := vn / Scalar_Type (a'Length);
      return vn / v2;
   end Normalized_Moment;
   --------------------
   --  Distribution  --
   --------------------
   function Normal (x, m, s : Scalar_Type) return Scalar_Type is
   begin
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

   ---------------
   -- Distances --
   ---------------

   function Squared_Euclidean_Distance (a, b : Element_Type)
      return Scalar_Type is
      m : Scalar_Type := 0.0;
   begin
      for j in Index_Type loop
         pragma Loop_Optimize (Vector);
         m := m + (a (j) - b (j)) ** 2;
      end loop;
      return m;
   end Squared_Euclidean_Distance;

   --  function Euclidean_Distance (a, b : Element_Type) return Scalar_Type is
   --  begin
   --    return Sqrt (Squared_Euclidean_Distance (a, b));
   --  end Euclidean_Distance;

   function Manhattan_Distance (a, b : Element_Type) return Scalar_Type is
      m : Scalar_Type := 0.0;
   begin
      for j in Index_Type loop
         pragma Loop_Optimize (Vector);
         m := m + abs (a (j) - b (j));
      end loop;
      return m;
   end Manhattan_Distance;

   function Sup_Distance (a, b : Element_Type) return Scalar_Type is
      m : Scalar_Type := 0.0;
      d : Scalar_Type;
   begin
      for j in Index_Type loop
         d := abs (a (j) - b (j));
         if d > m then
            m := d;
         end if;
      end loop;
      return m;
   end Sup_Distance;

   function Cosine_Distance (a, b : Element_Type) return Scalar_Type is
      m, na, nb : Scalar_Type := 0.0;
   begin
      for j in Index_Type loop
         pragma Loop_Optimize (Vector);
         m  := m  + a (j) * b (j);
         na := na + a (j) * a (j);
         nb := nb + b (j) * b (j);
      end loop;

      if m = 0.0 then
         return 1.0;
      end if;

      return 1.0 - m / Sqrt (na * nb);
   end Cosine_Distance;

end ML.Primitive;
