pragma License (GPL);
package body AI.Primitive is
   use Elementary_Functions;

   function max (a : Real_Array; b : Index_Array) return Real is
      m : Real := a (b (b'First));
   begin
      for c of b loop
         if a (c) > m then
            m := a (c);
         end if;
      end loop;
      return m;
   end max;

   function max (a : Real_Array) return Real is
      m : Real := a (a'First);
   begin
      for c of a loop
         if c > m then
            m := c;
         end if;
      end loop;
      return m;
   end max;

   function min (a : Real_Array; b : Index_Array) return Real is
      m : Real := a (b (b'First));
   begin
      for c of b loop
         if a (c) < m then
            m := a (c);
         end if;
      end loop;
      return m;
   end min;

   function min (a : Real_Array) return Real is
      m : Real := a (a'First);
   begin
      for c of a loop
         if c < m then
            m := c;
         end if;
      end loop;
      return m;
   end min;

   function mean (a : Real_Array; b : Index_Array) return Real is
      m : Real := 0.0;
   begin
      for c of b loop
         m := m + a (c);
      end loop;
      m := m / Real (b'Length);
      return m;
   end mean;

   function mean (a : Real_Array) return Real is
      m : Real := 0.0;
   begin
      for c of a loop
         m := m + c;
      end loop;
      m := m / Real (a'Length);
      return m;
   end mean;

   --  E(x^2) - E(x)^2
   function variance (a : Real_Array; b : Index_Array) return Real is
      v, m : Real := 0.0;
   begin
      for c of b loop
         m := m + a (c);
         v := v + a (c) * a (c);
      end loop;
      m := m / Real (b'Length);
      v := v / Real (b'Length) - m * m;
      return v; -- N.B. No bessel's correction (N-1) applied!
   end variance;

   function variance (a : Real_Array) return Real is
      v, m : Real := 0.0;
   begin
      for c of a loop
         m := m + c;
         v := v + c * c;
      end loop;
      m := m / Real (a'Length);
      v := v / Real (a'Length) - m * m;

      return v; -- N.B. No bessel's correction (N-1) applied!
   end variance;

   function standard_deviation (a : Real_Array; b : Index_Array) return Real is
   begin
      return Sqrt (variance (a, b));
   end standard_deviation;

   function standard_deviation (a : Real_Array) return Real is
   begin
      return Sqrt (variance (a));
   end standard_deviation;

   function central_moment (a : Real_Array; b : Index_Array; n : Positive)
      return Real is
      m : Real := mean (a, b);
      v : Real := 0.0;
   begin
      for c of b loop
         v := v + (a (c) - m) ** n;
      end loop;
      return v / Real (b'Length);
   end central_moment;

   function central_moment (a : Real_Array; n : Positive) return Real is
      m : Real := mean (a);
      v : Real := 0.0;
   begin
      for c of a loop
         v := v + (c - m) ** n;
      end loop;
      return v / Real (a'Length);
   end central_moment;

   function normalized_moment (a : Real_Array; b : Index_Array; n : Positive)
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
   end normalized_moment;

   function normalized_moment (a : Real_Array; n : Positive) return Real is
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
   end normalized_moment;

   ---------------
   -- Distances --
   ---------------

   function squared_euclidean_distance (a, b : Real_Array) return Real is
      m : Real := 0.0;
   begin
      for j in a'Range loop
         m := m + (a (j) - b (j + b'First - a'First)) ** 2;
      end loop;
      return m;
   end squared_euclidean_distance;

   function euclidean_distance (a, b : Real_Array) return Real is
   begin
      return Sqrt (squared_euclidean_distance (a, b));
   end euclidean_distance;

   function manhattan_distance (a, b : Real_Array) return Real is
      m : Real := 0.0;
   begin
      for j in a'Range loop
         m := m + abs (a (j) - b (j + b'First - a'First));
      end loop;
      return m;
   end manhattan_distance;

   function sup_distance (a, b : Real_Array) return Real is
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
   end sup_distance;

   function cosine_distance (a, b : Real_Array) return Real is
      m, na, nb : Real := 0.0;
   begin
      for j in a'Range loop
         m  := m  + a (j) * b (j + b'First - a'First);
         na := na + a (j) * a (j);
         nb := nb + b (j) * b (j);
      end loop;

      if m = 0.0 then return 1.0; end if;

      return 1.0 - m / Sqrt (na * nb);
   end cosine_distance;

end AI.Primitive;
