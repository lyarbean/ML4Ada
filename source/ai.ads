package AI is
   type Real is new Long_Long_Float;
   type Index_Type is new Integer;
   type Real_Array is array (Index_Type range <>) of Real;
   type Index_Array is array (Index_Type range <>) of Index_Type;
end AI;
