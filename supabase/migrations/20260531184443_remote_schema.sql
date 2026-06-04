


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "private";


ALTER SCHEMA "private" OWNER TO "postgres";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "private"."handle_new_profile"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'auth'
    AS $$
begin
  insert into public.profiles (id, username, display_name, avatar_url, is_private, created_at)
  values (
    new.id,
    public.build_unique_username(
      coalesce(new.raw_user_meta_data ->> 'username', split_part(new.email, '@', 1), new.id::text),
      new.id
    ),
    coalesce(new.raw_user_meta_data ->> 'display_name', new.raw_user_meta_data ->> 'full_name'),
    new.raw_user_meta_data ->> 'avatar_url',
    true,
    coalesce(new.created_at, now())
  )
  on conflict (id) do update
  set
    username = excluded.username,
    display_name = coalesce(public.profiles.display_name, excluded.display_name),
    avatar_url = coalesce(public.profiles.avatar_url, excluded.avatar_url);

  return new;
end;
$$;


ALTER FUNCTION "private"."handle_new_profile"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "private"."set_friendships_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
begin
  new.updated_at := now();
  return new;
end;
$$;


ALTER FUNCTION "private"."set_friendships_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."build_unique_username"("base_value" "text", "user_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
declare
  candidate text;
begin
  candidate := public.normalize_username(base_value);

  if candidate = '' then
    candidate := 'user_' || substr(replace(user_id::text, '-', ''), 1, 8);
  end if;

  if exists (
    select 1
    from public.profiles
    where username = candidate
      and id <> user_id
  ) then
    candidate := candidate || '_' || substr(replace(user_id::text, '-', ''), 1, 4);
  end if;

  return candidate;
end;
$$;


ALTER FUNCTION "public"."build_unique_username"("base_value" "text", "user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."normalize_username"("value" "text") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE
    AS $$
  select trim(both '_' from regexp_replace(lower(coalesce(value, '')), '[^a-z0-9_.]+', '_', 'g'));
$$;


ALTER FUNCTION "public"."normalize_username"("value" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."activities" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "title" "text",
    "subtitle" "text",
    "badge" "text",
    "tone" "text",
    "icon_key" "text",
    "sort_order" bigint,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."activities" OWNER TO "postgres";


COMMENT ON TABLE "public"."activities" IS 'Activities offered by companies, used to create outings.';



CREATE TABLE IF NOT EXISTS "public"."friendships" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "requester_id" "uuid" NOT NULL,
    "addressee_id" "uuid" NOT NULL,
    "status" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "friendships_check" CHECK (("requester_id" <> "addressee_id")),
    CONSTRAINT "friendships_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'accepted'::"text", 'declined'::"text"])))
);


ALTER TABLE "public"."friendships" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."planned_outing_activities" (
    "id" bigint NOT NULL,
    "planned_outing_id" bigint NOT NULL,
    "activity_id" "uuid" NOT NULL,
    "time" "text" DEFAULT ''::"text" NOT NULL,
    "sort_order" integer DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."planned_outing_activities" OWNER TO "postgres";


ALTER TABLE "public"."planned_outing_activities" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."planned_outing_activities_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."planned_outing_participants" (
    "planned_outing_id" bigint NOT NULL,
    "profile_id" "uuid" NOT NULL
);


ALTER TABLE "public"."planned_outing_participants" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."planned_outings" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "users" json,
    "activities" json,
    "title" "text",
    "creator_id" "uuid" DEFAULT "auth"."uid"(),
    "visibility" "text" DEFAULT 'private'::"text" NOT NULL,
    "scheduled_for" timestamp with time zone,
    CONSTRAINT "planned_outings_visibility_check" CHECK (("visibility" = ANY (ARRAY['private'::"text", 'public'::"text"])))
);


ALTER TABLE "public"."planned_outings" OWNER TO "postgres";


