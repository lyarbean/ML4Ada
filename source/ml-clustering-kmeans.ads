pragma License (GPL);
with Ada.Containers.Ordered_Sets;
with Ada.Finalization;

package ML.Clustering.Kmeans is
   type Object (k : Index_Type) is
      new Ada.Finalization.Limited_Controlled with private;
   procedure Run (o : in out Object;
      items : Real_Array_Vector; m : Positive := 10);
   procedure Put (o : Object);
   Small_K,  Huge_K, Zero_N : exception;

private

   package Index_Set is new Ada.Containers.Ordered_Sets (Index_Type);
   type Real_Array_Access is access Real_Array;
   type Index_Array_Access is access Index_Array;
   type Cluster_Array is array (Index_Type range <>) of Index_Set.Set;
   type Cluster_Array_Access is access Cluster_Array;
   type Centroid_Array is array (Index_Type range <>) of Real_Array_Access;

   type Object (k : Index_Type) is
      new Ada.Finalization.Limited_Controlled with record
      Clusters  : Cluster_Array_Access;
      Centroids : Centroid_Array (1 .. k);
      WSS       : Real_Array_Access;
      Withins   : Index_Array_Access;
      BSS       : Real;
      Iter      : Integer;
   end record;
   overriding procedure Initialize (o : in out Object);
   overriding procedure Finalize (o : in out Object);
end ML.Clustering.Kmeans;
