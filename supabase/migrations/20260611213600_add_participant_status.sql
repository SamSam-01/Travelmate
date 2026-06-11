ALTER TABLE "public"."planned_outing_participants"
ADD COLUMN "status" text NOT NULL DEFAULT 'pending'
CHECK ("status" IN ('pending', 'accepted', 'declined'));

CREATE POLICY "Users can update their own participation status"
ON "public"."planned_outing_participants"
FOR UPDATE TO "authenticated"
USING ("profile_id" = "auth"."uid"())
WITH CHECK ("profile_id" = "auth"."uid"());
