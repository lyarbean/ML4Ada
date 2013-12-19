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
   procedure Free is new Ada.Unchecked_Deallocation
      (Cluster_Array, Cluster_Array_Access);

   ----------------------------------------------------------------------------
   procedure Reset (o : in out Object) with Inline;
   ----------------------------------------------------------------------------
   procedure Initialize (o : in out Object) is
   begin
      o.Clusters := new Cluster_Array (1 .. o.k);
      o.Centroids := (others => null);
      o.WSS := new Real_Array (1 .. o.k);
      o.WSS.all := (others => 0.0);
      o.Withins := null;
      o.BSS := 0.0;
      o.Iter := 0;
   end Initialize;

   procedure Finalize (o : in out Object) is
   begin
      Free (o.Clusters);
      Free (o.WSS);

      if o.Withins /= null then
         Free (o.Withins);
      end if;

      for c of o.Centroids loop
         if c /= null then
            Free (c);
         end if;
      end loop;
   end Finalize;

   procedure Reset (o : in out Object) is
   begin
      for c of o.Clusters.all loop
         c.Clear;
      end loop;

      if o.Withins /= null then
         Free (o.Withins);
         o.Withins := null;
      end if;

      for c of o.Centroids loop
         if c /= null then
            Free (c);
         end if;
      end loop;

      o.WSS.all   := (others => 0.0);
      o.Centroids := (others => null);
      o.BSS       := 0.0;
      o.Iter      := 0;
   end Reset;
   ----------------------------------------------------------------------------

   procedure Run (o : in out Object; m : Positive := 10) is
      n : Index_Type;
   begin
      if Length = 0 then
         raise Zero_N;
      end if;

      n := Index_Type (Length);

      if o.k < 2 then
         raise Small_K;
      end if;

      if n < o.k then
         raise Huge_K;
      end if;

      declare
         updated : Boolean;
         dist    : Real;
         tmp     : Real;
         idx     : Index_Type;
         g       : ANDR.Generator;
      begin
         --  Reinitialize if we run again
         if o.Withins /= null then
            Reset (o);
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

               if o.Centroids (j) /= null then
                  raise Program_Error;
               end if;
               o.Centroids (j) := new Real_Array'(Element (c));

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
                     (Element (jn), o.Centroids (jk).all);
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
                  MLP.Add (o.Centroids (j).all, Element (jj));
               end loop;

               MLP.Divide (o.Centroids (j).all, Real (o.Clusters (j).Length));
            end loop;
            o.Iter := jm;
         end loop Iterative;

         WSS_BSS :
         declare
            m : Real_Array (o.Centroids (1)'Range) := (others => 0.0);
         begin
            for j in o.Centroids'Range loop
               for jj of o.Clusters (j)  loop
                  o.WSS (j) := o.WSS (j) + MLP.Squared_Euclidean_Distance
                     (o.Centroids (j).all, Element (jj));
               end loop;
            end loop;

            for j in 1 .. n loop
               MLP.Add (m, Element (j));
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
   ----------------------------------------------------------------------------

   procedure Put (o : Object) is
      use Ada.Text_IO;
   begin
      if o.Withins = null then
         return;
      end if;

      Put ("K-means clustering with " & o.k'Img & " clusters of sizes ");

      for c of o.Clusters.all loop
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

      for c of o.WSS.all loop
         Ada.Text_IO.Put (c'Img);
      end loop;

      New_Line;
      Put_Line ("(between_SS / total_SS =  "
      & Real'Image (o.BSS * 100.0 / (MLP.Sum (o.WSS.all) + o.BSS)) & " %)");
      New_Line;
      Put_Line ("Iterated " & o.Iter'Img & " times");
   end Put;

end ML.Clustering.Kmeans;