ALTER TABLE "public"."planned_outings" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."planned_outings_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "username" "text" NOT NULL,
    "display_name" "text",
    "avatar_url" "text",
    "is_private" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "username_length" CHECK (("char_length"("username") >= 3))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."profile_search" WITH ("security_invoker"='on') AS
 SELECT "id",
    "username",
    "display_name"
   FROM "public"."profiles";


ALTER VIEW "public"."profile_search" OWNER TO "postgres";


ALTER TABLE ONLY "public"."activities"
    ADD CONSTRAINT "activities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."friendships"
    ADD CONSTRAINT "friendships_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."friendships"
    ADD CONSTRAINT "friendships_requester_id_addressee_id_key" UNIQUE ("requester_id", "addressee_id");



ALTER TABLE ONLY "public"."planned_outing_activities"
    ADD CONSTRAINT "planned_outing_activities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."planned_outing_participants"
    ADD CONSTRAINT "planned_outing_participants_pkey" PRIMARY KEY ("planned_outing_id", "profile_id");



ALTER TABLE ONLY "public"."planned_outings"
    ADD CONSTRAINT "planned_outings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_username_key" UNIQUE ("username");



CREATE UNIQUE INDEX "friendships_unique_pair_idx" ON "public"."friendships" USING "btree" (LEAST("requester_id", "addressee_id"), GREATEST("requester_id", "addressee_id"));



CREATE OR REPLACE TRIGGER "friendships_set_updated_at" BEFORE UPDATE ON "public"."friendships" FOR EACH ROW EXECUTE FUNCTION "private"."set_friendships_updated_at"();



ALTER TABLE ONLY "public"."friendships"
    ADD CONSTRAINT "friendships_addressee_id_fkey" FOREIGN KEY ("addressee_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."friendships"
    ADD CONSTRAINT "friendships_requester_id_fkey" FOREIGN KEY ("requester_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."planned_outing_activities"
    ADD CONSTRAINT "planned_outing_activities_activity_id_fkey" FOREIGN KEY ("activity_id") REFERENCES "public"."activities"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."planned_outing_activities"
    ADD CONSTRAINT "planned_outing_activities_planned_outing_id_fkey" FOREIGN KEY ("planned_outing_id") REFERENCES "public"."planned_outings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."planned_outing_participants"
    ADD CONSTRAINT "planned_outing_participants_planned_outing_id_fkey" FOREIGN KEY ("planned_outing_id") REFERENCES "public"."planned_outings"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."planned_outing_participants"
    ADD CONSTRAINT "planned_outing_participants_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Users can create planned outings" ON "public"."planned_outings" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can insert activities" ON "public"."planned_outing_activities" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can insert participants" ON "public"."planned_outing_participants" FOR INSERT WITH CHECK (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can view activities of their planned outings" ON "public"."planned_outing_activities" FOR SELECT USING (("planned_outing_id" IN ( SELECT "planned_outing_participants"."planned_outing_id"
   FROM "public"."planned_outing_participants"
  WHERE ("planned_outing_participants"."profile_id" = "auth"."uid"()))));



CREATE POLICY "Users can view participants of their planned outings" ON "public"."planned_outing_participants" FOR SELECT USING (("auth"."uid"() IS NOT NULL));



CREATE POLICY "Users can view planned outings they participate in" ON "public"."planned_outings" FOR SELECT USING ((("creator_id" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM "public"."planned_outing_participants"
  WHERE (("planned_outing_participants"."planned_outing_id" = "planned_outings"."id") AND ("planned_outing_participants"."profile_id" = "auth"."uid"()))))));



ALTER TABLE "public"."activities" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."friendships" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "friendships_insert_requester" ON "public"."friendships" FOR INSERT TO "authenticated" WITH CHECK ((("requester_id" = "auth"."uid"()) AND ("requester_id" <> "addressee_id")));



