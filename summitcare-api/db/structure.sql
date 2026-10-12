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

--
-- Name: audit_events_reject_change(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.audit_events_reject_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'audit_events is append-only (% rejected)', TG_OP;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounting_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounting_requests (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    requested_at timestamp(6) without time zone NOT NULL,
    due_on date NOT NULL,
    extended_due_on date,
    format character varying DEFAULT 'pdf'::character varying NOT NULL,
    status character varying DEFAULT 'received'::character varying NOT NULL,
    fulfilled_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: accounting_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounting_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounting_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounting_requests_id_seq OWNED BY public.accounting_requests.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: activity_reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_reviews (
    id bigint NOT NULL,
    period_start timestamp(6) without time zone NOT NULL,
    period_end timestamp(6) without time zone NOT NULL,
    reviewed_by_id bigint,
    completed_at timestamp(6) without time zone,
    summary text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: activity_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_reviews_id_seq OWNED BY public.activity_reviews.id;


--
-- Name: amendment_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.amendment_requests (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    target_type character varying NOT NULL,
    target_id bigint NOT NULL,
    requested_change text,
    reason text,
    status character varying DEFAULT 'submitted'::character varying NOT NULL,
    decided_by_id bigint,
    decided_at timestamp(6) without time zone,
    denial_basis character varying,
    due_on date NOT NULL,
    extended_due_on date,
    notify_recipients jsonb DEFAULT '[]'::jsonb NOT NULL,
    include_with_disclosures boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: amendment_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.amendment_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: amendment_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.amendment_requests_id_seq OWNED BY public.amendment_requests.id;


--
-- Name: analytics_daily_counts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.analytics_daily_counts (
    id bigint NOT NULL,
    day date NOT NULL,
    event character varying NOT NULL,
    total integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: analytics_daily_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.analytics_daily_counts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analytics_daily_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.analytics_daily_counts_id_seq OWNED BY public.analytics_daily_counts.id;


--
-- Name: anomaly_findings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.anomaly_findings (
    id bigint NOT NULL,
    kind character varying NOT NULL,
    actor_id bigint,
    patient_id bigint,
    window_start timestamp(6) without time zone NOT NULL,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    status character varying DEFAULT 'open'::character varying NOT NULL,
    reviewed_by_id bigint,
    reviewed_at timestamp(6) without time zone,
    disposition character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: anomaly_findings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.anomaly_findings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: anomaly_findings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.anomaly_findings_id_seq OWNED BY public.anomaly_findings.id;


--
-- Name: appointments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointments (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    clinician_id bigint NOT NULL,
    starts_at timestamp(6) without time zone NOT NULL,
    ends_at timestamp(6) without time zone NOT NULL,
    reason text,
    status character varying DEFAULT 'scheduled'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL,
    CONSTRAINT appointments_end_after_start CHECK ((ends_at > starts_at))
);


--
-- Name: appointments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.appointments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appointments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.appointments_id_seq OWNED BY public.appointments.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: audit_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_events (
    id bigint NOT NULL,
    occurred_at timestamp(6) without time zone NOT NULL,
    actor_id bigint,
    actor_role character varying,
    action character varying NOT NULL,
    subject_type character varying,
    subject_id bigint,
    patient_id bigint,
    ip_address inet,
    user_agent character varying,
    request_id character varying,
    device_session_id bigint,
    reason text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    previous_digest character varying,
    digest character varying
);


--
-- Name: audit_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_events_id_seq OWNED BY public.audit_events.id;


--
-- Name: backup_restore_drills; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.backup_restore_drills (
    id bigint NOT NULL,
    instance_id character varying NOT NULL,
    snapshot_id character varying,
    snapshot_taken_at timestamp(6) without time zone,
    started_at timestamp(6) without time zone NOT NULL,
    available_at timestamp(6) without time zone,
    completed_at timestamp(6) without time zone,
    checks jsonb DEFAULT '{}'::jsonb NOT NULL,
    passed boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: backup_restore_drills_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.backup_restore_drills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: backup_restore_drills_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.backup_restore_drills_id_seq OWNED BY public.backup_restore_drills.id;


--
-- Name: break_glass_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.break_glass_grants (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    reason text NOT NULL,
    granted_at timestamp(6) without time zone NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    reviewed_by_id bigint,
    reviewed_at timestamp(6) without time zone,
    review_outcome character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: break_glass_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.break_glass_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: break_glass_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.break_glass_grants_id_seq OWNED BY public.break_glass_grants.id;


--
-- Name: care_team_memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.care_team_memberships (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    user_id bigint NOT NULL,
    role character varying DEFAULT 'primary_care'::character varying NOT NULL,
    starts_on date NOT NULL,
    ends_on date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: care_team_memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.care_team_memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: care_team_memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.care_team_memberships_id_seq OWNED BY public.care_team_memberships.id;


--
-- Name: clinical_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clinical_versions (
    id bigint NOT NULL,
    item_type character varying NOT NULL,
    item_id bigint NOT NULL,
    event character varying NOT NULL,
    whodunnit character varying,
    request_id character varying,
    object text,
    object_changes text,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: clinical_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clinical_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clinical_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clinical_versions_id_seq OWNED BY public.clinical_versions.id;


--
-- Name: communication_preferences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.communication_preferences (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    channel character varying NOT NULL,
    destination text,
    confidential boolean DEFAULT false NOT NULL,
    allow_message_preview boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: communication_preferences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.communication_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: communication_preferences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.communication_preferences_id_seq OWNED BY public.communication_preferences.id;


--
-- Name: control_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.control_runs (
    id bigint NOT NULL,
    control character varying NOT NULL,
    succeeded boolean NOT NULL,
    ran_at timestamp(6) without time zone NOT NULL,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: control_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.control_runs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: control_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.control_runs_id_seq OWNED BY public.control_runs.id;


--
-- Name: device_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.device_sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    device_id character varying NOT NULL,
    device_name character varying,
    access_token_digest character varying,
    refresh_token_digest character varying,
    previous_refresh_token_digest character varying,
    access_expires_at timestamp(6) without time zone,
    refresh_expires_at timestamp(6) without time zone NOT NULL,
    last_seen_at timestamp(6) without time zone,
    revoked_at timestamp(6) without time zone,
    revoked_reason character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: device_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.device_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: device_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.device_sessions_id_seq OWNED BY public.device_sessions.id;


--
-- Name: disclosures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disclosures (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    recipient_name character varying NOT NULL,
    recipient_address character varying,
    purpose character varying NOT NULL,
    description text,
    disclosed_at timestamp(6) without time zone NOT NULL,
    disclosed_by_id bigint,
    accountable boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: disclosures_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disclosures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disclosures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disclosures_id_seq OWNED BY public.disclosures.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    uploaded_by_id bigint NOT NULL,
    kind character varying NOT NULL,
    title text,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.documents_id_seq OWNED BY public.documents.id;


--
-- Name: incident_affected_patients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incident_affected_patients (
    id bigint NOT NULL,
    incident_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    notified_at timestamp(6) without time zone,
    notice_method character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: incident_affected_patients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incident_affected_patients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incident_affected_patients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incident_affected_patients_id_seq OWNED BY public.incident_affected_patients.id;


--
-- Name: incidents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incidents (
    id bigint NOT NULL,
    detected_at timestamp(6) without time zone NOT NULL,
    reported_by_id bigint NOT NULL,
    summary text NOT NULL,
    status character varying DEFAULT 'open'::character varying NOT NULL,
    phi_involved boolean DEFAULT false NOT NULL,
    risk_assessment jsonb DEFAULT '{}'::jsonb NOT NULL,
    breach_determination character varying DEFAULT 'pending'::character varying NOT NULL,
    discovered_at timestamp(6) without time zone,
    notification_deadline date,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incidents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incidents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incidents_id_seq OWNED BY public.incidents.id;


--
-- Name: lab_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lab_results (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    ordered_by_id bigint,
    test_code character varying,
    test_name character varying,
    value text,
    unit character varying,
    reference_range character varying,
    resulted_at timestamp(6) without time zone NOT NULL,
    notes text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL
);


--
-- Name: lab_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lab_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lab_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lab_results_id_seq OWNED BY public.lab_results.id;


--
-- Name: legal_holds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.legal_holds (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    reason text NOT NULL,
    placed_by_id bigint NOT NULL,
    placed_at timestamp(6) without time zone NOT NULL,
    released_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: legal_holds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.legal_holds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: legal_holds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.legal_holds_id_seq OWNED BY public.legal_holds.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    sender_id bigint NOT NULL,
    body text,
    read_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: partner_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partner_credentials (
    id bigint NOT NULL,
    partner_id bigint NOT NULL,
    lookup_id character varying NOT NULL,
    secret_digest character varying NOT NULL,
    scopes character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    expires_at timestamp(6) without time zone NOT NULL,
    revoked_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: partner_credentials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.partner_credentials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: partner_credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.partner_credentials_id_seq OWNED BY public.partner_credentials.id;


--
-- Name: partners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.partners (
    id bigint NOT NULL,
    name character varying NOT NULL,
    relationship character varying NOT NULL,
    vendor_key character varying,
    webhook_secret text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: partners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.partners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.partners_id_seq OWNED BY public.partners.id;


--
-- Name: patient_authorizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_authorizations (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    recipient character varying NOT NULL,
    purpose character varying NOT NULL,
    information_scope text,
    signed_at timestamp(6) without time zone NOT NULL,
    expires_on date,
    expiration_event text,
    revoked_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: patient_authorizations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.patient_authorizations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: patient_authorizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.patient_authorizations_id_seq OWNED BY public.patient_authorizations.id;


--
-- Name: patient_surrogates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_surrogates (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    surrogate_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: patient_surrogates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.patient_surrogates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: patient_surrogates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.patient_surrogates_id_seq OWNED BY public.patient_surrogates.id;


--
-- Name: patients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patients (
    id bigint NOT NULL,
    user_id bigint,
    mrn text,
    first_name text,
    last_name text,
    date_of_birth text,
    phone text,
    phone_bidx character varying,
    email text,
    address_line1 text,
    city text,
    state text,
    postal_code text,
    monitored boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL
);


--
-- Name: patients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.patients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: patients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.patients_id_seq OWNED BY public.patients.id;


--
-- Name: record_amendments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.record_amendments (
    id bigint NOT NULL,
    amendment_request_id bigint NOT NULL,
    target_type character varying NOT NULL,
    target_id bigint NOT NULL,
    author_id bigint,
    kind character varying NOT NULL,
    body text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: record_amendments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.record_amendments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: record_amendments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.record_amendments_id_seq OWNED BY public.record_amendments.id;


--
-- Name: record_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.record_requests (
    id bigint NOT NULL,
    patient_id bigint NOT NULL,
    requested_at timestamp(6) without time zone NOT NULL,
    due_on date NOT NULL,
    extended_due_on date,
    format character varying NOT NULL,
    status character varying DEFAULT 'received'::character varying NOT NULL,
    fulfilled_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: record_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.record_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: record_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.record_requests_id_seq OWNED BY public.record_requests.id;


--
-- Name: recovery_codes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recovery_codes (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    code_digest character varying NOT NULL,
    used_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: recovery_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recovery_codes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recovery_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recovery_codes_id_seq OWNED BY public.recovery_codes.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    ip_address character varying,
    user_agent character varying,
    last_active_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email_address character varying NOT NULL,
    password_digest character varying NOT NULL,
    role character varying DEFAULT 'patient'::character varying NOT NULL,
    otp_secret text,
    otp_enabled_at timestamp(6) without time zone,
    otp_last_used_at timestamp(6) without time zone,
    webauthn_id character varying,
    last_sign_in_at timestamp(6) without time zone,
    deactivated_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: webauthn_credentials; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webauthn_credentials (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    external_id character varying NOT NULL,
    public_key character varying NOT NULL,
    sign_count bigint DEFAULT 0 NOT NULL,
    nickname character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: webauthn_credentials_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webauthn_credentials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webauthn_credentials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webauthn_credentials_id_seq OWNED BY public.webauthn_credentials.id;


--
-- Name: webhook_receipts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webhook_receipts (
    id bigint NOT NULL,
    partner_id bigint NOT NULL,
    event_id character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: webhook_receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webhook_receipts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhook_receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webhook_receipts_id_seq OWNED BY public.webhook_receipts.id;


--
-- Name: accounting_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounting_requests ALTER COLUMN id SET DEFAULT nextval('public.accounting_requests_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: activity_reviews id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_reviews ALTER COLUMN id SET DEFAULT nextval('public.activity_reviews_id_seq'::regclass);


--
-- Name: amendment_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amendment_requests ALTER COLUMN id SET DEFAULT nextval('public.amendment_requests_id_seq'::regclass);


--
-- Name: analytics_daily_counts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_daily_counts ALTER COLUMN id SET DEFAULT nextval('public.analytics_daily_counts_id_seq'::regclass);


--
-- Name: anomaly_findings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anomaly_findings ALTER COLUMN id SET DEFAULT nextval('public.anomaly_findings_id_seq'::regclass);


--
-- Name: appointments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments ALTER COLUMN id SET DEFAULT nextval('public.appointments_id_seq'::regclass);


--
-- Name: audit_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_events ALTER COLUMN id SET DEFAULT nextval('public.audit_events_id_seq'::regclass);


--
-- Name: backup_restore_drills id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backup_restore_drills ALTER COLUMN id SET DEFAULT nextval('public.backup_restore_drills_id_seq'::regclass);


--
-- Name: break_glass_grants id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.break_glass_grants ALTER COLUMN id SET DEFAULT nextval('public.break_glass_grants_id_seq'::regclass);


--
-- Name: care_team_memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.care_team_memberships ALTER COLUMN id SET DEFAULT nextval('public.care_team_memberships_id_seq'::regclass);


--
-- Name: clinical_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_versions ALTER COLUMN id SET DEFAULT nextval('public.clinical_versions_id_seq'::regclass);


--
-- Name: communication_preferences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communication_preferences ALTER COLUMN id SET DEFAULT nextval('public.communication_preferences_id_seq'::regclass);


--
-- Name: control_runs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_runs ALTER COLUMN id SET DEFAULT nextval('public.control_runs_id_seq'::regclass);


--
-- Name: device_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_sessions ALTER COLUMN id SET DEFAULT nextval('public.device_sessions_id_seq'::regclass);


--
-- Name: disclosures id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disclosures ALTER COLUMN id SET DEFAULT nextval('public.disclosures_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents ALTER COLUMN id SET DEFAULT nextval('public.documents_id_seq'::regclass);


--
-- Name: incident_affected_patients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incident_affected_patients ALTER COLUMN id SET DEFAULT nextval('public.incident_affected_patients_id_seq'::regclass);


--
-- Name: incidents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidents ALTER COLUMN id SET DEFAULT nextval('public.incidents_id_seq'::regclass);


--
-- Name: lab_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lab_results ALTER COLUMN id SET DEFAULT nextval('public.lab_results_id_seq'::regclass);


--
-- Name: legal_holds id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_holds ALTER COLUMN id SET DEFAULT nextval('public.legal_holds_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: partner_credentials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_credentials ALTER COLUMN id SET DEFAULT nextval('public.partner_credentials_id_seq'::regclass);


--
-- Name: partners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partners ALTER COLUMN id SET DEFAULT nextval('public.partners_id_seq'::regclass);


--
-- Name: patient_authorizations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_authorizations ALTER COLUMN id SET DEFAULT nextval('public.patient_authorizations_id_seq'::regclass);


--
-- Name: patient_surrogates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_surrogates ALTER COLUMN id SET DEFAULT nextval('public.patient_surrogates_id_seq'::regclass);


--
-- Name: patients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients ALTER COLUMN id SET DEFAULT nextval('public.patients_id_seq'::regclass);


--
-- Name: record_amendments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_amendments ALTER COLUMN id SET DEFAULT nextval('public.record_amendments_id_seq'::regclass);


--
-- Name: record_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_requests ALTER COLUMN id SET DEFAULT nextval('public.record_requests_id_seq'::regclass);


--
-- Name: recovery_codes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recovery_codes ALTER COLUMN id SET DEFAULT nextval('public.recovery_codes_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: webauthn_credentials id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webauthn_credentials ALTER COLUMN id SET DEFAULT nextval('public.webauthn_credentials_id_seq'::regclass);


--
-- Name: webhook_receipts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_receipts ALTER COLUMN id SET DEFAULT nextval('public.webhook_receipts_id_seq'::regclass);


--
-- Name: accounting_requests accounting_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounting_requests
    ADD CONSTRAINT accounting_requests_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: activity_reviews activity_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_reviews
    ADD CONSTRAINT activity_reviews_pkey PRIMARY KEY (id);


--
-- Name: amendment_requests amendment_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amendment_requests
    ADD CONSTRAINT amendment_requests_pkey PRIMARY KEY (id);


--
-- Name: analytics_daily_counts analytics_daily_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.analytics_daily_counts
    ADD CONSTRAINT analytics_daily_counts_pkey PRIMARY KEY (id);


--
-- Name: anomaly_findings anomaly_findings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anomaly_findings
    ADD CONSTRAINT anomaly_findings_pkey PRIMARY KEY (id);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: audit_events audit_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_events
    ADD CONSTRAINT audit_events_pkey PRIMARY KEY (id);


--
-- Name: backup_restore_drills backup_restore_drills_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.backup_restore_drills
    ADD CONSTRAINT backup_restore_drills_pkey PRIMARY KEY (id);


--
-- Name: break_glass_grants break_glass_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.break_glass_grants
    ADD CONSTRAINT break_glass_grants_pkey PRIMARY KEY (id);


--
-- Name: care_team_memberships care_team_memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.care_team_memberships
    ADD CONSTRAINT care_team_memberships_pkey PRIMARY KEY (id);


--
-- Name: clinical_versions clinical_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_versions
    ADD CONSTRAINT clinical_versions_pkey PRIMARY KEY (id);


--
-- Name: communication_preferences communication_preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communication_preferences
    ADD CONSTRAINT communication_preferences_pkey PRIMARY KEY (id);


--
-- Name: control_runs control_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_runs
    ADD CONSTRAINT control_runs_pkey PRIMARY KEY (id);


--
-- Name: device_sessions device_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_sessions
    ADD CONSTRAINT device_sessions_pkey PRIMARY KEY (id);


--
-- Name: disclosures disclosures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disclosures
    ADD CONSTRAINT disclosures_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: incident_affected_patients incident_affected_patients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incident_affected_patients
    ADD CONSTRAINT incident_affected_patients_pkey PRIMARY KEY (id);


--
-- Name: incidents incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_pkey PRIMARY KEY (id);


--
-- Name: lab_results lab_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lab_results
    ADD CONSTRAINT lab_results_pkey PRIMARY KEY (id);


--
-- Name: legal_holds legal_holds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_holds
    ADD CONSTRAINT legal_holds_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: partner_credentials partner_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_credentials
    ADD CONSTRAINT partner_credentials_pkey PRIMARY KEY (id);


--
-- Name: partners partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partners
    ADD CONSTRAINT partners_pkey PRIMARY KEY (id);


--
-- Name: patient_authorizations patient_authorizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_authorizations
    ADD CONSTRAINT patient_authorizations_pkey PRIMARY KEY (id);


--
-- Name: patient_surrogates patient_surrogates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_surrogates
    ADD CONSTRAINT patient_surrogates_pkey PRIMARY KEY (id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: record_amendments record_amendments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_amendments
    ADD CONSTRAINT record_amendments_pkey PRIMARY KEY (id);


--
-- Name: record_requests record_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_requests
    ADD CONSTRAINT record_requests_pkey PRIMARY KEY (id);


--
-- Name: recovery_codes recovery_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recovery_codes
    ADD CONSTRAINT recovery_codes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);


--
-- Name: webhook_receipts webhook_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_receipts
    ADD CONSTRAINT webhook_receipts_pkey PRIMARY KEY (id);


--
-- Name: index_accounting_requests_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_accounting_requests_on_patient_id ON public.accounting_requests USING btree (patient_id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_activity_reviews_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activity_reviews_on_reviewed_by_id ON public.activity_reviews USING btree (reviewed_by_id);


--
-- Name: index_amendment_requests_on_decided_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_amendment_requests_on_decided_by_id ON public.amendment_requests USING btree (decided_by_id);


--
-- Name: index_amendment_requests_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_amendment_requests_on_patient_id ON public.amendment_requests USING btree (patient_id);


--
-- Name: index_amendment_requests_on_target; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_amendment_requests_on_target ON public.amendment_requests USING btree (target_type, target_id);


--
-- Name: index_analytics_daily_counts_on_day_and_event; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_analytics_daily_counts_on_day_and_event ON public.analytics_daily_counts USING btree (day, event);


--
-- Name: index_anomaly_findings_on_kind_and_actor_id_and_window_start; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_anomaly_findings_on_kind_and_actor_id_and_window_start ON public.anomaly_findings USING btree (kind, actor_id, window_start);


--
-- Name: index_anomaly_findings_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_anomaly_findings_on_reviewed_by_id ON public.anomaly_findings USING btree (reviewed_by_id);


--
-- Name: index_appointments_on_clinician_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_appointments_on_clinician_id ON public.appointments USING btree (clinician_id);


--
-- Name: index_appointments_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_appointments_on_patient_id ON public.appointments USING btree (patient_id);


--
-- Name: index_audit_events_on_actor_id_and_occurred_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audit_events_on_actor_id_and_occurred_at ON public.audit_events USING btree (actor_id, occurred_at);


--
-- Name: index_audit_events_on_patient_id_and_occurred_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_audit_events_on_patient_id_and_occurred_at ON public.audit_events USING btree (patient_id, occurred_at);


--
-- Name: index_break_glass_grants_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_break_glass_grants_on_patient_id ON public.break_glass_grants USING btree (patient_id);


--
-- Name: index_break_glass_grants_on_reviewed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_break_glass_grants_on_reviewed_by_id ON public.break_glass_grants USING btree (reviewed_by_id);


--
-- Name: index_break_glass_grants_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_break_glass_grants_on_user_id ON public.break_glass_grants USING btree (user_id);


--
-- Name: index_care_team_memberships_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_care_team_memberships_on_patient_id ON public.care_team_memberships USING btree (patient_id);


--
-- Name: index_care_team_memberships_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_care_team_memberships_on_user_id ON public.care_team_memberships USING btree (user_id);


--
-- Name: index_clinical_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clinical_versions_on_item_type_and_item_id ON public.clinical_versions USING btree (item_type, item_id);


--
-- Name: index_communication_preferences_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_communication_preferences_on_patient_id ON public.communication_preferences USING btree (patient_id);


--
-- Name: index_control_runs_on_control_and_ran_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_control_runs_on_control_and_ran_at ON public.control_runs USING btree (control, ran_at);


--
-- Name: index_device_sessions_on_access_token_digest; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_device_sessions_on_access_token_digest ON public.device_sessions USING btree (access_token_digest);


--
-- Name: index_device_sessions_on_previous_refresh_token_digest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_device_sessions_on_previous_refresh_token_digest ON public.device_sessions USING btree (previous_refresh_token_digest);


--
-- Name: index_device_sessions_on_refresh_token_digest; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_device_sessions_on_refresh_token_digest ON public.device_sessions USING btree (refresh_token_digest);


--
-- Name: index_device_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_device_sessions_on_user_id ON public.device_sessions USING btree (user_id);


--
-- Name: index_disclosures_on_disclosed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_disclosures_on_disclosed_by_id ON public.disclosures USING btree (disclosed_by_id);


--
-- Name: index_disclosures_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_disclosures_on_patient_id ON public.disclosures USING btree (patient_id);


--
-- Name: index_disclosures_on_patient_id_and_disclosed_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_disclosures_on_patient_id_and_disclosed_at ON public.disclosures USING btree (patient_id, disclosed_at);


--
-- Name: index_documents_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_patient_id ON public.documents USING btree (patient_id);


--
-- Name: index_documents_on_uploaded_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_uploaded_by_id ON public.documents USING btree (uploaded_by_id);


--
-- Name: index_incident_affected_patients_on_incident_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incident_affected_patients_on_incident_id ON public.incident_affected_patients USING btree (incident_id);


--
-- Name: index_incident_affected_patients_on_incident_id_and_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_incident_affected_patients_on_incident_id_and_patient_id ON public.incident_affected_patients USING btree (incident_id, patient_id);


--
-- Name: index_incident_affected_patients_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incident_affected_patients_on_patient_id ON public.incident_affected_patients USING btree (patient_id);


--
-- Name: index_incidents_on_reported_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_incidents_on_reported_by_id ON public.incidents USING btree (reported_by_id);


--
-- Name: index_lab_results_on_ordered_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lab_results_on_ordered_by_id ON public.lab_results USING btree (ordered_by_id);


--
-- Name: index_lab_results_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_lab_results_on_patient_id ON public.lab_results USING btree (patient_id);


--
-- Name: index_legal_holds_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legal_holds_on_patient_id ON public.legal_holds USING btree (patient_id);


--
-- Name: index_legal_holds_on_placed_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_legal_holds_on_placed_by_id ON public.legal_holds USING btree (placed_by_id);


--
-- Name: index_messages_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_patient_id ON public.messages USING btree (patient_id);


--
-- Name: index_messages_on_sender_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_sender_id ON public.messages USING btree (sender_id);


--
-- Name: index_partner_credentials_on_lookup_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_partner_credentials_on_lookup_id ON public.partner_credentials USING btree (lookup_id);


--
-- Name: index_partner_credentials_on_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_partner_credentials_on_partner_id ON public.partner_credentials USING btree (partner_id);


--
-- Name: index_patient_authorizations_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_patient_authorizations_on_patient_id ON public.patient_authorizations USING btree (patient_id);


--
-- Name: index_patient_surrogates_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_patient_surrogates_on_patient_id ON public.patient_surrogates USING btree (patient_id);


--
-- Name: index_patient_surrogates_on_surrogate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_patient_surrogates_on_surrogate_id ON public.patient_surrogates USING btree (surrogate_id);


--
-- Name: index_patients_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_patients_on_email ON public.patients USING btree (email);


--
-- Name: index_patients_on_mrn; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_patients_on_mrn ON public.patients USING btree (mrn);


--
-- Name: index_patients_on_phone_bidx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_patients_on_phone_bidx ON public.patients USING btree (phone_bidx);


--
-- Name: index_patients_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_patients_on_user_id ON public.patients USING btree (user_id);


--
-- Name: index_record_amendments_on_amendment_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_record_amendments_on_amendment_request_id ON public.record_amendments USING btree (amendment_request_id);


--
-- Name: index_record_amendments_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_record_amendments_on_author_id ON public.record_amendments USING btree (author_id);


--
-- Name: index_record_amendments_on_target; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_record_amendments_on_target ON public.record_amendments USING btree (target_type, target_id);


--
-- Name: index_record_requests_on_patient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_record_requests_on_patient_id ON public.record_requests USING btree (patient_id);


--
-- Name: index_recovery_codes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recovery_codes_on_user_id ON public.recovery_codes USING btree (user_id);


--
-- Name: index_recovery_codes_on_user_id_and_code_digest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_recovery_codes_on_user_id_and_code_digest ON public.recovery_codes USING btree (user_id, code_digest);


--
-- Name: index_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_user_id ON public.sessions USING btree (user_id);


--
-- Name: index_users_on_email_address; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email_address ON public.users USING btree (email_address);


--
-- Name: index_users_on_webauthn_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_webauthn_id ON public.users USING btree (webauthn_id);


--
-- Name: index_webauthn_credentials_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_webauthn_credentials_on_external_id ON public.webauthn_credentials USING btree (external_id);


--
-- Name: index_webauthn_credentials_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_webauthn_credentials_on_user_id ON public.webauthn_credentials USING btree (user_id);


--
-- Name: index_webhook_receipts_on_partner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_webhook_receipts_on_partner_id ON public.webhook_receipts USING btree (partner_id);


--
-- Name: index_webhook_receipts_on_partner_id_and_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_webhook_receipts_on_partner_id_and_event_id ON public.webhook_receipts USING btree (partner_id, event_id);


--
-- Name: audit_events audit_events_no_truncate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_events_no_truncate BEFORE TRUNCATE ON public.audit_events FOR EACH STATEMENT EXECUTE FUNCTION public.audit_events_reject_change();


--
-- Name: audit_events audit_events_no_update_delete; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_events_no_update_delete BEFORE DELETE OR UPDATE ON public.audit_events FOR EACH ROW EXECUTE FUNCTION public.audit_events_reject_change();


--
-- Name: appointments fk_rails_06d7a12378; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT fk_rails_06d7a12378 FOREIGN KEY (clinician_id) REFERENCES public.users(id);


--
-- Name: activity_reviews fk_rails_0cbb4b278c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_reviews
    ADD CONSTRAINT fk_rails_0cbb4b278c FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: webhook_receipts fk_rails_0ddd213386; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webhook_receipts
    ADD CONSTRAINT fk_rails_0ddd213386 FOREIGN KEY (partner_id) REFERENCES public.partners(id);


--
-- Name: care_team_memberships fk_rails_0e4189a625; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.care_team_memberships
    ADD CONSTRAINT fk_rails_0e4189a625 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: documents fk_rails_325148de08; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_rails_325148de08 FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: legal_holds fk_rails_38fc5d99b4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_holds
    ADD CONSTRAINT fk_rails_38fc5d99b4 FOREIGN KEY (placed_by_id) REFERENCES public.users(id);


--
-- Name: record_amendments fk_rails_3f75ef8ff4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_amendments
    ADD CONSTRAINT fk_rails_3f75ef8ff4 FOREIGN KEY (amendment_request_id) REFERENCES public.amendment_requests(id);


--
-- Name: device_sessions fk_rails_50e1d0b3ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.device_sessions
    ADD CONSTRAINT fk_rails_50e1d0b3ca FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: patient_authorizations fk_rails_5319d4d3a9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_authorizations
    ADD CONSTRAINT fk_rails_5319d4d3a9 FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: incidents fk_rails_5cfd35ab5f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT fk_rails_5cfd35ab5f FOREIGN KEY (reported_by_id) REFERENCES public.users(id);


--
-- Name: anomaly_findings fk_rails_5e06846577; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.anomaly_findings
    ADD CONSTRAINT fk_rails_5e06846577 FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: patients fk_rails_623f05c630; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT fk_rails_623f05c630 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: record_amendments fk_rails_6a08127911; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_amendments
    ADD CONSTRAINT fk_rails_6a08127911 FOREIGN KEY (author_id) REFERENCES public.users(id);


--
-- Name: break_glass_grants fk_rails_6ae664f7ae; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.break_glass_grants
    ADD CONSTRAINT fk_rails_6ae664f7ae FOREIGN KEY (reviewed_by_id) REFERENCES public.users(id);


--
-- Name: sessions fk_rails_758836b4f0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT fk_rails_758836b4f0 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: incident_affected_patients fk_rails_7c9ed1ccc3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incident_affected_patients
    ADD CONSTRAINT fk_rails_7c9ed1ccc3 FOREIGN KEY (incident_id) REFERENCES public.incidents(id);


--
-- Name: break_glass_grants fk_rails_7f4c55c378; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.break_glass_grants
    ADD CONSTRAINT fk_rails_7f4c55c378 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: partner_credentials fk_rails_852486c80b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.partner_credentials
    ADD CONSTRAINT fk_rails_852486c80b FOREIGN KEY (partner_id) REFERENCES public.partners(id);


--
-- Name: incident_affected_patients fk_rails_91b94d6c88; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incident_affected_patients
    ADD CONSTRAINT fk_rails_91b94d6c88 FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: accounting_requests fk_rails_94e126c2cd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounting_requests
    ADD CONSTRAINT fk_rails_94e126c2cd FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: break_glass_grants fk_rails_96cdae5cf0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.break_glass_grants
    ADD CONSTRAINT fk_rails_96cdae5cf0 FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: care_team_memberships fk_rails_9746b30837; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.care_team_memberships
    ADD CONSTRAINT fk_rails_9746b30837 FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: record_requests fk_rails_9c4881a641; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.record_requests
    ADD CONSTRAINT fk_rails_9c4881a641 FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_surrogates fk_rails_a0e705701a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_surrogates
    ADD CONSTRAINT fk_rails_a0e705701a FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: amendment_requests fk_rails_a0f2df2fb2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amendment_requests
    ADD CONSTRAINT fk_rails_a0f2df2fb2 FOREIGN KEY (decided_by_id) REFERENCES public.users(id);


--
-- Name: webauthn_credentials fk_rails_a4355aef77; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webauthn_credentials
    ADD CONSTRAINT fk_rails_a4355aef77 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: lab_results fk_rails_b236b07448; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lab_results
    ADD CONSTRAINT fk_rails_b236b07448 FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: disclosures fk_rails_b285897c3e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disclosures
    ADD CONSTRAINT fk_rails_b285897c3e FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: messages fk_rails_b8f26a382d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT fk_rails_b8f26a382d FOREIGN KEY (sender_id) REFERENCES public.users(id);


--
-- Name: documents fk_rails_bb94f775d4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT fk_rails_bb94f775d4 FOREIGN KEY (uploaded_by_id) REFERENCES public.users(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: appointments fk_rails_c63da04ab4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT fk_rails_c63da04ab4 FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: recovery_codes fk_rails_cf7d76c04b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recovery_codes
    ADD CONSTRAINT fk_rails_cf7d76c04b FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: disclosures fk_rails_d1ad6c30f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disclosures
    ADD CONSTRAINT fk_rails_d1ad6c30f5 FOREIGN KEY (disclosed_by_id) REFERENCES public.users(id);


--
-- Name: communication_preferences fk_rails_d1e853a1af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communication_preferences
    ADD CONSTRAINT fk_rails_d1e853a1af FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: messages fk_rails_d463801c8d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT fk_rails_d463801c8d FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: lab_results fk_rails_d7c863184c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lab_results
    ADD CONSTRAINT fk_rails_d7c863184c FOREIGN KEY (ordered_by_id) REFERENCES public.users(id);


--
-- Name: legal_holds fk_rails_fc5cb7a280; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.legal_holds
    ADD CONSTRAINT fk_rails_fc5cb7a280 FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: amendment_requests fk_rails_fca9172b75; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.amendment_requests
    ADD CONSTRAINT fk_rails_fca9172b75 FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20261006100000'),
('20261005100000'),
('20261004100100'),
('20261004100000'),
('20261003100200'),
('20261003100100'),
('20261003100000'),
('20261001100000'),
('20261001090100'),
('20261001090000'),
('20260920090400'),
('20260920090300'),
('20260920090200'),
('20260920090100'),
('20260920090000');

