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
      x : Byte_Access        := null;
      y : Index_Array_Access := null;
      z : Short_Array_Access := null;
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

   procedure Reset (o : in out Object) with Inline;
   function Get_Cluster (o : Object; j : Positive; t : Integer)
      return Positive with Inline;
   procedure Set_Cluster (o : in out Object; j : Positive;
      c : Positive; t : Integer) with Inline;

   procedure Initialize (o : in out Object) is
   begin
      o.Centroids := new Element_Array (1 .. o.k);
      o.WSS       := new Scalar_Array (1 .. o.k);
      o.Sizes     := new Index_Array (1 .. o.k);

      o.Centroids.all := (others => (others => 0.0));
      o.WSS.all       := (others => 0.0);
      o.Sizes.all     := (others => Integer'Last);
      o.Clusters      := null;
      o.BSS           := 0.0;
      o.Iter          := 0;
   end Initialize;

   procedure Finalize (o : in out Object) is
   begin
      Free (o.WSS);
      Free (o.Sizes);
      Free (o.Centroids);
      if o.Clusters /= null then
         if o.Clusters.x /= null then
            Free (o.Clusters.x);
         elsif o.Clusters.y /= null then
            Free (o.Clusters.y);
         elsif o.Clusters.z /= null then
            Free (o.Clusters.z);
         end if;
         Free (o.Clusters);
      end if;
   end Finalize;

   procedure Reset (o : in out Object) is
   begin
      if o.Clusters /= null then
         if o.Clusters.x /= null then
            Free (o.Clusters.x);
         elsif o.Clusters.y /= null then
            Free (o.Clusters.y);
         elsif o.Clusters.z /= null then
            Free (o.Clusters.z);
         end if;
         Free (o.Clusters);
      end if;

      o.Centroids.all := (others => (others => 0.0));
      o.WSS.all       := (others => 0.0);
      o.BSS           := 0.0;
      o.Iter          := 0;
   end Reset;

   function Get_Cluster (o : Object; j : Positive; t : Integer)
      return Positive is
   begin
      case t is
         when 1 => return Positive (o.Clusters.x (j));
         when 2 => return Positive (o.Clusters.y (j));
         when others => return Positive (o.Clusters.z (j));
      end case;
   end Get_Cluster;

   procedure Set_Cluster (o : in out Object; j : Positive;
                          c : Positive; t : Integer) is
   begin
      case t is
         when 1 => o.Clusters.x (j) := Byte (c);
         when 2 => o.Clusters.y (j) := Positive (c);
         when others => o.Clusters.z (j) := Short_Integer (c);
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
         t       : Integer;
      begin
         --  Reinitialize if we run again
         if o.Clusters /= null then
            Reset (o);
         end if;

         o.Clusters := new Cluster_Type;
         case t is
            when 1      => o.Clusters.x := new Byte_Array (1 .. n);
            o.Clusters.x.all := (others => 0);
            when 2      => o.Clusters.y := new Index_Array (1 .. n);
            o.Clusters.y.all := (others => 0);
            when others => o.Clusters.z := new Short_Array (1 .. n);
            o.Clusters.z.all := (others => 0);
         end case;

         t := (if o.k < 256 then 1 else 0) +
            (if o.k >= Positive (Short_Integer'Last) then 2 else 0);

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
                     if Get_Cluster (o, c, t) = jj then
                        done := False;
                     end if;
                  end loop;
                  exit when done;
               end loop;

               o.Centroids (j) := Element (c);
               Set_Cluster (o, c, j, t);
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
               if Get_Cluster (o, jn, t) /= idx then
                  if Get_Cluster (o, jn, t) /= 0 then
                     o.Sizes (Get_Cluster (o, jn, t)) :=
                        o.Sizes (Get_Cluster (o, jn, t)) - 1;
                  end if;
                  o.Sizes (idx)   := o.Sizes (idx) + 1;
                  Set_Cluster (o, jn, idx, t);
                  updated         := True;
               end if;
            end loop Each_Item;

            exit Iterative when not updated;

            --  update centroids
            o.Centroids.all := (others => (others => 0.0));
            for j in 1 .. n loop
               MLP.Add (o.Centroids (Get_Cluster (o, j, t)), Element (j));
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
               w := Get_Cluster (o, j, t);
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
      t       : Integer := (if o.k < 256 then 1 else 0) +
      (if o.k >= Positive (Short_Integer'Last) then 2 else 0);
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
         Ada.Text_IO.Put (Get_Cluster (o, c, t) 'Img);
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
