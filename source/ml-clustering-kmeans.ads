pragma License (GPL);
with Ada.Containers.Ordered_Sets;
with Ada.Finalization;
generic
   type Dim_Type is (<>);
   type Element_Type is array (Dim_Type) of Real;
   with function Length return Natural;
   with function Element (x : Positive) return Element_Type;

package ML.Clustering.Kmeans is
   type Object (k : Positive) is new Ada.Finalization.Limited_Controlled
   with private;
   procedure Run (o : in out Object; m : Positive := 10);
   procedure Put (o : Object);
   Small_K,  Huge_K, Zero_N : exception;

private
   type Element_Array is array (Positive range <>) of Element_Type;
   type Element_Array_Access is access Element_Array;
   type Real_Array_Access is access Real_Array;

   package Index_Set is new Ada.Containers.Ordered_Sets (Positive);
   type Index_Array is array (Positive range <>) of Positive;
   type Index_Array_Access is access Index_Array;
   type Cluster_Array is array (Positive range <>) of Index_Set.Set;
   type Cluster_Array_Access is access Cluster_Array;

   type Object (k : Positive) is new Ada.Finalization.Limited_Controlled with
      record
         Clusters  : Cluster_Array_Access;
         Centroids : Element_Array_Access;
         WSS       : Real_Array_Access;
         Withins   : Index_Array_Access;
         BSS       : Real;
         Iter      : Integer;
      end record;
   overriding procedure Initialize (o : in out Object);
   overriding procedure Finalize   (o : in out Object);
end ML.Clustering.Kmeans;
