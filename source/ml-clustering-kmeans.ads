pragma License (GPL);
with Ada.Containers.Ordered_Sets;
with Ada.Finalization;

package AI.Clustering.Kmeans is
   type Object (k : Index_Type; Items : not null Real_Array_Vector_Access) is
      new Ada.Finalization.Limited_Controlled with private;

   procedure Run (o : in out Object; k : Positive; m : Positive := 10);
   procedure Put (o : in Object);

   private

   package Index_Set is new Ada.Containers.Ordered_Sets (Index_Type);
   type Index_Array_Access is access Index_Array;
   type Cluster_Array is array (Index_Type range <>) of Index_Set.Set;
   type Centroid_Array is array (Index_Type range <>) of Real_Array_Access;

   type Object
      (k : Index_Type; Items : not null Real_Array_Vector_Access)
   is new Ada.Finalization.Limited_Controlled with record
      Clusters  : Cluster_Array (1 .. k);
      Centroids : Centroid_Array (1 .. k) := (others => null);
      WSS       : Real_Array (1 .. k)     := (others => 0.0);
      BSS       : Real                    := 0.0;
      Iter      : Integer                 := 0;
      Withins   : Index_Array_Access      := null;
   end record;
   overriding procedure finalize (o : in out Object);
end AI.Clustering.Kmeans;

