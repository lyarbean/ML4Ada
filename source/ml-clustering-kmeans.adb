pragma License (GPL);
with ML.Primitive;
with Ada.Unchecked_Deallocation;
with Ada.Numerics.Discrete_Random;
with Ada.Text_IO;

package body ML.Clustering.Kmeans is
   package MLP renames ML.Primitive;
   package ANDR is new Ada.Numerics.Discrete_Random (Index_Type);
   procedure Free is new Ada.Unchecked_Deallocation
      (Real_Array, Real_Array_Access);
   procedure Free is new Ada.Unchecked_Deallocation
      (Index_Array, Index_Array_Access);

   procedure Initialize (o : in out Object) is
   begin
      o.Centroids := (others => null);
      o.WSS := (others => 0.0);
      o. Withins := null;
      o.BSS := 0.0;
      o.Iter := 0;
   end Initialize;
   procedure Finalize (o : in out Object) is
   begin
      if o.Withins = null then
         return;
      end if;
      for c of o.Centroids loop
         Free (c);
      end loop;
      Free (o.Withins);
   end Finalize;

   procedure Run (o : in out Object; m : Positive := 10) is
      n : Index_Type := Index_Type (o.Items.Length);
   begin
      if o.k < 2  then
         raise SMALL_K;
      end if;

      if n < o.k then
         raise HUGE_K;
      end if;

      declare
         updated : Boolean;
         dist    : Real;
         tmp     : Real;
         idx     : Index_Type;
         g       : ANDR.Generator;
      begin
         if o.Withins /= null then
            Free (o.Withins);
         end if;
         o.Withins := new Index_Array (1 .. n);
         o.Withins.all := (others => 1);


         Initialize_Centroids :
         declare
            c : Index_Type; --  centroid
         begin
            ANDR.Reset (g);

            for j in o.Centroids'Range loop
               <<ReGen>>
               c := (ANDR.Random (g) mod n) + 1;
               for jj in 1 .. j - 1 loop
                  if o.Clusters (jj).Contains (c) then
                     goto ReGen;
                  end if;
               end loop;
               o.Centroids (j) := new Real_Array'(o.Items.all (c));
               o.Clusters (j).Include (c);
               o.Withins (c) := j;
            end loop;
         end Initialize_Centroids;
         Iterative :
         for jm in 1 .. m loop
            updated := False;
            Each_Item :
            for jn in 1 .. n loop
               --  Find a nearest cluster for jn
               dist := Real'Last;
               for jk in o.Centroids'Range loop
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

            --  update centroids
            for j in o.Centroids'Range loop
               o.Centroids (j).all := (others => 0.0);
               for jj of o.Clusters (j)  loop
                  MLP.Add (o.Centroids (j).all, o.Items.all (jj));
               end loop;
               MLP.Divide (o.Centroids (j).all, Real (o.Clusters (j).Length));
            end loop;
            o.Iter := jm;
         end loop Iterative;

         WSS_BSS :
         declare
            r : Real_Array_Access;
            m : Real_Array (o.Centroids (1)'Range) := (others => 0.0);
         begin
            for j in o.Centroids'Range loop
               r := o.Centroids (j);
               for jj of o.Clusters (j)  loop
                  o.WSS (j) := o.WSS (j) + MLP.Squared_Euclidean_Distance
                     (o.Centroids (j).all, o.Items.all (jj));
               end loop;
            end loop;
            for j in 1 .. n loop
               MLP.Add (m, o.Items.all (j));
            end loop;
            MLP.Divide (m, Real (n));
            o.BSS := 0.0;
            for j in o.Centroids'Range loop
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

