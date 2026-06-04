alter table "public"."planned_outing_activities" add column "google_place_id" text;

alter table "public"."planned_outing_activities" add column "google_place_name" text;

alter table "public"."planned_outing_activities" alter column "activity_id" drop not null;

alter table "public"."planned_outing_activities" add constraint "planned_outing_activities_activity_source_check" CHECK (((activity_id IS NOT NULL) OR ((google_place_id IS NOT NULL) AND (btrim(google_place_id) <> ''::text)))) not valid;

alter table "public"."planned_outing_activities" validate constraint "planned_outing_activities_activity_source_check";


  create policy "Activities are viewable by everyone"
  on "public"."activities"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Users can view activities of planned outings"
  on "public"."planned_outing_activities"
  as permissive
  for select
  to authenticated
using (true);



