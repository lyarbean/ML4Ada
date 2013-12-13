with ai.primitive;
use ai.primitive;
with ada.text_io;
use ada.text_io;

procedure primitive_driver is
    s1 : real_array(1..10) := (2.4, 2.5, 7.6, 1.3, 2.5, 7.6, 3.4, 5.6, 0.2, 0.7); 
    s2 : real_array(1..10) := (2.7, 1.5, 9.6, -0.3, 6.5, 8.2, 6.1, -8.6, 9.2, -10.7); 
    type index_10 is new index_array(1..10);
    ind : index_array(1..10) := (1,2,3,4,5,6,7,8,9,10);
    
begin
    put_line ( real'image(s1(1)**4) & real'image(elementary_functions.log(s1(2))) );
    put_line ( "max of s1: " & max(s1,ind)'img);
    put_line ( "min of s1: " & min(s1,ind)'img);
    put_line ( "mean of s1: " & mean(s1,ind)'img);
    put_line ( "variance of s1: " & variance(s1,ind)'img);
    put_line ( "standard_deviation of s1: " & standard_deviation(s1,ind)'img);
    put_line ( "3rd central_moment of s1: " & central_moment(s1,ind,3)'img);
    put_line ( "3rd normalized_moment of s1: " & normalized_moment(s1,3)'img);
    put_line ( "3rd normalized_moment of s1: " & normalized_moment(s1,ind,3)'img);
end primitive_driver;
