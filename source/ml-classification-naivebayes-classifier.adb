pragma Ada_2012;
package body ML.Classification.Naivebayes.Classifier is
   procedure Train (Feature : in out My_Feature; Event :  Event_Type'Class) is
   begin
      if Event in My_Event'Class then
         declare
            ME : My_Event renames My_Event (Event);
         begin
            Feature.P (ME.C) := Feature.P (ME.C) + 1.0;
            for d in Feature_Dim loop
               Feature.F (ME.C, d).Handle (ME.E (d).all);
            end loop;
         end;
      end if;
   end Train;

   procedure Done (Feature : in out My_Feature) is
   begin
      for f of Feature.F loop
         f.Done;
      end loop;
   end Done;

   procedure Predict (Feature : My_Feature; Event : in out Event_Type'Class) is
   begin
      if Event not in My_Event'Class then
         raise Program_Error;
      end if;

      declare
         ME : My_Event renames My_Event (Event);
         p : Score_Type := (others => 1.0);
         s : Long_Float;
      begin
         for c in Class_Type loop
            for d in Feature_Dim loop
               p (c) := p (c) * Feature.F (c, d).Priori (ME.E (d).all);
            end loop;
         end loop;

         s := 0.0;
         for c of p loop
            s := s + c;
         end loop;

         for c of p loop
            c := c / s;
         end loop;

         s := 0.0;
         for j in Class_Type loop
            if p (j) > s then
               s := p (j);
               ME.C := j;
            end if;
         end loop;
      end;
   end Predict;

end ML.Classification.Naivebayes.Classifier;
