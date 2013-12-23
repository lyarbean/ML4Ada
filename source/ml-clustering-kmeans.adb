pragma License (GPL);
with ML.Primitive;
with ML.Primitive.Vector;
with Ada.Unchecked_Deallocation;
with Ada.Numerics.Discrete_Random;
with Ada.Text_IO;

package body ML.Clustering.Kmeans is
   package P is new ML.Primitive (Scalar_Type);
   package MLP is new P.Vector (Dim_Type, Element_Type);
   function SED (a, b : Element_Type) return Scalar_Type
      renames MLP.Squared_Euclidean_Distance;

   package ANDR is new Ada.Numerics.Discrete_Random (Positive);
   type Element_Array is array (Positive range <>) of Element_Type;
   type Scalar_Array    is array (Positive range <>) of Scalar_Type;
   type Index_Array   is array (Positive range <>) of Positive;

   procedure Free is new Ada.Unchecked_Deallocation
      (Element_Array, Element_Array_Access);
   procedure Free is new Ada.Unchecked_Deallocation
      (Scalar_Array, Scalar_Array_Access);
   procedure Free is new Ada.Unchecked_Deallocation
      (Index_Array, Index_Array_Access);

   ----------------------------------------------------------------------------
   procedure Reset (o : in out Object) with Inline;
   ----------------------------------------------------------------------------
   procedure Initialize (o : in out Object) is
   begin
      o.Centroids := new Element_Array (1 .. o.k);
      o.WSS       := new Scalar_Array (1 .. o.k);
      o.Sizes     := new Index_Array (1 .. o.k);

      o.Centroids.all := (others => (others => 0.0));
      o.WSS.all       := (others => 0.0);
      o.Sizes.all     := (others => Positive'Last);
      o.Withins       := null;
      o.BSS           := 0.0;
      o.Iter          := 0;
   end Initialize;

   procedure Finalize (o : in out Object) is
   begin
      Free (o.WSS);
      Free (o.Sizes);
      Free (o.Centroids);
      if o.Withins /= null then
         Free (o.Withins);
      end if;
   end Finalize;

   procedure Reset (o : in out Object) is
   begin
      if o.Withins /= null then
         Free (o.Withins);
      end if;

      o.Centroids.all := (others => (others => 0.0));
      o.WSS.all       := (others => 0.0);
      o.BSS           := 0.0;
      o.Iter          := 0;
   end Reset;

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
         dist    : Scalar_Type;
         tmp     : Scalar_Type;
         idx     : Positive;
         g       : ANDR.Generator;
         mean    : Element_Type := (others => 0.0);
      begin
         --  Reinitialize if we run again
         if o.Withins /= null then
            Reset (o);
         end if;

         o.Withins := new Index_Array (1 .. n);
         o.Withins.all := (others => Positive'Last);
         Initialize_Centroids :
         declare
            c    : Positive; --  centroid index
            done : Boolean;
         begin
            for j in 1 .. n loop
               MLP.Add (mean, Element (j));
            end loop;

            --  Compute sample mean
            MLP.Divide (mean, Scalar_Type (n));
            ANDR.Reset (g);

            for j in 1 .. o.k loop
               loop
                  done := True;
                  c := (ANDR.Random (g) mod n) + 1;
                  for jj in 1 .. j loop
                     if o.Withins (c) = jj then
                        done := False;
                     end if;
                  end loop;
                  exit when done;
               end loop;

               o.Centroids (j) := Element (c);
               o.Withins (c)   := j;
               o.Sizes (j)     := 1;
            end loop;
         end Initialize_Centroids;

         Iterative :
         for jm in 1 .. m loop
            updated := False;

            Each_Item :
            for jn in 1 .. n loop
               --  Find a nearest cluster for jn
               dist := Scalar_Type'Last;

               for jk in o.Centroids'Range loop
                  --  TODO Optimize this
                  tmp := SED (Element (jn), o.Centroids (jk));
                  if tmp < dist then
                     dist := tmp;
                     idx := jk;
                  end if;
               end loop;

               --  Migrate
               if o.Withins (jn) /= idx then
                  if o.Withins (jn) /= Positive'Last then
                     o.Sizes (o.Withins (jn)) := o.Sizes (o.Withins (jn)) - 1;
                  end if;
                  o.Sizes (idx)  := o.Sizes (idx) + 1;
                  o.Withins (jn) := idx;
                  updated        := True;
               end if;
            end loop Each_Item;

            exit Iterative when not updated;

            --  update centroids

            o.Centroids.all := (others => (others => 0.0));
            for j in 1 .. n loop
               MLP.Add (o.Centroids (o.Withins (j)), Element (j));
            end loop;

            for j in o.Centroids'Range loop
               MLP.Divide (o.Centroids (j), Scalar_Type (o.Sizes (j)));
            end loop;

            o.Iter := jm;
         end loop Iterative;

         WSS_BSS :
         declare
            w : Positive;
         begin
            for j in 1 .. n loop
               w := o.Withins (j);
               o.WSS (w) := o.WSS (w) + SED (o.Centroids (w), Element (j));
            end loop;

            o.BSS := 0.0;

            for j in o.Centroids'Range loop
               o.BSS := o.BSS +
               SED (o.Centroids (j), mean) * Scalar_Type (o.Sizes (j));
            end loop;
         end WSS_BSS;
      end;
   end Run;

   procedure Put (o : Object) is
      use Ada.Text_IO;
   begin
      if o.Withins = null then
         return;
      end if;

      Put ("K-means clustering with " & o.k'Img & " clusters of sizes ");

      --  for c of o.Clusters.all loop
      --     Put (c.Length'Img);
      ---   end loop;
      for c of o.Sizes.all loop
         Put (c'Img);
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
         s : Scalar_Type := 0.0;
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
