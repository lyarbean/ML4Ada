pragma ada_12;

package body ai.primitive is
   use elementary_functions;

   function max (a : real_array; b : index_array) return real is
      m : real := a (b (b'first));
   begin
      for c of b loop
           if a(c) > m then
               m := a(c);
           end if;
       end loop;
       return m;
   end max;

   function min (a : real_array; b : index_array) return real is
       m : real := a(b(b'first));
   begin
       for c of b loop
          if a(c) < m then
             m := a(c);
          end if;
       end loop;
       return m;
   end min;

   -- TODO Check b's values
   function mean (a : real_array; b : index_array) return real is
       sum : real := 0.0;
   begin
       for c of b loop
           sum := sum + a(c);
       end loop;
       sum := sum / real(b'length);
       return sum;
   end mean;

   function variance(a : real_array; b : index_array) return real is
       v, m: real := 0.0;
   begin
       for c of b loop
           m := m + a(c);
       end loop;
       m := m / real(b'length);
       for c of b loop
           v := v + (a(c)-m)**2;
       end loop;
       return v/real(b'length); -- should we apply  bessel's correction (-1)?
   end variance;

   function standard_deviation (a : real_array; b : index_array) return real is
   begin
       return sqrt(variance(a,b));
   end standard_deviation;

   function central_moment (a : real_array;
       b : index_array;
       n : positive) return real is
       m : real := mean(a,b);
       v : real := 0.0;
   begin
       for c of b loop
           v := v + (a(c)-m)**n;
       end loop;
       return v/real(b'length);
   end central_moment;

   -- TODO avoid computing mean twice
   function normalized_moment (a : real_array;
       b : index_array;
       n : positive) return real is
   begin
       return central_moment(a,b,n) / (standard_deviation(a,b)**n);
   end normalized_moment;

   ---------------
   -- Distances --
   ---------------

   function squared_euclidean_distance(a,b:real_array) return real is
       sed : real := 0.0;
       item_b : real;
   begin
       for j in a'range loop
           item_b := b(j+b'first-a'first);
           sed := sed + (a(j)-item_b)**2;
       end loop;
       return sed;
   end squared_euclidean_distance;

   function euclidean_distance(a,b:real_array) return real is
   begin
       return sqrt(squared_euclidean_distance(a,b));
   end euclidean_distance;

   function manhattan_distance(a,b:real_array) return real is
       md : real := 0.0;
   begin
       for j in a'range loop
           md := md + abs(a(j) - b(j+b'first-a'first));
       end loop;
       return md;
   end manhattan_distance;

   function sup_distance(a,b:real_array) return real is
       distance: real := 0.0;
       diff : real;
   begin
       for j in a'range loop
           diff := abs(a(j) - b(j+b'first-a'first));
           if diff > distance then
               distance := diff;
           end if;
       end loop;
       return distance;
   end sup_distance;

   function cosine_distance(a,b:real_array) return real is
       dot_prod, norm_a, norm_b: real := 0.0;
   begin
       for j in a'range loop
           dot_prod := dot_prod +  a(j) * b(j+b'first-a'first);
           norm_b := norm_a + a(j) ** 2;
           norm_b := norm_b + b(j) ** 2;
       end loop;

       if dot_prod = 0.0 then return 1.0; end if;

       return 1.0 - dot_prod / sqrt(norm_a*norm_b);
   end cosine_distance;

end ai.primitive;
