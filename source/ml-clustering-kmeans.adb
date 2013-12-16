pragma License (GPL);
with ML.Primitive;
with Ada.Unchecked_Deallocation;
with Ada.Text_IO;

package body ML.Clustering.Kmeans is
   package MLP renames ML.Primitive;
   procedure free is new Ada.Unchecked_Deallocation
      (Real_Array, Real_Array_Access);
   procedure free is new Ada.Unchecked_Deallocation
      (Index_Array, Index_Array_Access);

   procedure finalize (o : in out Object) is
   begin
      if o.Withins = null then
         return;
      end if;
      for c of o.Centroids loop
         free (c);
      end loop;
      free (o.Withins);
   end finalize;

   procedure Run (o : in out Object; k : Positive; m : Positive := 10) is
      n : Index_Type := Index_Type (o.Items.Length);
   begin
      --  TODO raise exception
      if k < 2 or n < k then
         return;
      end if;

      declare
         updated : Boolean;
         dist    : Real;
         tmp     : Real;
         idx     : Index_Type;
      begin
         if o.Withins /= null then
            free (o.Withins);
         end if;
         o.Withins := new Index_Array (1 .. n);
         o.Withins.all := (others => 1);
         --  Initialze clusters
         --  TODO Randomize
         for j in 1 .. k loop
            o.Centroids (j) := new Real_Array'(o.Items.all (j));
            o.Clusters (j).Include (j);
            o.Withins (j) := j;
         end loop;

         Iterative :
         for jm in 1 .. m loop
            updated := False;
            Each_Item :
            for jn in 1 .. n loop
               --  for each vector A_{jn}, find a nearest center
               dist := Real'Last;
               for jk in 1 .. k loop
                  --  TODO Optimize this
                  tmp := MLP.Squared_Euclidean_Distance
                     (o.Items.all (jn), o.Centroids (jk).all);
                  if tmp < dist then
                     dist := tmp;
                     idx := jk;
                  end if;
               end loop;
               --  Migrate
               if not o.Clusters (idx).Contains (jn) then
                  o.Clusters (o.Withins (jn)).Exclude (jn);
                  o.Clusters (idx).Include (jn);
                  o.Withins (jn) := idx;
                  updated := True;
               end if;
            end loop Each_Item;

            exit Iterative when not updated;
            --  update centroid
            for j in 1 .. k loop
               o.Centroids (j).all := (others => 0.0);
               for jj of o.Clusters (j)  loop
                  Add (o.Centroids (j).all, o.Items.all (jj));
               end loop;
               Divide (o.Centroids (j).all, Real (o.Clusters (j).Length));
            end loop;
            o.Iter := jm;
         end loop Iterative;

         WSS_BSS :
         declare
            r : Real_Array_Access;
            m : Real_Array (o.Centroids (1)'Range) := (others => 0.0);
         begin
            for j in 1 .. k loop
               r := o.Centroids (j);
               for jj of o.Clusters (j)  loop
                  o.WSS (j) := o.WSS (j) + MLP.Squared_Euclidean_Distance
                     (o.Centroids (j).all, o.Items.all (jj));
               end loop;
            end loop;
            for j in 1 .. n loop
               Add (m, o.Items.all (j));
            end loop;
            Divide (m, Real (n));
            o.BSS := 0.0;
            for j in 1 .. k loop
               o.BSS := o.BSS +
               MLP.Squared_Euclidean_Distance (o.Centroids (j).all, m) *
               Real (o.Clusters (j).Length);
            end loop;
         end WSS_BSS;
      end;
   end Run;

   procedure Put (o : in Object) is
      use Ada.Text_IO;
   begin
      if o.Withins = null then
         return;
      end if;
      Put ("K-means clustering with " & o.k'Img & " clusters of sizes ");
      for c of o.Clusters loop
         Put (c.Length'Img);
      end loop;
      New_Line (2);
      Put_Line ("Cluster means:");
      for j in 1 .. o.k loop
         Put ("[" & j'Img & "]" & ASCII.HT);
         for e of o.Centroids (j).all loop
            Put (e'Img);
         end loop;
         New_Line;
      end loop;
      New_Line;
      Put_Line ("Clustering vector:");
      for c of o.Withins.all loop
         Ada.Text_IO.Put (c'Img);
      end loop;
      New_Line (2);
      Put_Line ("Within cluster sum of squares by cluster:");
      for c of o.WSS loop
         Ada.Text_IO.Put (c'Img);
      end loop;
      New_Line;
      Put_Line ("(between_SS / total_SS =  "
      & Real'Image (o.BSS * 100.0 / (MLP.Sum (o.WSS) + o.BSS)) & " %)");
      New_Line;
      Put_Line ("Iterated " & o.Iter'Img & " times");
   end Put;

end ML.Clustering.Kmeans;

