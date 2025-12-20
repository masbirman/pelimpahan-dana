--
-- PostgreSQL database dump
--

\restrict gIMshx3Kw7vZfe3sU6VdmJdUtmtxqXW2Jo44gMI1GiaWtnmPDfthIfvrBuljsQH

-- Dumped from database version 15.15 (Debian 15.15-1.pgdg13+1)
-- Dumped by pg_dump version 15.15 (Debian 15.15-1.pgdg13+1)

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: pelimpahan_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO pelimpahan_user;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pelimpahan_user
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: backup_histories; Type: TABLE; Schema: public; Owner: pelimpahan_user
--

CREATE TABLE public.backup_histories (
    id bigint NOT NULL,
    filename character varying(255) NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    location character varying(50) DEFAULT 'local'::character varying NOT NULL,
    g_drive_id character varying(255),
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    created_by bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.backup_histories OWNER TO pelimpahan_user;

--
-- Name: backup_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: pelimpahan_user
--

CREATE SEQUENCE public.backup_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.backup_histories_id_seq OWNER TO pelimpahan_user;

--
-- Name: backup_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pelimpahan_user
--

ALTER SEQUENCE public.backup_histories_id_seq OWNED BY public.backup_histories.id;


--
-- Name: backup_settings; Type: TABLE; Schema: public; Owner: pelimpahan_user
--

CREATE TABLE public.backup_settings (
    id bigint NOT NULL,
    enabled boolean DEFAULT false,
    schedule character varying(50) DEFAULT 'daily'::character varying,
    schedule_time character varying(10) DEFAULT '02:00'::character varying,
    retention_days bigint DEFAULT 30,
    g_drive_enabled boolean DEFAULT false,
    g_drive_client_id character varying(255),
    g_drive_secret character varying(255),
    g_drive_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.backup_settings OWNER TO pelimpahan_user;

--
-- Name: backup_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: pelimpahan_user
--

CREATE SEQUENCE public.backup_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.backup_settings_id_seq OWNER TO pelimpahan_user;

--
-- Name: backup_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pelimpahan_user
--

ALTER SEQUENCE public.backup_settings_id_seq OWNED BY public.backup_settings.id;


--
-- Name: jenis_pelimpahans; Type: TABLE; Schema: public; Owner: pelimpahan_user
--

CREATE TABLE public.jenis_pelimpahans (
    id bigint NOT NULL,
    kode_jenis character varying(50) NOT NULL,
    nama_jenis character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.jenis_pelimpahans OWNER TO pelimpahan_user;

--
-- Name: jenis_pelimpahans_id_seq; Type: SEQUENCE; Schema: public; Owner: pelimpahan_user
--

CREATE SEQUENCE public.jenis_pelimpahans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jenis_pelimpahans_id_seq OWNER TO pelimpahan_user;

--
-- Name: jenis_pelimpahans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pelimpahan_user
--

ALTER SEQUENCE public.jenis_pelimpahans_id_seq OWNED BY public.jenis_pelimpahans.id;


--
-- Name: pelimpahan_details; Type: TABLE; Schema: public; Owner: pelimpahan_user
--

CREATE TABLE public.pelimpahan_details (
    id bigint NOT NULL,
    pelimpahan_id bigint NOT NULL,
    unit_id bigint NOT NULL,
    nama_penerima character varying(255) NOT NULL,
    nomor_rekening character varying(50) NOT NULL,
    jumlah numeric(15,2) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    sumber_dana character varying(10) DEFAULT 'bank'::character varying NOT NULL
);


ALTER TABLE public.pelimpahan_details OWNER TO pelimpahan_user;

--
-- Name: pelimpahan_details_id_seq; Type: SEQUENCE; Schema: public; Owner: pelimpahan_user
--

CREATE SEQUENCE public.pelimpahan_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pelimpahan_details_id_seq OWNER TO pelimpahan_user;

--
-- Name: pelimpahan_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pelimpahan_user
--

ALTER SEQUENCE public.pelimpahan_details_id_seq OWNED BY public.pelimpahan_details.id;


--
-- Name: pelimpahans; Type: TABLE; Schema: public; Owner: pelimpahan_user
--

CREATE TABLE public.pelimpahans (
    id bigint NOT NULL,
    nomor_pelimpahan bigint NOT NULL,
    waktu_pelimpahan timestamp with time zone NOT NULL,
    tanggal_pelimpahan date NOT NULL,
    uraian_pelimpahan text,
    jenis_pelimpahan_id bigint NOT NULL,
    created_by bigint NOT NULL,
    total_jumlah numeric(15,2) DEFAULT 0,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    sumber_dana character varying(10) DEFAULT 'bank'::character varying NOT NULL,
    tahun_anggaran bigint DEFAULT 2025 NOT NULL
);


ALTER TABLE public.pelimpahans OWNER TO pelimpahan_user;

--
-- Name: pelimpahans_id_seq; Type: SEQUENCE; Schema: public; Owner: pelimpahan_user
--

CREATE SEQUENCE public.pelimpahans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pelimpahans_id_seq OWNER TO pelimpahan_user;

--
-- Name: pelimpahans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pelimpahan_user
--

ALTER SEQUENCE public.pelimpahans_id_seq OWNED BY public.pelimpahans.id;


--
-- Name: penarikan_tunais; Type: TABLE; Schema: public; Owner: pelimpahan_user
--

CREATE TABLE public.penarikan_tunais (
    id bigint NOT NULL,
    tanggal date NOT NULL,
    jumlah numeric(15,2) NOT NULL,
    keterangan text NOT NULL,
    created_by bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    tahun_anggaran bigint DEFAULT 2025 NOT NULL
);


ALTER TABLE public.penarikan_tunais OWNER TO pelimpahan_user;

--
-- Name: penarikan_tunais_id_seq; Type: SEQUENCE; Schema: public; Owner: pelimpahan_user
--

CREATE SEQUENCE public.penarikan_tunais_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.penarikan_tunais_id_seq OWNER TO pelimpahan_user;

--
-- Name: penarikan_tunais_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pelimpahan_user
--

ALTER SEQUENCE public.penarikan_tunais_id_seq OWNED BY public.penarikan_tunais.id;


--
-- Name: saldo_bendaharas; Type: TABLE; Schema: public; Owner: pelimpahan_user
--

CREATE TABLE public.saldo_bendaharas (
    id bigint NOT NULL,
    tanggal date NOT NULL,
    saldo_bank numeric(15,2) DEFAULT 0 NOT NULL,
    saldo_tunai numeric(15,2) DEFAULT 0 NOT NULL,
    keterangan text,
    created_by bigint,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    tahun_anggaran bigint DEFAULT 2025 NOT NULL
);


ALTER TABLE public.saldo_bendaharas OWNER TO pelimpahan_user;

--
-- Name: saldo_bendaharas_id_seq; Type: SEQUENCE; Schema: public; Owner: pelimpahan_user
--

CREATE SEQUENCE public.saldo_bendaharas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saldo_bendaharas_id_seq OWNER TO pelimpahan_user;

--
-- Name: saldo_bendaharas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pelimpahan_user
--

ALTER SEQUENCE public.saldo_bendaharas_id_seq OWNED BY public.saldo_bendaharas.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: pelimpahan_user
--

CREATE TABLE public.settings (
    id bigint NOT NULL,
    key character varying(100) NOT NULL,
    value text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.settings OWNER TO pelimpahan_user;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: pelimpahan_user
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.settings_id_seq OWNER TO pelimpahan_user;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pelimpahan_user
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: top_up_saldos; Type: TABLE; Schema: public; Owner: pelimpahan_user
--

CREATE TABLE public.top_up_saldos (
    id bigint NOT NULL,
    tanggal date NOT NULL,
    jumlah numeric(15,2) NOT NULL,
    keterangan text NOT NULL,
    created_by bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    tahun_anggaran bigint DEFAULT 2025 NOT NULL
);


ALTER TABLE public.top_up_saldos OWNER TO pelimpahan_user;

--
-- Name: top_up_saldos_id_seq; Type: SEQUENCE; Schema: public; Owner: pelimpahan_user
--

CREATE SEQUENCE public.top_up_saldos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.top_up_saldos_id_seq OWNER TO pelimpahan_user;

--
-- Name: top_up_saldos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pelimpahan_user
--

ALTER SEQUENCE public.top_up_saldos_id_seq OWNED BY public.top_up_saldos.id;


--
-- Name: units; Type: TABLE; Schema: public; Owner: pelimpahan_user
--

CREATE TABLE public.units (
    id bigint NOT NULL,
    kode_unit character varying(50) NOT NULL,
    nama_unit character varying(255) NOT NULL,
    nama_pimpinan character varying(255),
    nama_bendahara character varying(255) NOT NULL,
    nomor_rekening character varying(50) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    n_ip_pimpinan character varying(50),
    n_ip_bendahara character varying(50)
);


ALTER TABLE public.units OWNER TO pelimpahan_user;

--
-- Name: units_id_seq; Type: SEQUENCE; Schema: public; Owner: pelimpahan_user
--

CREATE SEQUENCE public.units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.units_id_seq OWNER TO pelimpahan_user;

--
-- Name: units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pelimpahan_user
--

ALTER SEQUENCE public.units_id_seq OWNED BY public.units.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: pelimpahan_user
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role character varying(50) DEFAULT 'operator'::character varying NOT NULL,
    avatar character varying(255),
    is_active boolean DEFAULT true,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    username character varying(100) NOT NULL
);


ALTER TABLE public.users OWNER TO pelimpahan_user;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: pelimpahan_user
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO pelimpahan_user;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pelimpahan_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: backup_histories id; Type: DEFAULT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.backup_histories ALTER COLUMN id SET DEFAULT nextval('public.backup_histories_id_seq'::regclass);


--
-- Name: backup_settings id; Type: DEFAULT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.backup_settings ALTER COLUMN id SET DEFAULT nextval('public.backup_settings_id_seq'::regclass);


--
-- Name: jenis_pelimpahans id; Type: DEFAULT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.jenis_pelimpahans ALTER COLUMN id SET DEFAULT nextval('public.jenis_pelimpahans_id_seq'::regclass);


--
-- Name: pelimpahan_details id; Type: DEFAULT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.pelimpahan_details ALTER COLUMN id SET DEFAULT nextval('public.pelimpahan_details_id_seq'::regclass);


--
-- Name: pelimpahans id; Type: DEFAULT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.pelimpahans ALTER COLUMN id SET DEFAULT nextval('public.pelimpahans_id_seq'::regclass);


--
-- Name: penarikan_tunais id; Type: DEFAULT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.penarikan_tunais ALTER COLUMN id SET DEFAULT nextval('public.penarikan_tunais_id_seq'::regclass);


--
-- Name: saldo_bendaharas id; Type: DEFAULT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.saldo_bendaharas ALTER COLUMN id SET DEFAULT nextval('public.saldo_bendaharas_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: top_up_saldos id; Type: DEFAULT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.top_up_saldos ALTER COLUMN id SET DEFAULT nextval('public.top_up_saldos_id_seq'::regclass);


--
-- Name: units id; Type: DEFAULT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.units ALTER COLUMN id SET DEFAULT nextval('public.units_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: backup_histories; Type: TABLE DATA; Schema: public; Owner: pelimpahan_user
--

COPY public.backup_histories (id, filename, size, location, g_drive_id, status, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: backup_settings; Type: TABLE DATA; Schema: public; Owner: pelimpahan_user
--

COPY public.backup_settings (id, enabled, schedule, schedule_time, retention_days, g_drive_enabled, g_drive_client_id, g_drive_secret, g_drive_token, created_at, updated_at) FROM stdin;
1	f	daily	02:00	30	f				2025-12-20 12:05:39.671702+00	2025-12-20 12:05:39.671702+00
\.


--
-- Data for Name: jenis_pelimpahans; Type: TABLE DATA; Schema: public; Owner: pelimpahan_user
--

COPY public.jenis_pelimpahans (id, kode_jenis, nama_jenis, created_at, updated_at) FROM stdin;
1	UP / GU	Uang Persediaan / Ganti Uang Persediaan	2025-12-18 07:20:40.462038+00	2025-12-20 13:30:18.581885+00
\.


--
-- Data for Name: pelimpahan_details; Type: TABLE DATA; Schema: public; Owner: pelimpahan_user
--

COPY public.pelimpahan_details (id, pelimpahan_id, unit_id, nama_penerima, nomor_rekening, jumlah, created_at, updated_at, sumber_dana) FROM stdin;
127	19	9	SRI ASTUTI, S.SI	0010103000600	35661500.00	2025-12-20 13:40:52.657105+00	2025-12-20 13:40:52.657105+00	bank
128	20	4	LISTIAWATI S. TAMA, SE	0010103002313	108575000.00	2025-12-20 13:41:27.724733+00	2025-12-20 13:41:27.724733+00	bank
129	21	4	LISTIAWATI S. TAMA, SE	0010103002313	20000000.00	2025-12-20 13:41:53.236355+00	2025-12-20 13:41:53.236355+00	bank
130	22	4	LISTIAWATI S. TAMA, SE	0010103002313	276177000.00	2025-12-20 13:42:19.174073+00	2025-12-20 13:42:19.174073+00	bank
73	10	4	LISTIAWATI S. TAMA, SE	0010103002313	259025000.00	2025-12-19 11:03:49.652782+00	2025-12-19 11:03:49.652782+00	bank
74	10	8	NURAFNI SETIAWATI, SP	0010103002335	4470000.00	2025-12-19 11:03:49.655766+00	2025-12-19 11:03:49.655766+00	bank
75	10	5	NURMALA SARI SOULISA, ST.,M.A.P	0010103002501	12780000.00	2025-12-19 11:03:49.65728+00	2025-12-19 11:03:49.65728+00	bank
76	10	7	ELYA ROSA YULIANTI, SE	0010103001985	7680000.00	2025-12-19 11:03:49.658502+00	2025-12-19 11:03:49.658502+00	bank
77	10	9	SRI ASTUTI, S.SI	0010103000600	20652000.00	2025-12-19 11:03:49.659668+00	2025-12-19 11:03:49.659668+00	bank
78	10	10	NOFRINCE LAGENTU, SE	0010103000386	20000000.00	2025-12-19 11:03:49.660851+00	2025-12-19 11:03:49.660851+00	bank
79	10	11	SYAFRINI, SE	0030103000045	10640000.00	2025-12-19 11:03:49.662115+00	2025-12-19 11:03:49.662115+00	bank
80	10	12	SARI MUTIA B. SAPPE, S.Si	0010103000320	20000000.00	2025-12-19 11:03:49.663425+00	2025-12-19 11:03:49.663425+00	bank
81	10	13	LELY SUPU, S.Pd	0040102008472	15500000.00	2025-12-19 11:03:49.66466+00	2025-12-19 11:03:49.66466+00	bank
82	10	14	VINA ANGRIANA, S.Sos	0010103000714	14500000.00	2025-12-19 11:03:49.665833+00	2025-12-19 11:03:49.665833+00	bank
83	11	4	LISTIAWATI S. TAMA, SE	0010103002313	96516000.00	2025-12-19 11:45:50.090606+00	2025-12-19 11:45:50.090606+00	bank
94	14	4	LISTIAWATI S. TAMA, SE	0010103002313	91534000.00	2025-12-20 09:46:46.63004+00	2025-12-20 09:46:46.63004+00	bank
106	15	4	LISTIAWATI S. TAMA, SE	0010103002313	166884400.00	2025-12-20 09:57:36.894665+00	2025-12-20 09:57:36.894665+00	bank
107	15	8	NURAFNI SETIAWATI, SP	0010103002335	381819400.00	2025-12-20 09:57:36.896087+00	2025-12-20 09:57:36.896087+00	bank
108	15	5	NURMALA SARI SOULISA, ST.,M.A.P	0010103002501	457441500.00	2025-12-20 09:57:36.897341+00	2025-12-20 09:57:36.897341+00	bank
109	15	6	NIDYA WIDIASTUTI, SM	0010103002140	182373050.00	2025-12-20 09:57:36.898524+00	2025-12-20 09:57:36.898524+00	bank
110	15	7	ELYA ROSA YULIANTI, SE	0010103001985	53562000.00	2025-12-20 09:57:36.899709+00	2025-12-20 09:57:36.899709+00	bank
111	15	9	SRI ASTUTI, S.SI	0010103000600	19348000.00	2025-12-20 09:57:36.900891+00	2025-12-20 09:57:36.900891+00	bank
112	15	10	NOFRINCE LAGENTU, SE	0010103000386	20000000.00	2025-12-20 09:57:36.902016+00	2025-12-20 09:57:36.902016+00	bank
113	15	12	SARI MUTIA B. SAPPE, S.Si	0010103000320	30000000.00	2025-12-20 09:57:36.903171+00	2025-12-20 09:57:36.903171+00	bank
114	15	13	LELY SUPU, S.Pd	0040102008472	34500000.00	2025-12-20 09:57:36.904423+00	2025-12-20 09:57:36.904423+00	bank
115	15	14	VINA ANGRIANA, S.Sos	0010103000714	35500000.00	2025-12-20 09:57:36.905701+00	2025-12-20 09:57:36.905701+00	bank
117	16	20	ASTUTY SULISTIYANTY, ST	0010103240216	123185000.00	2025-12-20 10:16:42.902457+00	2025-12-20 10:16:42.902457+00	tunai
119	13	15	ASTUTY SULISTIYANTY, ST	0010103240216	5100000.00	2025-12-20 10:17:41.977593+00	2025-12-20 10:17:41.977593+00	tunai
120	12	19	ASTUTY SULISTIYANTY, ST	0010103240216	31493000.00	2025-12-20 10:17:48.04408+00	2025-12-20 10:17:48.04408+00	tunai
121	17	11	SYAFRINI, SE	0030103000045	24700000.00	2025-12-20 13:19:50.987664+00	2025-12-20 13:19:50.987664+00	bank
\.


--
-- Data for Name: pelimpahans; Type: TABLE DATA; Schema: public; Owner: pelimpahan_user
--

COPY public.pelimpahans (id, nomor_pelimpahan, waktu_pelimpahan, tanggal_pelimpahan, uraian_pelimpahan, jenis_pelimpahan_id, created_by, total_jumlah, created_at, updated_at, sumber_dana, tahun_anggaran) FROM stdin;
10	1	2025-12-19 11:03:49.648689+00	2025-02-19	Pelimpahan Uang Persediaan (UP)	1	1	385247000.00	2025-12-19 11:03:49.649232+00	2025-12-19 11:03:49.649232+00	bank	2025
11	2	2025-12-19 11:45:50.086109+00	2025-03-05	Pelimpahan Uang Persediaan (UP)	1	1	96516000.00	2025-12-19 11:45:50.086428+00	2025-12-19 11:45:50.086428+00	bank	2025
14	5	2025-12-20 07:15:44.235692+00	2025-04-09	Pelimpahan Uang Persediaan (UP)	1	1	91534000.00	2025-12-20 07:15:44.235997+00	2025-12-20 09:46:46.619952+00	bank	2025
15	6	2025-12-20 09:56:31.364708+00	2025-04-22	Pelimpahan Uang Persediaan (UP)	1	1	1381428350.00	2025-12-20 09:56:31.365474+00	2025-12-20 09:57:36.891775+00	bank	2025
16	7	2025-12-20 09:57:00.557654+00	2025-04-23	Penarikan Tunai	1	1	123185000.00	2025-12-20 09:57:00.557873+00	2025-12-20 10:16:42.898006+00	bank	2025
13	4	2025-12-19 11:50:36.217041+00	2025-03-06	Penarikan Tunai	1	1	5100000.00	2025-12-19 11:50:36.217352+00	2025-12-20 10:17:41.974351+00	bank	2025
12	3	2025-12-19 11:50:18.424158+00	2025-03-04	Penarikan Tunai	1	1	31493000.00	2025-12-19 11:50:18.42446+00	2025-12-20 10:17:48.040376+00	bank	2025
17	8	2025-12-20 13:19:50.98459+00	2025-05-05	Pelimpahan Uang Persediaan (UP)	1	1	24700000.00	2025-12-20 13:19:50.984865+00	2025-12-20 13:19:50.984865+00	bank	2025
19	9	2025-12-20 13:32:46.667965+00	2025-05-09	Pelimpahan GU	1	1	35661500.00	2025-12-20 13:32:46.668628+00	2025-12-20 13:40:52.649598+00	bank	2025
20	10	2025-12-20 13:41:27.721413+00	2025-05-14		1	1	108575000.00	2025-12-20 13:41:27.721765+00	2025-12-20 13:41:27.721765+00	bank	2025
21	11	2025-12-20 13:41:53.234601+00	2025-05-15		1	1	20000000.00	2025-12-20 13:41:53.234829+00	2025-12-20 13:41:53.234829+00	bank	2025
22	12	2025-12-20 13:42:19.170567+00	2025-05-22		1	1	276177000.00	2025-12-20 13:42:19.17104+00	2025-12-20 13:42:19.17104+00	bank	2025
\.


--
-- Data for Name: penarikan_tunais; Type: TABLE DATA; Schema: public; Owner: pelimpahan_user
--

COPY public.penarikan_tunais (id, tanggal, jumlah, keterangan, created_by, created_at, updated_at, tahun_anggaran) FROM stdin;
2	2025-03-04	31493000.00	UPTD BLPT\n	1	2025-12-19 11:48:22.561038+00	2025-12-19 11:48:22.561038+00	2025
3	2025-03-06	5100000.00	DAK SMK	1	2025-12-19 11:48:48.598679+00	2025-12-19 11:48:48.598679+00	2025
4	2025-04-23	123185000.00	Penarikan Tunai	1	2025-12-20 13:21:13.971838+00	2025-12-20 13:21:13.971838+00	2025
\.


--
-- Data for Name: saldo_bendaharas; Type: TABLE DATA; Schema: public; Owner: pelimpahan_user
--

COPY public.saldo_bendaharas (id, tanggal, saldo_bank, saldo_tunai, keterangan, created_by, created_at, updated_at, tahun_anggaran) FROM stdin;
1	2025-02-05	3000000000.00	0.00	Saldo Awal Uang Persediaan (UP)	1	2025-12-18 10:01:46.464592+00	2025-12-18 10:01:46.464592+00	2025
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: pelimpahan_user
--

COPY public.settings (id, key, value, created_at, updated_at) FROM stdin;
1	countdown	{"active":true,"description":"Penatausahaan Keuangan akan berakhir tanggal 31 Desember 2025","target_date":"2025-12-31T00:00","title":"Jadwal Penatausahaan Tahun 2025"}	2025-12-18 08:46:06.739945+00	2025-12-18 14:57:26.031844+00
2	branding	{"app_name":"Sistem Pelimpahan","app_subtitle":"Dana UP/GU","logo_url":"https://pelimpahan.keudisdiksulteng.web.id/uploads/logo_20251218225558.png"}	2025-12-18 09:10:40.094805+00	2025-12-18 14:56:02.124362+00
3	report_header	{"header":{"alamat":"Jalan Setia Budi No. 9 Palu Telp. (0451) 421290, 421090, 421190 Faxmile 428490","dinas":"DINAS PENDIDIKAN","instansi":"PEMERINTAH PROVINSI SULAWESI TENGAH","logo_url":"/uploads/report_logo_20251219193752.png"},"signatory_left":{"jabatan":"Bendahara Pengeluaran,","nama":"ASTUTY SULISTIYANTY, ST\\t\\t","nip":"NIP. 19800924 201001 2 004"},"signatory_right":{"jabatan":"Pengguna Anggaran,","nama":"YUDIAWATI V. WINDARRUSLIANA, SKM., M.Kes\\t","nip":"NIP. 19670712 199003 2 013\\t"}}	2025-12-19 11:38:50.432805+00	2025-12-19 11:38:50.432805+00
\.


--
-- Data for Name: top_up_saldos; Type: TABLE DATA; Schema: public; Owner: pelimpahan_user
--

COPY public.top_up_saldos (id, tanggal, jumlah, keterangan, created_by, created_at, updated_at, tahun_anggaran) FROM stdin;
2	2025-05-07	35661500.00	Penerimaan GU	1	2025-12-20 13:38:54.510376+00	2025-12-20 13:38:54.510376+00	2025
3	2025-05-26	16785600.00	GU-3	1	2025-12-20 13:43:37.413178+00	2025-12-20 13:43:37.413178+00	2025
4	2025-05-26	33127398.00	GU-2	1	2025-12-20 13:44:07.706736+00	2025-12-20 13:44:07.706736+00	2025
\.


--
-- Data for Name: units; Type: TABLE DATA; Schema: public; Owner: pelimpahan_user
--

COPY public.units (id, kode_unit, nama_unit, nama_pimpinan, nama_bendahara, nomor_rekening, created_at, updated_at, n_ip_pimpinan, n_ip_bendahara) FROM stdin;
4	001	Sekretariat	Dr. ASRUL ACHMAD, S.Pd.,M.Si	LISTIAWATI S. TAMA, SE	0010103002313	2025-12-18 07:45:56.61689+00	2025-12-18 07:45:56.61689+00	\N	\N
5	002	Bidang Pembinaan SMK	ZULFIKAR IS PAUDI, S.Pd.,M.Si	NURMALA SARI SOULISA, ST.,M.A.P	0010103002501	2025-12-18 07:45:56.627056+00	2025-12-18 07:45:56.627056+00	\N	\N
6	003	Bidang PKPLK & IP	NURSEHA, S.Sos.,M.Si	NIDYA WIDIASTUTI, SM	0010103002140	2025-12-18 07:45:56.629986+00	2025-12-18 07:45:56.629986+00	\N	\N
7	004	Bidang PTK & Fasilitasi Tugas Pembantuan	MUNASHIR, SE.,MM	ELYA ROSA YULIANTI, SE	0010103001985	2025-12-18 07:45:56.633172+00	2025-12-18 07:45:56.633172+00	\N	\N
8	005	Bidang Pembinaan SMA	M. YUNUS, SE	NURAFNI SETIAWATI, SP	0010103002335	2025-12-18 07:45:56.637266+00	2025-12-18 07:45:56.637266+00	\N	\N
9	006	Cabang Dinas Wilayah 1	KRISTI ARIA PRATAMA, SH.,M.Si	SRI ASTUTI, S.SI	0010103000600	2025-12-18 07:45:56.639723+00	2025-12-18 07:45:56.639723+00	\N	\N
10	007	Cabang Dinas Wilayah 2	SARIFAH, S.Pd.,M.Pd	NOFRINCE LAGENTU, SE	0010103000386	2025-12-18 07:45:56.64311+00	2025-12-18 07:45:56.64311+00	\N	\N
11	008	Cabang Dinas Wilayah 3	ALWI ACHMAD MUSA, S.Sos	SYAFRINI, SE	0030103000045	2025-12-18 07:45:56.645992+00	2025-12-18 07:45:56.645992+00	\N	\N
12	009	Cabang Dinas Wilayah 4	SOFIAN, SE.,MM	SARI MUTIA B. SAPPE, S.Si	0010103000320	2025-12-18 07:45:56.648448+00	2025-12-18 07:45:56.648448+00	\N	\N
13	010	Cabang Dinas Wilayah 5	YASSER MASULILI, S.Ag.,M.A.P	LELY SUPU, S.Pd	0040102008472	2025-12-18 07:45:56.650238+00	2025-12-18 07:45:56.650238+00	\N	\N
14	011	Cabang Dinas Wilayah 6	FITRIYAH IHWANI, S.Sos.,MM	VINA ANGRIANA, S.Sos	0010103000714	2025-12-18 07:45:56.651941+00	2025-12-18 07:45:56.651941+00	\N	\N
15	012	DAK SMK	Yudiawati	ASTUTY SULISTIYANTY, ST	0010103240216	2025-12-18 11:01:44.513308+00	2025-12-18 11:02:39.721616+00	\N	\N
19	014	UPTD. BLPT	YUDIAWATI	ASTUTY SULISTIYANTY, ST	0010103240216	2025-12-18 12:43:31.917733+00	2025-12-18 12:43:31.917733+00	\N	\N
18	013	DAK SMA	YUDIAWATI	ASTUTY SULISTIYANTY, ST	0010103240216	2025-12-18 12:43:05.224711+00	2025-12-19 06:05:19.470667+00	\N	\N
20	015	DINAS	YUDIAWATI	ASTUTY SULISTIYANTY, ST	0010103240216	2025-12-20 07:15:22.801252+00	2025-12-20 07:15:22.801252+00	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: pelimpahan_user
--

COPY public.users (id, name, email, password, role, avatar, is_active, created_at, updated_at, username) FROM stdin;
1	Asriyanto	admin@pelimpahan.local	$2a$10$d7UGOabDOTi.jYEpeDd8LOJq9KP.Vk5rCbbUyy8Ds.RMp/lAqNMUS	super_admin	http://pelimpahan.keudisdiksulteng.web.id/uploads/avatar_20251219133741_admin_pelimpahan.local.png	t	2025-12-18 07:20:40.456917+00	2025-12-19 05:37:53.758728+00	admin
2	Astuty Sulistiyanti, ST	bendahara@pelimpahan.local	$2a$10$d7UGOabDOTi.jYEpeDd8LOJq9KP.Vk5rCbbUyy8Ds.RMp/lAqNMUS	bendahara	\N	t	2025-12-18 07:20:40.459772+00	2025-12-18 08:54:48.963773+00	bendahara
3	Operator Input	operator@pelimpahan.local	$2a$10$d7UGOabDOTi.jYEpeDd8LOJq9KP.Vk5rCbbUyy8Ds.RMp/lAqNMUS	operator		f	2025-12-18 07:20:40.460935+00	2025-12-20 10:32:47.261592+00	operator
\.


--
-- Name: backup_histories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pelimpahan_user
--

SELECT pg_catalog.setval('public.backup_histories_id_seq', 1, false);


--
-- Name: backup_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pelimpahan_user
--

SELECT pg_catalog.setval('public.backup_settings_id_seq', 1, true);


--
-- Name: jenis_pelimpahans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pelimpahan_user
--

SELECT pg_catalog.setval('public.jenis_pelimpahans_id_seq', 4, true);


--
-- Name: pelimpahan_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pelimpahan_user
--

SELECT pg_catalog.setval('public.pelimpahan_details_id_seq', 130, true);


--
-- Name: pelimpahans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pelimpahan_user
--

SELECT pg_catalog.setval('public.pelimpahans_id_seq', 22, true);


--
-- Name: penarikan_tunais_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pelimpahan_user
--

SELECT pg_catalog.setval('public.penarikan_tunais_id_seq', 4, true);


--
-- Name: saldo_bendaharas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pelimpahan_user
--

SELECT pg_catalog.setval('public.saldo_bendaharas_id_seq', 1, true);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pelimpahan_user
--

SELECT pg_catalog.setval('public.settings_id_seq', 3, true);


--
-- Name: top_up_saldos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pelimpahan_user
--

SELECT pg_catalog.setval('public.top_up_saldos_id_seq', 4, true);


--
-- Name: units_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pelimpahan_user
--

SELECT pg_catalog.setval('public.units_id_seq', 20, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pelimpahan_user
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- Name: backup_histories backup_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.backup_histories
    ADD CONSTRAINT backup_histories_pkey PRIMARY KEY (id);


--
-- Name: backup_settings backup_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.backup_settings
    ADD CONSTRAINT backup_settings_pkey PRIMARY KEY (id);


--
-- Name: jenis_pelimpahans jenis_pelimpahans_kode_jenis_key; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.jenis_pelimpahans
    ADD CONSTRAINT jenis_pelimpahans_kode_jenis_key UNIQUE (kode_jenis);


--
-- Name: jenis_pelimpahans jenis_pelimpahans_pkey; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.jenis_pelimpahans
    ADD CONSTRAINT jenis_pelimpahans_pkey PRIMARY KEY (id);


--
-- Name: pelimpahan_details pelimpahan_details_pkey; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.pelimpahan_details
    ADD CONSTRAINT pelimpahan_details_pkey PRIMARY KEY (id);


--
-- Name: pelimpahans pelimpahans_pkey; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.pelimpahans
    ADD CONSTRAINT pelimpahans_pkey PRIMARY KEY (id);


--
-- Name: penarikan_tunais penarikan_tunais_pkey; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.penarikan_tunais
    ADD CONSTRAINT penarikan_tunais_pkey PRIMARY KEY (id);


--
-- Name: saldo_bendaharas saldo_bendaharas_pkey; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.saldo_bendaharas
    ADD CONSTRAINT saldo_bendaharas_pkey PRIMARY KEY (id);


--
-- Name: settings settings_key_key; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key UNIQUE (key);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: top_up_saldos top_up_saldos_pkey; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.top_up_saldos
    ADD CONSTRAINT top_up_saldos_pkey PRIMARY KEY (id);


--
-- Name: units units_kode_unit_key; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_kode_unit_key UNIQUE (kode_unit);


--
-- Name: units units_pkey; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: pelimpahan_user
--

CREATE UNIQUE INDEX idx_users_username ON public.users USING btree (username);


--
-- Name: backup_histories fk_backup_histories_creator; Type: FK CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.backup_histories
    ADD CONSTRAINT fk_backup_histories_creator FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: pelimpahan_details fk_pelimpahan_details_unit; Type: FK CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.pelimpahan_details
    ADD CONSTRAINT fk_pelimpahan_details_unit FOREIGN KEY (unit_id) REFERENCES public.units(id);


--
-- Name: pelimpahans fk_pelimpahans_creator; Type: FK CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.pelimpahans
    ADD CONSTRAINT fk_pelimpahans_creator FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: pelimpahan_details fk_pelimpahans_details; Type: FK CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.pelimpahan_details
    ADD CONSTRAINT fk_pelimpahans_details FOREIGN KEY (pelimpahan_id) REFERENCES public.pelimpahans(id);


--
-- Name: pelimpahans fk_pelimpahans_jenis_pelimpahan; Type: FK CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.pelimpahans
    ADD CONSTRAINT fk_pelimpahans_jenis_pelimpahan FOREIGN KEY (jenis_pelimpahan_id) REFERENCES public.jenis_pelimpahans(id);


--
-- Name: penarikan_tunais fk_penarikan_tunais_creator; Type: FK CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.penarikan_tunais
    ADD CONSTRAINT fk_penarikan_tunais_creator FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: saldo_bendaharas fk_saldo_bendaharas_creator; Type: FK CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.saldo_bendaharas
    ADD CONSTRAINT fk_saldo_bendaharas_creator FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: top_up_saldos fk_top_up_saldos_creator; Type: FK CONSTRAINT; Schema: public; Owner: pelimpahan_user
--

ALTER TABLE ONLY public.top_up_saldos
    ADD CONSTRAINT fk_top_up_saldos_creator FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pelimpahan_user
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

\unrestrict gIMshx3Kw7vZfe3sU6VdmJdUtmtxqXW2Jo44gMI1GiaWtnmPDfthIfvrBuljsQH

