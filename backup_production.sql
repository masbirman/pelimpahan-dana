--
-- PostgreSQL database dump
--


-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: jenis_pelimpahans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jenis_pelimpahans (
    id bigint NOT NULL,
    kode_jenis character varying(50) NOT NULL,
    nama_jenis character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: jenis_pelimpahans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jenis_pelimpahans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jenis_pelimpahans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jenis_pelimpahans_id_seq OWNED BY public.jenis_pelimpahans.id;


--
-- Name: pelimpahan_details; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: pelimpahan_details_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pelimpahan_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pelimpahan_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pelimpahan_details_id_seq OWNED BY public.pelimpahan_details.id;


--
-- Name: pelimpahans; Type: TABLE; Schema: public; Owner: -
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
    sumber_dana character varying(10) DEFAULT 'bank'::character varying NOT NULL
);


--
-- Name: pelimpahans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pelimpahans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pelimpahans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pelimpahans_id_seq OWNED BY public.pelimpahans.id;


--
-- Name: penarikan_tunais; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.penarikan_tunais (
    id bigint NOT NULL,
    tanggal date NOT NULL,
    jumlah numeric(15,2) NOT NULL,
    keterangan text NOT NULL,
    created_by bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: penarikan_tunais_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.penarikan_tunais_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: penarikan_tunais_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.penarikan_tunais_id_seq OWNED BY public.penarikan_tunais.id;


--
-- Name: saldo_bendaharas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.saldo_bendaharas (
    id bigint NOT NULL,
    tanggal date NOT NULL,
    saldo_bank numeric(15,2) DEFAULT 0 NOT NULL,
    saldo_tunai numeric(15,2) DEFAULT 0 NOT NULL,
    keterangan text,
    created_by bigint,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: saldo_bendaharas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.saldo_bendaharas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: saldo_bendaharas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.saldo_bendaharas_id_seq OWNED BY public.saldo_bendaharas.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.settings (
    id bigint NOT NULL,
    key character varying(100) NOT NULL,
    value text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: top_up_saldos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.top_up_saldos (
    id bigint NOT NULL,
    tanggal date NOT NULL,
    jumlah numeric(15,2) NOT NULL,
    keterangan text NOT NULL,
    created_by bigint NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: top_up_saldos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.top_up_saldos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: top_up_saldos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.top_up_saldos_id_seq OWNED BY public.top_up_saldos.id;


--
-- Name: units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.units (
    id bigint NOT NULL,
    kode_unit character varying(50) NOT NULL,
    nama_unit character varying(255) NOT NULL,
    nama_pimpinan character varying(255),
    nama_bendahara character varying(255) NOT NULL,
    nomor_rekening character varying(50) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.units_id_seq OWNED BY public.units.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
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
    updated_at timestamp with time zone
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
-- Name: jenis_pelimpahans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jenis_pelimpahans ALTER COLUMN id SET DEFAULT nextval('public.jenis_pelimpahans_id_seq'::regclass);


--
-- Name: pelimpahan_details id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelimpahan_details ALTER COLUMN id SET DEFAULT nextval('public.pelimpahan_details_id_seq'::regclass);


--
-- Name: pelimpahans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelimpahans ALTER COLUMN id SET DEFAULT nextval('public.pelimpahans_id_seq'::regclass);


--
-- Name: penarikan_tunais id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.penarikan_tunais ALTER COLUMN id SET DEFAULT nextval('public.penarikan_tunais_id_seq'::regclass);


--
-- Name: saldo_bendaharas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saldo_bendaharas ALTER COLUMN id SET DEFAULT nextval('public.saldo_bendaharas_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: top_up_saldos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.top_up_saldos ALTER COLUMN id SET DEFAULT nextval('public.top_up_saldos_id_seq'::regclass);


--
-- Name: units id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units ALTER COLUMN id SET DEFAULT nextval('public.units_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: jenis_pelimpahans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.jenis_pelimpahans (id, kode_jenis, nama_jenis, created_at, updated_at) FROM stdin;
1	UP	Uang Persediaan	2025-12-18 15:20:40.462038+08	2025-12-18 15:20:40.462038+08
2	GU	Ganti Uang	2025-12-18 15:20:40.464654+08	2025-12-18 15:20:40.464654+08
3	TU	Tambahan Uang	2025-12-18 15:20:40.466179+08	2025-12-18 15:20:40.466179+08
4	LS	Langsung	2025-12-18 15:20:40.467708+08	2025-12-18 15:20:40.467708+08
\.


--
-- Data for Name: pelimpahan_details; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pelimpahan_details (id, pelimpahan_id, unit_id, nama_penerima, nomor_rekening, jumlah, created_at, updated_at, sumber_dana) FROM stdin;
\.


--
-- Data for Name: pelimpahans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pelimpahans (id, nomor_pelimpahan, waktu_pelimpahan, tanggal_pelimpahan, uraian_pelimpahan, jenis_pelimpahan_id, created_by, total_jumlah, created_at, updated_at, sumber_dana) FROM stdin;
\.


--
-- Data for Name: penarikan_tunais; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.penarikan_tunais (id, tanggal, jumlah, keterangan, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: saldo_bendaharas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.saldo_bendaharas (id, tanggal, saldo_bank, saldo_tunai, keterangan, created_by, created_at, updated_at) FROM stdin;
1	2025-02-05	3000000000.00	0.00	Saldo Awal Uang Persediaan (UP)	1	2025-12-18 18:01:46.464592+08	2025-12-18 18:01:46.464592+08
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.settings (id, key, value, created_at, updated_at) FROM stdin;
2	branding	{"app_name":"Sistem Pelimpahan","app_subtitle":"Dana UP/GU","logo_url":"https://pelimpahan.keudisdiksulteng.web.id/uploads/logo_20251218225558.png"}	2025-12-18 17:10:40.094805+08	2025-12-18 22:56:02.124362+08
1	countdown	{"active":true,"description":"Penatausahaan Keuangan akan berakhir tanggal 31 Desember 2025","target_date":"2025-12-31T00:00","title":"Jadwal Penatausahaan Tahun 2025"}	2025-12-18 16:46:06.739945+08	2025-12-18 22:57:26.031844+08
\.


--
-- Data for Name: top_up_saldos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.top_up_saldos (id, tanggal, jumlah, keterangan, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: units; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.units (id, kode_unit, nama_unit, nama_pimpinan, nama_bendahara, nomor_rekening, created_at, updated_at) FROM stdin;
4	001	Sekretariat	Dr. ASRUL ACHMAD, S.Pd.,M.Si	LISTIAWATI S. TAMA, SE	0010103002313	2025-12-18 15:45:56.61689+08	2025-12-18 15:45:56.61689+08
5	002	Bidang Pembinaan SMK	ZULFIKAR IS PAUDI, S.Pd.,M.Si	NURMALA SARI SOULISA, ST.,M.A.P	0010103002501	2025-12-18 15:45:56.627056+08	2025-12-18 15:45:56.627056+08
6	003	Bidang PKPLK & IP	NURSEHA, S.Sos.,M.Si	NIDYA WIDIASTUTI, SM	0010103002140	2025-12-18 15:45:56.629986+08	2025-12-18 15:45:56.629986+08
7	004	Bidang PTK & Fasilitasi Tugas Pembantuan	MUNASHIR, SE.,MM	ELYA ROSA YULIANTI, SE	0010103001985	2025-12-18 15:45:56.633172+08	2025-12-18 15:45:56.633172+08
8	005	Bidang Pembinaan SMA	M. YUNUS, SE	NURAFNI SETIAWATI, SP	0010103002335	2025-12-18 15:45:56.637266+08	2025-12-18 15:45:56.637266+08
9	006	Cabang Dinas Wilayah 1	KRISTI ARIA PRATAMA, SH.,M.Si	SRI ASTUTI, S.SI	0010103000600	2025-12-18 15:45:56.639723+08	2025-12-18 15:45:56.639723+08
10	007	Cabang Dinas Wilayah 2	SARIFAH, S.Pd.,M.Pd	NOFRINCE LAGENTU, SE	0010103000386	2025-12-18 15:45:56.64311+08	2025-12-18 15:45:56.64311+08
11	008	Cabang Dinas Wilayah 3	ALWI ACHMAD MUSA, S.Sos	SYAFRINI, SE	0030103000045	2025-12-18 15:45:56.645992+08	2025-12-18 15:45:56.645992+08
12	009	Cabang Dinas Wilayah 4	SOFIAN, SE.,MM	SARI MUTIA B. SAPPE, S.Si	0010103000320	2025-12-18 15:45:56.648448+08	2025-12-18 15:45:56.648448+08
13	010	Cabang Dinas Wilayah 5	YASSER MASULILI, S.Ag.,M.A.P	LELY SUPU, S.Pd	0040102008472	2025-12-18 15:45:56.650238+08	2025-12-18 15:45:56.650238+08
14	011	Cabang Dinas Wilayah 6	FITRIYAH IHWANI, S.Sos.,MM	VINA ANGRIANA, S.Sos	0010103000714	2025-12-18 15:45:56.651941+08	2025-12-18 15:45:56.651941+08
15	012	DAK SMK	Yudiawati	ASTUTY SULISTIYANTY, ST	0010103240216	2025-12-18 19:01:44.513308+08	2025-12-18 19:02:39.721616+08
18	013	\tDAK SMK	YUDIAWATI	ASTUTY SULISTIYANTY, ST	0010103240216	2025-12-18 20:43:05.224711+08	2025-12-18 20:43:05.224711+08
19	014	UPTD. BLPT	YUDIAWATI	ASTUTY SULISTIYANTY, ST	0010103240216	2025-12-18 20:43:31.917733+08	2025-12-18 20:43:31.917733+08
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, name, email, password, role, avatar, is_active, created_at, updated_at) FROM stdin;
3	Operator Input	operator@pelimpahan.local	$2a$10$d7UGOabDOTi.jYEpeDd8LOJq9KP.Vk5rCbbUyy8Ds.RMp/lAqNMUS	operator	\N	t	2025-12-18 15:20:40.460935+08	2025-12-18 15:20:40.460935+08
2	Astuty Sulistiyanti, ST	bendahara@pelimpahan.local	$2a$10$d7UGOabDOTi.jYEpeDd8LOJq9KP.Vk5rCbbUyy8Ds.RMp/lAqNMUS	bendahara	\N	t	2025-12-18 15:20:40.459772+08	2025-12-18 16:54:48.963773+08
1	Asriyanto	admin@pelimpahan.local	$2a$10$d7UGOabDOTi.jYEpeDd8LOJq9KP.Vk5rCbbUyy8Ds.RMp/lAqNMUS	super_admin	https://pelimpahan.keudisdiksulteng.web.id/uploads/avatar_20251218225545_admin_pelimpahan.local.png	t	2025-12-18 15:20:40.456917+08	2025-12-18 22:55:48.768897+08
\.


--
-- Name: jenis_pelimpahans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.jenis_pelimpahans_id_seq', 4, true);


--
-- Name: pelimpahan_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pelimpahan_details_id_seq', 43, true);


--
-- Name: pelimpahans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pelimpahans_id_seq', 5, true);


--
-- Name: penarikan_tunais_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.penarikan_tunais_id_seq', 1, false);


--
-- Name: saldo_bendaharas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.saldo_bendaharas_id_seq', 1, true);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.settings_id_seq', 2, true);


--
-- Name: top_up_saldos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.top_up_saldos_id_seq', 1, false);


--
-- Name: units_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.units_id_seq', 19, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- Name: jenis_pelimpahans jenis_pelimpahans_kode_jenis_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jenis_pelimpahans
    ADD CONSTRAINT jenis_pelimpahans_kode_jenis_key UNIQUE (kode_jenis);


--
-- Name: jenis_pelimpahans jenis_pelimpahans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jenis_pelimpahans
    ADD CONSTRAINT jenis_pelimpahans_pkey PRIMARY KEY (id);


--
-- Name: pelimpahan_details pelimpahan_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelimpahan_details
    ADD CONSTRAINT pelimpahan_details_pkey PRIMARY KEY (id);


--
-- Name: pelimpahans pelimpahans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelimpahans
    ADD CONSTRAINT pelimpahans_pkey PRIMARY KEY (id);


--
-- Name: penarikan_tunais penarikan_tunais_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.penarikan_tunais
    ADD CONSTRAINT penarikan_tunais_pkey PRIMARY KEY (id);


--
-- Name: saldo_bendaharas saldo_bendaharas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saldo_bendaharas
    ADD CONSTRAINT saldo_bendaharas_pkey PRIMARY KEY (id);


--
-- Name: settings settings_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_key_key UNIQUE (key);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: top_up_saldos top_up_saldos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.top_up_saldos
    ADD CONSTRAINT top_up_saldos_pkey PRIMARY KEY (id);


--
-- Name: units units_kode_unit_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_kode_unit_key UNIQUE (kode_unit);


--
-- Name: units units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: pelimpahan_details fk_pelimpahan_details_unit; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelimpahan_details
    ADD CONSTRAINT fk_pelimpahan_details_unit FOREIGN KEY (unit_id) REFERENCES public.units(id);


--
-- Name: pelimpahans fk_pelimpahans_creator; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelimpahans
    ADD CONSTRAINT fk_pelimpahans_creator FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: pelimpahan_details fk_pelimpahans_details; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelimpahan_details
    ADD CONSTRAINT fk_pelimpahans_details FOREIGN KEY (pelimpahan_id) REFERENCES public.pelimpahans(id);


--
-- Name: pelimpahans fk_pelimpahans_jenis_pelimpahan; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pelimpahans
    ADD CONSTRAINT fk_pelimpahans_jenis_pelimpahan FOREIGN KEY (jenis_pelimpahan_id) REFERENCES public.jenis_pelimpahans(id);


--
-- Name: penarikan_tunais fk_penarikan_tunais_creator; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.penarikan_tunais
    ADD CONSTRAINT fk_penarikan_tunais_creator FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: saldo_bendaharas fk_saldo_bendaharas_creator; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.saldo_bendaharas
    ADD CONSTRAINT fk_saldo_bendaharas_creator FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: top_up_saldos fk_top_up_saldos_creator; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.top_up_saldos
    ADD CONSTRAINT fk_top_up_saldos_creator FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--



