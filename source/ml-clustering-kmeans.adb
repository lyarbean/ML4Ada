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
   type Scalar_Array  is array (Positive range <>) of Scalar_Type;
   type Index_Array   is array (Positive range <>) of Integer;
   type Short_Array   is array (Positive range <>) of Short_Integer;
   type Short_Array_Access is access Short_Array;
   type Byte is mod 2 ** 8;
   for Byte'Size use 8;
   type Byte_Array is array (Positive range <>) of Byte;
   type Byte_Access is access Byte_Array;

   type Cluster_Type is record
      t : Integer            := Integer'Last;
      x : Byte_Access        := null;
      y : Short_Array_Access := null;
      z : Index_Array_Access := null;
   end record;

   procedure Free is new Ada.Unchecked_Deallocation
      (Element_Array, Element_Array_Access);
   procedure Free is new Ada.Unchecked_Deallocation
      (Scalar_Array, Scalar_Array_Access);
   procedure Free is new Ada.Unchecked_Deallocation
      (Index_Array, Index_Array_Access);
   procedure Free is new Ada.Unchecked_Deallocation
      (Byte_Array, Byte_Access);
   procedure Free is new Ada.Unchecked_Deallocation
      (Short_Array, Short_Array_Access);
   procedure Free is new Ada.Unchecked_Deallocation
      (Cluster_Type, Cluster_Access);

   procedure Reset (o : in out Object; n : Positive) with Inline;
   function Get_Cluster (o : Object; j : Positive) return Integer with Inline;
   procedure Set_Cluster
      (o : in out Object; j : Positive; c : Positive) with Inline;

   procedure Initialize (o : in out Object) is
   begin
      o.Centroids := new Element_Array (1 .. o.k);
      o.WSS       := new Scalar_Array (1 .. o.k);
      o.Sizes     := new Index_Array (1 .. o.k);
      o.Clusters  := new Cluster_Type;

      --  Byte => 0, Short => 1, Index => 2
      o.Clusters.t := (if o.k < 256 then 0 else 1) +
      (if o.k >= Positive (Short_Integer'Last) then 2 else 0);

      o.Centroids.all := (others => (others => 0.0));
      o.WSS.all       := (others => 0.0);
      o.Sizes.all     := (others => Integer'Last);
      o.BSS           := 0.0;
      o.Iter          := 0;
   end Initialize;

   procedure Finalize (o : in out Object) is
   begin
      Free (o.WSS);
      Free (o.Sizes);
      Free (o.Centroids);
      if o.Clusters.x /= null then
         Free (o.Clusters.x);
      elsif o.Clusters.y /= null then
         Free (o.Clusters.y);
      elsif o.Clusters.z /= null then
         Free (o.Clusters.z);
      end if;
      Free (o.Clusters);
   end Finalize;

   procedure Reset (o : in out Object; n : Positive) is
   begin
      case o.Clusters.t is
         when 0 =>
            if o.Clusters.x /= null and then n /= o.Clusters.x'Length then
               Free (o.Clusters.x);
               o.Clusters.x := null;
            end if;
            if o.Clusters.x = null then
               o.Clusters.x := new Byte_Array (1 .. n);
            end if;
            o.Clusters.x.all := (others => 0);

         when 1 =>
            if o.Clusters.y /= null and then n /= o.Clusters.y'Length then
               Free (o.Clusters.y);
               o.Clusters.y := null;
            end if;
            if o.Clusters.y = null then
               o.Clusters.y := new Short_Array (1 .. n);
            end if;
            o.Clusters.y.all := (others => 0);

         when 2 =>
            if o.Clusters.z /= null and then n /= o.Clusters.z'Length then
               Free (o.Clusters.z);
               o.Clusters.z := null;
            end if;
            if o.Clusters.z = null then
               o.Clusters.z := new Index_Array (1 .. n);
            end if;
            o.Clusters.z.all := (others => 0);

         when others => raise Program_Error;
      end case;
      o.Centroids.all := (others => (others => 0.0));
      o.WSS.all       := (others => 0.0);
      o.BSS           := 0.0;
      o.Iter          := 0;
   end Reset;

   function Get_Cluster (o : Object; j : Positive)
      return Integer is
   begin
      case o.Clusters.t is
         when 0 =>
            if j not in o.Clusters.x'Range then
               raise Program_Error;
            end if;
            return Integer (o.Clusters.x (j));
         when 1 =>
            if j not in o.Clusters.y'Range then
               raise Program_Error;
            end if; return Integer (o.Clusters.y (j));
         when others =>
            if j not in o.Clusters.z'Range then
               raise Program_Error;
            end if;
            return Integer (o.Clusters.z (j));
      end case;
   end Get_Cluster;

   procedure Set_Cluster
      (o : in out Object; j : Positive; c : Positive) is
   begin
      case o.Clusters.t is
         when 0      => o.Clusters.x (j) := Byte (c);
         when 1      => o.Clusters.y (j) := Short_Integer (c);
         when others => o.Clusters.z (j) := Integer (c);
      end case;
   end Set_Cluster;

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
         idx     : Positive := Positive'Last;
         g       : ANDR.Generator;
         mean    : Element_Type := (others => 0.0);
      begin
         --  Reinitialize if we run again
         Reset (o, n);
         ANDR.Reset (g);

         Initialize_Centroids :
         declare
            c    : Positive; --  centroid index
            done : Boolean;
         begin
            --  Compute sample mean
            for j in 1 .. n loop
               MLP.Add (mean, Element (j));
            end loop;

            MLP.Divide (mean, Scalar_Type (n));

            for j in 1 .. o.k loop
               loop
                  done := True;
                  c := (ANDR.Random (g) mod n) + 1;
                  for jj in 1 .. j loop
                     if Get_Cluster (o, c) = jj then
                        done := False;
                     end if;
                  end loop;
                  exit when done;
               end loop;

               o.Centroids (j) := Element (c);
               Set_Cluster (o, c, j);
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
                  tmp := SED (Element (jn), o.Centroids (jk));
                  if tmp < dist then
                     dist := tmp;
                     idx := jk;
                  end if;
               end loop;

               --  Migrate
               if Get_Cluster (o, jn) /= idx then
                  if Get_Cluster (o, jn) /= 0 then
                     o.Sizes (Get_Cluster (o, jn)) :=
                        o.Sizes (Get_Cluster (o, jn)) - 1;
                  end if;
                  o.Sizes (idx)   := o.Sizes (idx) + 1;
                  Set_Cluster (o, jn, idx);
                  updated         := True;
               end if;
            end loop Each_Item;

            exit Iterative when not updated;

            --  update centroids
            o.Centroids.all := (others => (others => 0.0));
            for j in 1 .. n loop
               MLP.Add (o.Centroids (Get_Cluster (o, j)), Element (j));
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
               w := Get_Cluster (o, j);
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
      if o.Clusters = null then
         return;
      end if;

      Put ("K-means clustering with " & o.k'Img & " Clusters of sizes ");

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

      for c in 1 .. Length loop
         Ada.Text_IO.Put (Get_Cluster (o, c) 'Img);
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
