-- Reconstructed from remote migration history (version 20260413115003).
-- Source: supabase_migrations.schema_migrations on project tfavamqszdkoeabpyxms.


CREATE TABLE love_notes (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  household_id  uuid        NOT NULL REFERENCES households(id) ON DELETE CASCADE,
  from_user_id  uuid        NOT NULL,
  to_user_id    uuid        NOT NULL,
  content       text        NOT NULL CHECK (char_length(content) BETWEEN 1 AND 500),
  is_read       boolean     NOT NULL DEFAULT false,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX love_notes_to_user ON love_notes (to_user_id, is_read, created_at DESC);
CREATE INDEX love_notes_household  ON love_notes (household_id, created_at DESC);

ALTER TABLE love_notes ENABLE ROW LEVEL SECURITY;

-- Solo los miembros del household pueden leer/escribir sus notas
CREATE POLICY "household members read love notes"
  ON love_notes FOR SELECT
  USING (
    household_id IN (
      SELECT household_id FROM household_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "household members insert love notes"
  ON love_notes FOR INSERT
  WITH CHECK (
    from_user_id = auth.uid()
    AND household_id IN (
      SELECT household_id FROM household_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "recipient can mark as read"
  ON love_notes FOR UPDATE
  USING (to_user_id = auth.uid())
  WITH CHECK (to_user_id = auth.uid());
;