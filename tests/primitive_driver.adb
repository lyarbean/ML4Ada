with AI.Primitive;
use AI.Primitive;
with Ada.Text_IO;
use Ada.Text_IO;

procedure primitive_driver is
   s1 : Real_Array (1 .. 10)
      := (2.4, 2.5, 7.6, 1.3, 2.5, 7.6, 3.4, 5.6, 0.2, 0.7);
   s2 : Real_Array (1 .. 10)
      := (2.7, 1.5, 9.6, -0.3, 6.5, 8.2, 6.1, -8.6, 9.2, -10.7);
   ind : Index_Array (1 .. 10) := (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);

begin
   Put_Line (Real'Image (s1 (1) ** 4) &
             Real'Image (Elementary_Functions.Log (s1 (2))));
   Put_Line ("max of s1: " & max (s1, ind)'Img);
   Put_Line ("min of s1: " & min (s1, ind)'Img);
   Put_Line ("mean of s1: " & mean (s1, ind)'Img);
   Put_Line ("variance of s1: " & variance (s1, ind)'Img);
   Put_Line ("standard_deviation of s1: " & standard_deviation (s1, ind)'Img);
   Put_Line ("3rd central_moment of s1: " & central_moment (s1, ind, 3)'Img);
   Put_Line ("3rd normalized_moment of s1: " & normalized_moment (s1, 3)'Img);
   Put_Line ("3rd normalized_moment of s1: " &
             normalized_moment (s1, ind, 3)'Img);
end primitive_driver;