CREATE POLICY "friendships_select_participants" ON "public"."friendships" FOR SELECT TO "authenticated" USING ((("auth"."uid"() = "requester_id") OR ("auth"."uid"() = "addressee_id")));



CREATE POLICY "friendships_update_addressee_pending" ON "public"."friendships" FOR UPDATE TO "authenticated" USING ((("addressee_id" = "auth"."uid"()) AND ("status" = 'pending'::"text"))) WITH CHECK ((("addressee_id" = "auth"."uid"()) AND ("status" = ANY (ARRAY['accepted'::"text", 'declined'::"text"]))));



ALTER TABLE "public"."planned_outing_activities" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."planned_outing_participants" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."planned_outings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "profiles_insert_own" ON "public"."profiles" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "profiles_select_own_or_accepted_friend" ON "public"."profiles" FOR SELECT TO "authenticated" USING ((("auth"."uid"() = "id") OR (EXISTS ( SELECT 1
   FROM "public"."friendships"
  WHERE (("friendships"."status" = 'accepted'::"text") AND ((("friendships"."requester_id" = "auth"."uid"()) AND ("friendships"."addressee_id" = "profiles"."id")) OR (("friendships"."addressee_id" = "auth"."uid"()) AND ("friendships"."requester_id" = "profiles"."id"))))))));



CREATE POLICY "profiles_update_own" ON "public"."profiles" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "id")) WITH CHECK (("auth"."uid"() = "id"));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";








































































































































































GRANT ALL ON FUNCTION "public"."build_unique_username"("base_value" "text", "user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."build_unique_username"("base_value" "text", "user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."build_unique_username"("base_value" "text", "user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."normalize_username"("value" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."normalize_username"("value" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."normalize_username"("value" "text") TO "service_role";



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;












GRANT ALL ON TABLE "public"."activities" TO "anon";
GRANT ALL ON TABLE "public"."activities" TO "authenticated";
GRANT ALL ON TABLE "public"."activities" TO "service_role";



GRANT ALL ON TABLE "public"."friendships" TO "anon";
GRANT SELECT,INSERT,REFERENCES,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE "public"."friendships" TO "authenticated";
GRANT ALL ON TABLE "public"."friendships" TO "service_role";



GRANT ALL ON TABLE "public"."planned_outing_activities" TO "anon";
GRANT ALL ON TABLE "public"."planned_outing_activities" TO "authenticated";
GRANT ALL ON TABLE "public"."planned_outing_activities" TO "service_role";



GRANT ALL ON SEQUENCE "public"."planned_outing_activities_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."planned_outing_activities_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."planned_outing_activities_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."planned_outing_participants" TO "anon";
GRANT ALL ON TABLE "public"."planned_outing_participants" TO "authenticated";
GRANT ALL ON TABLE "public"."planned_outing_participants" TO "service_role";



GRANT ALL ON TABLE "public"."planned_outings" TO "anon";
GRANT ALL ON TABLE "public"."planned_outings" TO "authenticated";
GRANT ALL ON TABLE "public"."planned_outings" TO "service_role";



GRANT ALL ON SEQUENCE "public"."planned_outings_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."planned_outings_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."planned_outings_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON TABLE "public"."profile_search" TO "authenticated";
GRANT ALL ON TABLE "public"."profile_search" TO "service_role";



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



SET SESSION AUTHORIZATION "postgres";
RESET SESSION AUTHORIZATION;



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































drop extension if exists "pg_net";

revoke delete on table "public"."friendships" from "authenticated";

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION private.handle_new_profile();


  create policy "Anyone can upload an avatar."
  on "storage"."objects"
  as permissive
  for insert
  to public
with check ((bucket_id = 'avatars'::text));



  create policy "Avatar images are publicly accessible."
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'avatars'::text));

CREATE POLICY "Activities are viewable by everyone" 
ON "public"."activities" FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can view activities of planned outings" 
ON "public"."planned_outing_activities" FOR SELECT TO authenticated USING (true);




