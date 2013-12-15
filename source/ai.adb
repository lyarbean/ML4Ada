package body AI is
   --  TODO Assert the same range!
   procedure Add (a : in out Real_Array;  b : in Real_Array) is
   begin
      for j in a'Range loop
         a (j) := a (j) + b (j);
      end loop;
   end Add;
   procedure Sub (a : in out Real_Array;  b : in Real_Array) is
   begin
      for j in a'Range loop
         a (j) := a (j) - b (j);
      end loop;
   end Sub;
   procedure Multiply (a : in out Real_Array; b : in Real) is
   begin
      for c of a loop
         c := c * b;
      end loop;
   end Multiply;
   procedure Divide (a : in out Real_Array; b : in Real) is
   begin
      for c of a loop
         c := c / b;
      end loop;
   end Divide;
   function "*" (a : Real_Array; b : Real) return Real_Array is
   begin
      return r : Real_Array := a do
         for c of r loop
            c := c * b;
         end loop;
      end return;
   end "*";
end AI;
