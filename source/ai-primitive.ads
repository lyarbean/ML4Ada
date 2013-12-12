pragma ada_12;
with ada.numerics.generic_elementary_functions;
package ai.primitive is
   type real is new long_long_float;
   type index is new long_long_integer;
   type real_array is array (index range <>) of real;
   type index_array is array (index range <>) of index;

   package elementary_functions is new
      ada.numerics.generic_elementary_functions (
      real);

   error_mismatch_index : exception;

   function max (a : real_array; b : index_array) return real with inline;
    function min (a : real_array; b : index_array) return real with inline;
   ----------------
   -- Statistics --
   ----------------
   -- 1st raw moment
   function mean (a : real_array; b : index_array) return real with inline;

   -- 2nd central moment
   function variance (a : real_array; b : index_array) return real with inline;

   function standard_deviation (a : real_array;  b : index_array)
   return real with inline;
   
   function central_moment (a : real_array; b : index_array; n : positive)
    return real with inline;

   function normalized_moment (a : real_array; b : index_array; n : positive)
   return real with inline;
    -- mode

   ---------------
   -- Distances --
   ---------------
   function squared_euclidean_distance(a,b:real_array) return real with inline;

   function euclidean_distance(a,b:real_array) return real with inline;

   function manhattan_distance(a,b:real_array) return real with  inline;

   function sup_distance(a,b:real_array) return real with  inline;

   function cosine_distance(a,b:real_array) return real with inline;

-- hamming_distance
-- simple_matching_distance

end ai.primitive;
