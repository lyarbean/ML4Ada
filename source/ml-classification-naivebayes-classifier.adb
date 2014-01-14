pragma Ada_2012;
package body ML.Classification.Naivebayes.Classifier is
   procedure Train
      (Classifier : in out My_Classifier; Event :  Event_Type'Class) is
   begin
      if Event not in My_Event'Class then
         raise Mismatched_Event;
      end if;

      declare
         ME : My_Event renames My_Event (Event);
      begin
         Classifier.Score (ME.Class) := Classifier.Score (ME.Class) + 1.0;
         for f in Feature_Type loop
            Classifier.Prioris (ME.Class, f).Handle (ME.Cells (f).all);
         end loop;
      end;
   end Train;

   procedure Done (Classifier : in out My_Classifier) is
   begin
      for p of Classifier.Prioris loop
         p.Done;
      end loop;
   end Done;

   procedure Predict
      (Classifier : My_Classifier; Event : in out Event_Type'Class) is
      score : Score_Type;
   begin
      Predict (Classifier, Event, score);
   end Predict;

   procedure Predict (Classifier : My_Classifier;
      Event : in out Event_Type'Class; Score : out Score_Type) is
   begin
      Score :=  Predict (Classifier, Event);
      declare
         ME : My_Event renames My_Event (Event);
         s : Long_Float := -1.0;
      begin
         for c in Class_Type loop
            if Score (c) > s then
               s := Score (c);
               ME.Class := c;
            end if;
         end loop;
      end;
   end Predict;

   function Predict (Classifier : My_Classifier; Event : Event_Type'Class)
      return Score_Type is
   begin
      if Event not in My_Event'Class then
         raise Mismatched_Event;
      end if;
      return score : Score_Type do
         declare
            ME : My_Event renames My_Event (Event);
            s : Long_Float;
         begin
            score := (others => 1.0);
            for c in Class_Type loop
               for f in Feature_Type loop
                  score (c) := score (c) *
                  Classifier.Prioris (c, f).Priori (ME.Cells (f).all);
               end loop;
            end loop;

            s := 0.0;

            for c of score loop
               s := s + c;
            end loop;

            for c of score loop
               c := c / s;
            end loop;
         end;
      end return;
   end Predict;

end ML.Classification.Naivebayes.Classifier;
