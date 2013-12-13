pragma ada_12;

package body ai.primitive is
   use elementary_functions;

   function max (a : real_array; b : index_array) return real is
      m : real := a (b (b'first));
   begin
      for c of b loop
         if a (c) > m then
            m := a (c);
         end if;
      end loop;
      return m;
   end max;

   function max (a : real_array) return real is
      m : real := a (a'first);
   begin
      for c of a loop
         if c > m then
            m := c;
         end if;
      end loop;
      return m;
   end max;

   function min (a : real_array; b : index_array) return real is
      m : real := a (b (b'first));
   begin
      for c of b loop
         if a (c) < m then
            m := a (c);
         end if;
      end loop;
      return m;
   end min;

   function min (a : real_array) return real is
      m : real := a (a'first);
   begin
      for c of a loop
         if c < m then
            m := c;
         end if;
      end loop;
      return m;
   end min;

   function mean (a : real_array; b : index_array) return real is
      m : real := 0.0;
   begin
      for c of b loop
         m := m + a (c);
      end loop;
      m := m / real (b'length);
      return m;
   end mean;

   function mean (a : real_array) return real is
      m : real := 0.0;
   begin
      for c of a loop
         m := m + c;
      end loop;
      m := m / real (a'length);
      return m;
   end mean;

   -- E(x^2) - E(x)^2
   function variance(a : real_array; b : index_array) return real is
      v, m : real := 0.0;
   begin
      for c of b loop
         m := m + a (c);
         v := v + a (c) * a (c);
      end loop;
      m := m / real (b'length);
      v := v / real (b'length) - m * m;
      return v; -- N.B. No bessel's correction (N-1) applied!
   end variance;

   function variance(a : real_array) return real is
      v, m : real := 0.0;
   begin
      for c of a loop
         m := m + c;
         v := v + c * c;
      end loop;
      m := m / real (a'length);
      v := v / real (a'length) - m * m;
      return v; -- N.B. No bessel's correction (N-1) applied!
   end variance;

   function standard_deviation (a : real_array; b : index_array) return real is
   begin
      return sqrt(variance(a,b));
   end standard_deviation;

   function standard_deviation (a : real_array) return real is
   begin
      return sqrt(variance(a));
   end standard_deviation;

   function central_moment (a : real_array; b : index_array; n : positive)
      return real is
      m : real := mean (a,b);
      v : real := 0.0;
   begin
      for c of b loop
         v := v + (a (c) - m) ** n;
      end loop;
      return v / real (b'length);
   end central_moment;

   function central_moment (a : real_array; n : positive) return real is
      m : real := mean (a);
      v : real := 0.0;
   begin
      for c of a loop
         v := v + (c - m) ** n;
      end loop;
      return v / real (a'length);
   end central_moment;

   function normalized_moment (a : real_array; b : index_array; n : positive)
      return real is
      m  : real := 0.0;
      v2 : real := 0.0;
      vn : real := 0.0;
   begin
      for c of b loop
         m  := m + a (c);
      end loop;
      m := m / real(b'length);
      for c of b loop
         v2 := v2 + (a (c) - m) * (a (c) - m);
         vn := vn + (a (c) - m) ** n;
      end loop;
      v2 := v2 / real (b'length);
      v2 := sqrt (v2) ** n;
      vn := vn / real (b'length);
      return vn / v2;
   end normalized_moment;

   function normalized_moment (a : real_array; n : positive) return real is
      m  : real := 0.0;
      v2 : real := 0.0;
      vn : real := 0.0;
   begin
      for c of a loop
         m  := m + c;
      end loop;
      m := m / real (a'length);

      for c of a loop
         v2 := v2 + (c - m) * (c - m);
         vn := vn + (c - m) ** n;
      end loop;

      v2 := v2 / real (a'length);
      v2 := sqrt (v2) ** n;
      vn := vn / real (a'length);
      return vn / v2;
   end normalized_moment;

   ---------------
   -- Distances --
   ---------------

   function squared_euclidean_distance(a, b : real_array) return real is
      m : real := 0.0;
   begin
      for j in a'range loop
         m := m + (a (j) - b (j + b'first - a'first)) ** 2;
      end loop;
      return m;
   end squared_euclidean_distance;

   function euclidean_distance(a, b : real_array) return real is
   begin
      return sqrt(squared_euclidean_distance(a,b));
   end euclidean_distance;

   function manhattan_distance(a, b : real_array) return real is
      m : real := 0.0;
   begin
      for j in a'range loop
         m := m + abs (a (j) - b (j + b'first - a'first));
      end loop;
      return m;
   end manhattan_distance;

   function sup_distance(a, b : real_array) return real is
      m : real := 0.0;
      d : real;
   begin
      for j in a'range loop
         d := abs (a (j) - b (j + b'first - a'first));
         if d > m then
            m := d;
         end if;
      end loop;
      return m;
   end sup_distance;

   function cosine_distance(a, b : real_array) return real is
      m, na, nb: real := 0.0;
   begin
      for j in a'range loop
         m  := m  + a (j) * b (j + b'first - a'first);
         na := na + a (j) * a (j);
         nb := nb + b (j) * b (j);
      end loop;

      if m = 0.0 then return 1.0; end if;

      return 1.0 - m / sqrt (na * nb);
   end cosine_distance;

end ai.primitive;
