pragma License (GPL);
with ML.Primitive;
with Ada.Unchecked_Deallocation;
with Ada.Numerics.Discrete_Random;
with Ada.Containers.Ordered_Sets;
with Ada.Text_IO;

package body ML.Clustering.Kmeans is
   package MLP is new ML.Primitive (Dim_Type, Element_Type);
   function SED (a, b : Element_Type) return Real
      renames MLP.Squared_Euclidean_Distance;

   package ANDR is new Ada.Numerics.Discrete_Random (Positive);
   package Index_Set is new Ada.Containers.Ordered_Sets (Positive);
   type Element_Array is array (Positive range <>) of Element_Type;
   type Real_Array    is array (Positive range <>) of Real;
   type Index_Array   is array (Positive range <>) of Positive;
   type Cluster_Array is array (Positive range <>) of Index_Set.Set;

   procedure Free is new Ada.Unchecked_Deallocation
      (Element_Array, Element_Array_Access);
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
      o.Clusters  := new Cluster_Array (1 .. o.k);
      o.Centroids := new Element_Array (1 .. o.k);
      o.WSS       := new Real_Array (1 .. o.k);

      o.Centroids.all := (others => (others => 0.0));
      o.WSS.all       := (others => 0.0);
      o.Withins       := null;
      o.BSS           := 0.0;
      o.Iter          := 0;
   end Initialize;

   procedure Finalize (o : in out Object) is
   begin
      Free (o.Clusters);
      Free (o.WSS);

      if o.Withins /= null then
         Free (o.Withins);
      end if;

      Free (o.Centroids);
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

      o.Centroids.all := (others => (others => 0.0));

      o.WSS.all   := (others => 0.0);
      o.BSS       := 0.0;
      o.Iter      := 0;
   end Reset;
   ----------------------------------------------------------------------------

   procedure Run (o : in out Object; m : Positive := 10) is
      n : Positive;
   begin
      if Length = 0 then
         raise Zero_N;
      end if;

      n := Positive (Length);

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
         idx     : Positive;
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
            c : Positive; --  centroid index
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

               o.Centroids (j) := Element (c);
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
                  tmp := SED(Element (jn), o.Centroids (jk));
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
               o.Centroids (j) := (others => 0.0);

               for jj of o.Clusters (j)  loop
                  for jjj in Dim_Type loop
                     o.Centroids (j) (jjj) :=
                        o.Centroids (j) (jjj) + Element (jj) (jjj);
                  end loop;
               end loop;
               for jj in Dim_Type loop
                  o.Centroids (j) (jj) :=
                     o.Centroids (j) (jj) / Real (o.Clusters (j).Length);
               end loop;
            end loop;
            o.Iter := jm;
         end loop Iterative;

         WSS_BSS :
         declare
            m : Element_Type := (others => 0.0);
         begin
            for j in o.Centroids'Range loop
               for jj of o.Clusters (j)  loop
                  o.WSS (j) := o.WSS (j) +
                     SED (o.Centroids (j), Element (jj));
               end loop;
            end loop;

            for j in 1 .. n loop
               for jj in Dim_Type loop
                  m (jj) := m (jj) + Element (j) (jj);
               end loop;
            end loop;

            for j in Dim_Type loop
               m (j) := m (j) / Real (n);
            end loop;
            o.BSS := 0.0;

            for j in o.Centroids'Range loop
               o.BSS := o.BSS + 
                  SED (o.Centroids (j), m) * Real (o.Clusters (j).Length);
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
         for e of o.Centroids (j) loop
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
      declare
         s : Real := 0.0;
      begin
         for c of o.WSS.all loop
            s := s + c;
         end loop;
         s := o.BSS * 100.0 / (s + o.BSS);
         Put_Line ("(between_SS / total_SS =  " & s'Img & " %)");
      end;
      New_Line;
      Put_Line ("Iterated " & o.Iter'Img & " times");
   end Put;

end ML.Clustering.Kmeans;
