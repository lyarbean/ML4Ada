with ML.Primitive;
use ML.Primitive;
with Ada.Text_IO;
use Ada.Text_IO;

procedure primitive_driver is
   use ML;
   s1 : Real_Array (1 .. 10)
      := (2.4, 2.5, 7.6, 1.3, 2.5, 7.6, 3.4, 5.6, 0.2, 0.7);
   s2 : Real_Array (1 .. 10)
      := (2.7, 1.5, 9.6, -0.3, 6.5, 8.2, 6.1, -8.6, 9.2, -10.7);
   ind : Index_Array (1 .. 10) := (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

begin
   Put_Line (Real'Image (s1 (1) ** 4) &
             Real'Image (ML_Elementary_Functions.Log (s1 (2))));
   Put_Line ("max of s1: " & Max (s1, ind)'Img);
   Put_Line ("min of s1: " & Min (s1, ind)'Img);
   Put_Line ("mean of s1: " & Mean (s1, ind)'Img);
   Put_Line ("variance of s1: " & Variance (s1, ind)'Img);
   Put_Line ("standard_deviation of s1: " & Standard_Deviation (s1, ind)'Img);
   Put_Line ("3rd central_moment of s1: " & Central_Moment (s1, ind, 3)'Img);
   Put_Line ("3rd normalized_moment of s1: " & Normalized_Moment (s1, 3)'Img);
   Put_Line ("3rd normalized_moment of s1: " &
             Normalized_Moment (s1, ind, 3)'Img);
   Put_Line (Real'Image (Normal (0.0, 4.0, 10.0)));
   Put_Line (Real'Image (Log_Normal (2.0, 4.0, 10.0)));
   Put_Line (Real'Image (Log_Normal (1.0, 4.0, 11.0)));
end primitive_driver;
