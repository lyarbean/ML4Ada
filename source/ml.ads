pragma License (GPL);
with Ada.Containers.Indefinite_Vectors;

package ML is
   -------------
   --  Types  --
   -------------
   type Real is new Long_Long_Float;
   type Distribution_Type is (Normal, Log_Normal);
end ML;
