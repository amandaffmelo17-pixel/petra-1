-- PETRA — Central de Registros e Acessos
-- Mantém rastreabilidade de usuários, serviços, agentes e integrações.

CREATE TYPE petra.access_subject_type AS ENUM ('user', 'service', 'agent', 'integration');
CREATE TYPE petra.access_event_type AS ENUM ('login', 'logout', 'connection', 'disconnection', 'permission_change', 'access_denied', 'token_rotation');
CREATE TYPE petra.access_status AS ENUM ('active', 'ended', 'denied', 'revoked');

CREATE TABLE petra.access_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES petra.companies(id) ON DELETE CASCADE,
  subject_type petra.access_subject_type NOT NULL,
  subject_id uuid,
  subject_name text NOT NULL,
  access_role text,
  source text NOT NULL,
  target text NOT NULL,
  permissions jsonb NOT NULL DEFAULT '[]'::jsonb,
  device_info jsonb NOT NULL DEFAULT '{}'::jsonb,
  ip_hash text,
  started_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  last_activity_at timestamptz NOT NULL DEFAULT now(),
  status petra.access_status NOT NULL DEFAULT 'active',
  correlation_id uuid,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE petra.access_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES petra.companies(id) ON DELETE SET NULL,
  session_id uuid REFERENCES petra.access_sessions(id) ON DELETE SET NULL,
  subject_type petra.access_subject_type NOT NULL,
  subject_id uuid,
  subject_name text NOT NULL,
  event_type petra.access_event_type NOT NULL,
  source text NOT NULL,
  target text NOT NULL,
  permission text,
  result petra.access_status NOT NULL,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  occurred_at timestamptz NOT NULL DEFAULT now(),
  correlation_id uuid
);

CREATE INDEX idx_access_sessions_company_status ON petra.access_sessions(company_id, status);
CREATE INDEX idx_access_sessions_subject ON petra.access_sessions(subject_type, subject_id);
CREATE INDEX idx_access_events_company_time ON petra.access_events(company_id, occurred_at DESC);
CREATE INDEX idx_access_events_subject_time ON petra.access_events(subject_type, subject_id, occurred_at DESC);
CREATE INDEX idx_access_events_type_time ON petra.access_events(event_type, occurred_at DESC);

COMMENT ON TABLE petra.access_sessions IS 'Sessões e conexões atualmente ativas ou encerradas no PETRA.';
COMMENT ON TABLE petra.access_events IS 'Registro de auditoria de acessos, conexões, permissões e bloqueios.';
