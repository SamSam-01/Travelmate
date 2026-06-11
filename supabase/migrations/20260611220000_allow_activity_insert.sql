-- Allow authenticated users to insert custom activities (e.g. from map places) into the activities table.
CREATE POLICY "Users can insert activities" ON "public"."activities" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));
