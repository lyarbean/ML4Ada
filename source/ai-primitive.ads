pragma ada_12;

with ada.numerics.generic_elementary_functions;
package ai.primitive is
   type real is new long_long_float;
   type index is new integer;
   type real_array is array (index range <>) of real;
   type index_array is array (index range <>) of index;

   -- Math functions for real
   package elementary_functions is new
   ada.numerics.generic_elementary_functions (real);

   index_mismatched : exception;

   function max (a : real_array; b : index_array) return real with inline;
   function max (a : real_array) return real with inline;
   function min (a : real_array; b : index_array) return real with inline;
   function min (a : real_array) return real with inline;
   ----------------
   -- Statistics --
   ----------------

   -- 1st raw moment
   function mean (a : real_array; b : index_array) return real;

   -- 2nd central moment
   function variance (a : real_array; b : index_array) return real;

   function standard_deviation (a : real_array; b : index_array) return real;

   function central_moment (a : real_array; b : index_array; n : positive) return real;

   function normalized_moment (a : real_array; b : index_array; n : positive) return real;

   function normalized_moment (a : real_array; n : positive) return real;
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
