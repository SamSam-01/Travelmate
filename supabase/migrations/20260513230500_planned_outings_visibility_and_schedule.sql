-- Migration: planned_outings_visibility_and_schedule
-- Description: Add visibility and scheduled date fields for planned outings

ALTER TABLE planned_outings
ADD COLUMN IF NOT EXISTS visibility TEXT NOT NULL DEFAULT 'private';

ALTER TABLE planned_outings
ADD COLUMN IF NOT EXISTS scheduled_for TIMESTAMP WITH TIME ZONE;

ALTER TABLE planned_outings
DROP CONSTRAINT IF EXISTS planned_outings_visibility_check;

ALTER TABLE planned_outings
ADD CONSTRAINT planned_outings_visibility_check
CHECK (visibility IN ('private', 'public'));
