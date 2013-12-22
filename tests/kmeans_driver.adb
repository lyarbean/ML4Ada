with ML.Clustering.Kmeans;
with Ada.Containers.Vectors;

procedure kmeans_driver is
   type My_Dim is (x, y);
   type My_Point is array (My_Dim) of Long_Float;
   package My_Vector is new  Ada.Containers.Vectors (Positive, My_Point);

   data : My_Vector.Vector;

   function Length return Integer;
   function Element (x : Positive) return My_Point;

   function Length return Integer is
   begin
      if data.Is_Empty then
         return 0;
      end if;
      return Integer (data.Length);
   end Length;

   function Element (x : Positive) return My_Point is
   begin
      return data.Element (x);
   end Element;

   package Kmeans is new ML.Clustering.Kmeans
      (Long_Float, My_Dim, My_Point, Length, Element);

   kmeans_obj : Kmeans.Object (3);
begin
   data.Append ((1.15051216, 0.472122276));
   data.Append ((1.09239598, 0.636432058));
   data.Append ((1.63273494, 0.944266883));
   data.Append ((1.47341322, 0.127732792));
   data.Append ((1.05773555, 2.737441116));
   data.Append ((1.86009701, 0.235754348));
   data.Append ((1.86189074, 2.370561005));
   data.Append ((1.13529958, 0.359877942));
   data.Append ((1.29449350, 0.732107572));
   data.Append ((1.46069898, 0.917935191));
   data.Append ((1.92692308, 0.728487639));
   data.Append ((1.04758128, 0.830907185));
   data.Append ((1.49585697, 0.754649555));
   data.Append ((0.31762318, 0.089460726));
   data.Append ((1.84172809, 0.411763131));
   data.Append ((0.49856196, 0.053693391));
   data.Append ((0.36886585, 2.309107820));
   data.Append ((1.65142856, 1.478849825));
   data.Append ((2.64375353, 2.464321685));
   data.Append ((0.22912256, 0.859418721));
   data.Append ((0.29055744, 2.018153195));
   data.Append ((0.61883246, 1.781105353));
   data.Append ((0.43476090, 2.497923409));
   data.Append ((1.65722921, 0.474870022));
   data.Append ((0.52646230, 0.348672552));
   data.Append ((2.29263359, 0.780259759));
   data.Append ((0.41005850, 1.625880654));
   data.Append ((0.74438341, 0.826952697));
   data.Append ((1.70730825, 0.001825889));
   data.Append ((0.37378312, 0.876119264));
   data.Append ((0.44424768, 1.197617793));
   data.Append ((2.98833321, 0.710153296));
   data.Append ((2.47589652, 0.803730348));
   data.Append ((0.67208442, 1.052753027));
   data.Append ((0.20884590, 0.448115218));
   data.Append ((0.98169702, 0.898125705));
   data.Append ((0.36166799, 0.821921474));
   data.Append ((0.22665173, 0.960632685));
   data.Append ((0.78678705, 0.434142612));
   data.Append ((0.93713365, 0.371491168));
   data.Append ((0.62550778, 0.186665081));
   data.Append ((0.68691922, 0.761313227));
   data.Append ((0.98631066, 0.789352658));
   data.Append ((0.45111422, 0.559994510));
   data.Append ((0.24191797, 0.410229031));
   data.Append ((0.24438946, 0.402182698));
   data.Append ((0.63817275, 0.491253224));
   data.Append ((0.32893477, 0.637998218));
   data.Append ((0.77677226, 0.017112272));
   data.Append ((0.33214128, 0.328192015));
   Kmeans.Run (kmeans_obj, 12);
   Kmeans.Run (kmeans_obj, 12);
   Kmeans.Run (kmeans_obj, 12);
   Kmeans.Run (kmeans_obj, 12);
   Kmeans.Put (kmeans_obj);
   data.Append ((6.33214128, 1.328192015));
   Kmeans.Run (kmeans_obj, 12);
   Kmeans.Put (kmeans_obj);
end kmeans_driver;
