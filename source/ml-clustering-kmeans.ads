pragma License (GPL);
with Ada.Containers.Ordered_Sets;
with Ada.Finalization;

package ML.Clustering.Kmeans is
   type Object (k : Index_Type; Items : not null access Real_Array_Vector) is
      new Ada.Finalization.Limited_Controlled with private;

   procedure Run (o : in out Object; m : Positive := 10);
   procedure Put (o : in Object);
   SMALL_K,  HUGE_K : exception;
private

   package Index_Set is new Ada.Containers.Ordered_Sets (Index_Type);
   type Real_Array_Access is access Real_Array;
   type Index_Array_Access is access Index_Array;
   type Cluster_Array is array (Index_Type range <>) of Index_Set.Set;
   type Centroid_Array is array (Index_Type range <>) of Real_Array_Access;

   type Object
      (k : Index_Type; Items : not null access Real_Array_Vector)
   is new Ada.Finalization.Limited_Controlled with record
      Clusters  : Cluster_Array (1 .. k);
      Centroids : Centroid_Array (1 .. k) := (others => null);
      WSS       : Real_Array (1 .. k)     := (others => 0.0);
      BSS       : Real                    := 0.0;
      Iter      : Integer                 := 0;
      Withins   : Index_Array_Access      := null;
   end record;
   overriding procedure finalize (o : in out Object);
end ML.Clustering.Kmeans;

