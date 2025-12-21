--
-- PostgreSQL database dump
--

-- Dumped from database version 15.15 (Debian 15.15-1.pgdg13+1)
-- Dumped by pg_dump version 15.15

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

CREATE SEQUENCE public.backup_histories_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.backup_histories_id_seq OWNED BY public.backup_histories.id;

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

CREATE SEQUENCE public.backup_settings_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.backup_settings_id_seq OWNED BY public.backup_settings.id;

CREATE TABLE public.jenis_pelimpahans (
    id bigint NOT NULL,
    kode_jenis character varying(50) NOT NULL,
    nama_jenis character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);

CREATE SEQUENCE public.jenis_pelimpahans_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.jenis_pelimpahans_id_seq OWNED BY public.jenis_pelimpahans.id;

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

CREATE SEQUENCE public.pelimpahan_details_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.pelimpahan_details_id_seq OWNED BY public.pelimpahan_details.id;

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

CREATE SEQUENCE public.pelimpahans_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.pelimpahans_id_seq OWNED BY public.pelimpahans.id;

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

CREATE SEQUENCE public.penarikan_tunais_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.penarikan_tunais_id_seq OWNED BY public.penarikan_tunais.id;

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

CREATE SEQUENCE public.saldo_bendaharas_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.saldo_bendaharas_id_seq OWNED BY public.saldo_bendaharas.id;

CREATE TABLE public.settings (
    id bigint NOT NULL,
    key character varying(100) NOT NULL,
    value text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);

CREATE SEQUENCE public.settings_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;

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

CREATE SEQUENCE public.top_up_saldos_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.top_up_saldos_id_seq OWNED BY public.top_up_saldos.id;

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

CREATE SEQUENCE public.units_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.units_id_seq OWNED BY public.units.id;

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

CREATE SEQUENCE public.users_id_seq START WITH 1 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;

ALTER TABLE ONLY public.backup_histories ALTER COLUMN id SET DEFAULT nextval('public.backup_histories_id_seq'::regclass);
ALTER TABLE ONLY public.backup_settings ALTER COLUMN id SET DEFAULT nextval('public.backup_settings_id_seq'::regclass);
ALTER TABLE ONLY public.jenis_pelimpahans ALTER COLUMN id SET DEFAULT nextval('public.jenis_pelimpahans_id_seq'::regclass);
ALTER TABLE ONLY public.pelimpahan_details ALTER COLUMN id SET DEFAULT nextval('public.pelimpahan_details_id_seq'::regclass);
ALTER TABLE ONLY public.pelimpahans ALTER COLUMN id SET DEFAULT nextval('public.pelimpahans_id_seq'::regclass);
ALTER TABLE ONLY public.penarikan_tunais ALTER COLUMN id SET DEFAULT nextval('public.penarikan_tunais_id_seq'::regclass);
ALTER TABLE ONLY public.saldo_bendaharas ALTER COLUMN id SET DEFAULT nextval('public.saldo_bendaharas_id_seq'::regclass);
ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);
ALTER TABLE ONLY public.top_up_saldos ALTER COLUMN id SET DEFAULT nextval('public.top_up_saldos_id_seq'::regclass);
ALTER TABLE ONLY public.units ALTER COLUMN id SET DEFAULT nextval('public.units_id_seq'::regclass);
ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);

-- Data
INSERT INTO public.backup_settings VALUES (1, false, 'daily', '02:00', 30, false, '', '', '', '2025-12-20 12:05:39.671702+00', '2025-12-20 12:05:39.671702+00');
INSERT INTO public.jenis_pelimpahans VALUES (1, 'UP / GU', 'Uang Persediaan / Ganti Uang Persediaan', '2025-12-18 07:20:40.462038+00', '2025-12-20 13:30:18.581885+00');
INSERT INTO public.saldo_bendaharas VALUES (1, '2025-02-05', 3000000000.00, 0.00, 'Saldo Awal Uang Persediaan (UP)', 1, '2025-12-18 10:01:46.464592+00', '2025-12-18 10:01:46.464592+00', 2025);

INSERT INTO public.users VALUES (1, 'Asriyanto', 'admin@pelimpahan.local', '$2a$10$d7UGOabDOTi.jYEpeDd8LOJq9KP.Vk5rCbbUyy8Ds.RMp/lAqNMUS', 'super_admin', 'http://pelimpahan.keudisdiksulteng.web.id/uploads/avatar_20251219133741_admin_pelimpahan.local.png', true, '2025-12-18 07:20:40.456917+00', '2025-12-19 05:37:53.758728+00', 'admin');
INSERT INTO public.users VALUES (3, 'Operator Input', 'operator@pelimpahan.local', '$2a$10$d7UGOabDOTi.jYEpeDd8LOJq9KP.Vk5rCbbUyy8Ds.RMp/lAqNMUS', 'operator', '', false, '2025-12-18 07:20:40.460935+00', '2025-12-20 10:32:47.261592+00', 'operator');
INSERT INTO public.users VALUES (2, 'Astuty Sulistiyanti, ST', 'bendahara@pelimpahan.local', '$2a$10$JHonRFyEiC3HVYwtcyppOu1UDdhEr0SaoInZ6EDO.AFgmav1P/NG2', 'bendahara', 'http://pelimpahan.keudisdiksulteng.web.id/uploads/avatar_20251221152214_.png', true, '2025-12-18 07:20:40.459772+00', '2025-12-21 07:22:17.516374+00', 'bendahara');

INSERT INTO public.units VALUES (4, '001', 'Sekretariat', 'Dr. ASRUL ACHMAD, S.Pd.,M.Si', 'LISTIAWATI S. TAMA, SE', '0010103002313', '2025-12-18 07:45:56.61689+00', '2025-12-18 07:45:56.61689+00', NULL, NULL);
INSERT INTO public.units VALUES (5, '002', 'Bidang Pembinaan SMK', 'ZULFIKAR IS PAUDI, S.Pd.,M.Si', 'NURMALA SARI SOULISA, ST.,M.A.P', '0010103002501', '2025-12-18 07:45:56.627056+00', '2025-12-18 07:45:56.627056+00', NULL, NULL);
INSERT INTO public.units VALUES (6, '003', 'Bidang PKPLK & IP', 'NURSEHA, S.Sos.,M.Si', 'NIDYA WIDIASTUTI, SM', '0010103002140', '2025-12-18 07:45:56.629986+00', '2025-12-18 07:45:56.629986+00', NULL, NULL);
INSERT INTO public.units VALUES (7, '004', 'Bidang PTK & Fasilitasi Tugas Pembantuan', 'MUNASHIR, SE.,MM', 'ELYA ROSA YULIANTI, SE', '0010103001985', '2025-12-18 07:45:56.633172+00', '2025-12-18 07:45:56.633172+00', NULL, NULL);
INSERT INTO public.units VALUES (8, '005', 'Bidang Pembinaan SMA', 'M. YUNUS, SE', 'NURAFNI SETIAWATI, SP', '0010103002335', '2025-12-18 07:45:56.637266+00', '2025-12-18 07:45:56.637266+00', NULL, NULL);
INSERT INTO public.units VALUES (9, '006', 'Cabang Dinas Wilayah 1', 'KRISTI ARIA PRATAMA, SH.,M.Si', 'SRI ASTUTI, S.SI', '0010103000600', '2025-12-18 07:45:56.639723+00', '2025-12-18 07:45:56.639723+00', NULL, NULL);
INSERT INTO public.units VALUES (10, '007', 'Cabang Dinas Wilayah 2', 'SARIFAH, S.Pd.,M.Pd', 'NOFRINCE LAGENTU, SE', '0010103000386', '2025-12-18 07:45:56.64311+00', '2025-12-18 07:45:56.64311+00', NULL, NULL);
INSERT INTO public.units VALUES (11, '008', 'Cabang Dinas Wilayah 3', 'ALWI ACHMAD MUSA, S.Sos', 'SYAFRINI, SE', '0030103000045', '2025-12-18 07:45:56.645992+00', '2025-12-18 07:45:56.645992+00', NULL, NULL);
INSERT INTO public.units VALUES (12, '009', 'Cabang Dinas Wilayah 4', 'SOFIAN, SE.,MM', 'SARI MUTIA B. SAPPE, S.Si', '0010103000320', '2025-12-18 07:45:56.648448+00', '2025-12-18 07:45:56.648448+00', NULL, NULL);
INSERT INTO public.units VALUES (13, '010', 'Cabang Dinas Wilayah 5', 'YASSER MASULILI, S.Ag.,M.A.P', 'LELY SUPU, S.Pd', '0040102008472', '2025-12-18 07:45:56.650238+00', '2025-12-18 07:45:56.650238+00', NULL, NULL);
INSERT INTO public.units VALUES (14, '011', 'Cabang Dinas Wilayah 6', 'FITRIYAH IHWANI, S.Sos.,MM', 'VINA ANGRIANA, S.Sos', '0010103000714', '2025-12-18 07:45:56.651941+00', '2025-12-18 07:45:56.651941+00', NULL, NULL);
INSERT INTO public.units VALUES (15, '012', 'DAK SMK', 'Yudiawati', 'ASTUTY SULISTIYANTY, ST', '0010103240216', '2025-12-18 11:01:44.513308+00', '2025-12-18 11:02:39.721616+00', NULL, NULL);
INSERT INTO public.units VALUES (19, '014', 'UPTD. BLPT', 'YUDIAWATI', 'ASTUTY SULISTIYANTY, ST', '0010103240216', '2025-12-18 12:43:31.917733+00', '2025-12-18 12:43:31.917733+00', NULL, NULL);
INSERT INTO public.units VALUES (18, '013', 'DAK SMA', 'YUDIAWATI', 'ASTUTY SULISTIYANTY, ST', '0010103240216', '2025-12-18 12:43:05.224711+00', '2025-12-19 06:05:19.470667+00', NULL, NULL);
INSERT INTO public.units VALUES (20, '015', 'DINAS', 'YUDIAWATI', 'ASTUTY SULISTIYANTY, ST', '0010103240216', '2025-12-20 07:15:22.801252+00', '2025-12-20 07:15:22.801252+00', NULL, NULL);

INSERT INTO public.settings VALUES (1, 'countdown', '{"active":true,"description":"Penatausahaan Keuangan akan berakhir tanggal 31 Desember 2025","target_date":"2025-12-31T00:00","title":"Jadwal Penatausahaan Tahun 2025"}', '2025-12-18 08:46:06.739945+00', '2025-12-18 14:57:26.031844+00');
INSERT INTO public.settings VALUES (2, 'branding', '{"app_name":"Sistem Pelimpahan","app_subtitle":"Dana UP/GU","logo_url":"https://pelimpahan.keudisdiksulteng.web.id/uploads/logo_20251218225558.png"}', '2025-12-18 09:10:40.094805+00', '2025-12-18 14:56:02.124362+00');
INSERT INTO public.settings VALUES (3, 'report_header', '{"header":{"alamat":"Jalan Setia Budi No. 9 Palu Telp. (0451) 421290, 421090, 421190 Faxmile 428490","dinas":"DINAS PENDIDIKAN","instansi":"PEMERINTAH PROVINSI SULAWESI TENGAH","logo_url":"/uploads/report_logo_20251219193752.png"},"signatory_left":{"jabatan":"Bendahara Pengeluaran,","nama":"ASTUTY SULISTIYANTY, ST\\t\\t","nip":"NIP. 19800924 201001 2 004"},"signatory_right":{"jabatan":"Pengguna Anggaran,","nama":"YUDIAWATI V. WINDARRUSLIANA, SKM., M.Kes\\t","nip":"NIP. 19670712 199003 2 013\\t"}}', '2025-12-19 11:38:50.432805+00', '2025-12-19 11:38:50.432805+00');

INSERT INTO public.penarikan_tunais VALUES (5, '2025-03-04', 31493000.00, 'Penarikan Tunai', 1, '2025-12-21 06:57:39.059807+00', '2025-12-21 06:57:39.059807+00', 2025);
INSERT INTO public.penarikan_tunais VALUES (6, '2025-03-06', 5100000.00, 'Penarikan Tunai', 1, '2025-12-21 07:01:17.910074+00', '2025-12-21 07:01:17.910074+00', 2025);
INSERT INTO public.penarikan_tunais VALUES (7, '2025-04-23', 123185000.00, 'Penarikan Tunai', 1, '2025-12-21 07:06:00.271569+00', '2025-12-21 07:06:00.271569+00', 2025);

INSERT INTO public.top_up_saldos VALUES (16, '2025-06-20', 250933200.00, 'Pengembalian dari Bidang PTK', 1, '2025-12-21 07:31:01.945795+00', '2025-12-21 07:31:01.945795+00', 2025);
INSERT INTO public.top_up_saldos VALUES (7, '2025-05-07', 35661500.00, 'Penerimaan GU-1 Cabdis Wilayah 1', 1, '2025-12-21 07:12:06.783769+00', '2025-12-21 08:06:56.916744+00', 2025);
INSERT INTO public.top_up_saldos VALUES (9, '2025-05-26', 16785600.00, 'Penerimaan GU-3 Cabdis Wilayah 6 DAU EMARKED', 1, '2025-12-21 07:17:41.237729+00', '2025-12-21 08:07:12.282348+00', 2025);
INSERT INTO public.top_up_saldos VALUES (8, '2025-05-26', 33127398.00, 'Penerimaan GU-2 Cabdis Wilayah 6', 1, '2025-12-21 07:17:12.253601+00', '2025-12-21 08:07:25.851119+00', 2025);
INSERT INTO public.top_up_saldos VALUES (11, '2025-05-28', 39940300.00, 'Penerimaan GU-5 Cabdis Wilayah 2', 1, '2025-12-21 07:20:11.726782+00', '2025-12-21 08:07:50.004789+00', 2025);
INSERT INTO public.top_up_saldos VALUES (10, '2025-05-28', 42132250.00, 'Penerimaan GU-4 Cabdis Wilayah 5', 1, '2025-12-21 07:19:52.777825+00', '2025-12-21 08:08:03.287938+00', 2025);
INSERT INTO public.top_up_saldos VALUES (12, '2025-06-16', 673593949.00, 'Penerimaan GU-6 Dinas', 1, '2025-12-21 07:26:47.316009+00', '2025-12-21 08:08:15.629099+00', 2025);
INSERT INTO public.top_up_saldos VALUES (13, '2025-06-16', 683159336.00, 'Penerimaan GU-7 Dinas DAU EMARKED', 1, '2025-12-21 07:27:08.592562+00', '2025-12-21 08:08:28.804259+00', 2025);
INSERT INTO public.top_up_saldos VALUES (15, '2025-06-19', 15319160.00, 'Penerimaan GU-9 Cabdis Wilayah 3', 1, '2025-12-21 07:28:04.80258+00', '2025-12-21 08:08:46.028697+00', 2025);
INSERT INTO public.top_up_saldos VALUES (14, '2025-06-19', 14550000.00, 'Penerimaan GU-8 Cabdis Wulayah 3 DAU EMARKED', 1, '2025-12-21 07:27:44.828394+00', '2025-12-21 08:09:49.769085+00', 2025);
INSERT INTO public.top_up_saldos VALUES (17, '2025-06-23', 39040000.00, 'Penerimaan GU-10 Cabdis Wilayah 1 DAU EMARKED', 1, '2025-12-21 07:34:14.878953+00', '2025-12-21 08:10:15.823472+00', 2025);
INSERT INTO public.top_up_saldos VALUES (19, '2025-07-02', 23920000.00, 'Penerimaan GU-12 Cabdis Wilayah 1 DAU EMARKED', 1, '2025-12-21 07:38:13.802015+00', '2025-12-21 08:11:37.426087+00', 2025);
INSERT INTO public.top_up_saldos VALUES (18, '2025-07-02', 15350500.00, 'Penerimaan GU-11 Cabdis Wilayah 1', 1, '2025-12-21 07:37:54.378534+00', '2025-12-21 08:11:59.454573+00', 2025);
INSERT INTO public.top_up_saldos VALUES (20, '2025-07-02', 49800000.00, 'Penerimaan GU-13 Cabdis Wilayah 4 DAU EMARKED', 1, '2025-12-21 07:38:31.741405+00', '2025-12-21 08:12:17.02116+00', 2025);

INSERT INTO public.pelimpahans VALUES (10, 1, '2025-12-19 11:03:49.648689+00', '2025-02-19', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 385247000.00, '2025-12-19 11:03:49.649232+00', '2025-12-19 11:03:49.649232+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (28, 3, '2025-12-21 07:00:27.886304+00', '2025-03-05', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 96516000.00, '2025-12-21 07:00:27.886751+00', '2025-12-21 07:00:27.886751+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (27, 2, '2025-12-21 07:00:00.865765+00', '2025-03-04', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 31493000.00, '2025-12-21 07:00:00.866277+00', '2025-12-21 07:00:44.646013+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (30, 5, '2025-12-21 07:02:42.742601+00', '2025-04-09', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 91534000.00, '2025-12-21 07:02:42.742891+00', '2025-12-21 07:02:42.742891+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (31, 6, '2025-12-21 07:05:28.154594+00', '2025-04-22', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 1381428350.00, '2025-12-21 07:05:28.155049+00', '2025-12-21 07:05:28.155049+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (32, 7, '2025-12-21 07:06:41.098005+00', '2025-04-23', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 123185000.00, '2025-12-21 07:06:41.098346+00', '2025-12-21 07:07:16.516078+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (29, 4, '2025-12-21 07:01:39.737992+00', '2025-03-06', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 5100000.00, '2025-12-21 07:01:39.73839+00', '2025-12-21 07:09:50.798171+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (33, 8, '2025-12-21 07:10:50.818349+00', '2025-05-07', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 24740000.00, '2025-12-21 07:10:50.818742+00', '2025-12-21 07:11:06.312905+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (34, 9, '2025-12-21 07:14:00.142772+00', '2025-05-09', 'Pelimpahan GU', 1, 1, 35661500.00, '2025-12-21 07:14:00.143394+00', '2025-12-21 07:14:00.143394+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (35, 10, '2025-12-21 07:14:32.471702+00', '2025-05-14', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 108575000.00, '2025-12-21 07:14:32.471898+00', '2025-12-21 07:14:32.471898+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (36, 11, '2025-12-21 07:15:44.29497+00', '2025-05-16', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 20000000.00, '2025-12-21 07:15:44.295187+00', '2025-12-21 07:15:44.295187+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (37, 12, '2025-12-21 07:16:17.723249+00', '2025-05-22', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 276177000.00, '2025-12-21 07:16:17.72389+00', '2025-12-21 07:16:17.72389+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (38, 13, '2025-12-21 07:19:00.827366+00', '2025-05-27', 'Pelimpahan GU', 1, 1, 103342998.00, '2025-12-21 07:19:00.827619+00', '2025-12-21 07:19:00.827619+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (39, 14, '2025-12-21 07:24:50.443205+00', '2025-06-03', 'Pelimpahan GU', 1, 1, 82072550.00, '2025-12-21 07:24:50.443766+00', '2025-12-21 07:24:50.443766+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (40, 15, '2025-12-21 07:26:06.501768+00', '2025-06-13', 'Pelimpahan GU', 1, 1, 303184200.00, '2025-12-21 07:26:06.502137+00', '2025-12-21 07:26:06.502137+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (41, 16, '2025-12-21 07:30:10.963342+00', '2025-06-20', 'Pelimpahan GU', 1, 1, 750309300.00, '2025-12-21 07:30:10.96363+00', '2025-12-21 07:32:58.907805+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (42, 17, '2025-12-21 07:33:41.593146+00', '2025-06-23', 'Pelimpahan GU', 1, 1, 29869160.00, '2025-12-21 07:33:41.593416+00', '2025-12-21 07:33:41.593416+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (43, 18, '2025-12-21 07:35:03.057007+00', '2025-06-24', 'Pelimpahan GU', 1, 1, 39040000.00, '2025-12-21 07:35:03.057336+00', '2025-12-21 07:35:03.057336+00', 'bank', 2025);
INSERT INTO public.pelimpahans VALUES (44, 19, '2025-12-21 07:35:36.516661+00', '2025-06-26', 'Pelimpahan GU', 1, 1, 70000000.00, '2025-12-21 07:35:36.516907+00', '2025-12-21 07:35:36.516907+00', 'bank', 2025);

INSERT INTO public.pelimpahan_details VALUES (73, 10, 4, 'LISTIAWATI S. TAMA, SE', '0010103002313', 259025000.00, '2025-12-19 11:03:49.652782+00', '2025-12-19 11:03:49.652782+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (74, 10, 8, 'NURAFNI SETIAWATI, SP', '0010103002335', 4470000.00, '2025-12-19 11:03:49.655766+00', '2025-12-19 11:03:49.655766+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (75, 10, 5, 'NURMALA SARI SOULISA, ST.,M.A.P', '0010103002501', 12780000.00, '2025-12-19 11:03:49.65728+00', '2025-12-19 11:03:49.65728+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (76, 10, 7, 'ELYA ROSA YULIANTI, SE', '0010103001985', 7680000.00, '2025-12-19 11:03:49.658502+00', '2025-12-19 11:03:49.658502+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (77, 10, 9, 'SRI ASTUTI, S.SI', '0010103000600', 20652000.00, '2025-12-19 11:03:49.659668+00', '2025-12-19 11:03:49.659668+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (78, 10, 10, 'NOFRINCE LAGENTU, SE', '0010103000386', 20000000.00, '2025-12-19 11:03:49.660851+00', '2025-12-19 11:03:49.660851+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (79, 10, 11, 'SYAFRINI, SE', '0030103000045', 10640000.00, '2025-12-19 11:03:49.662115+00', '2025-12-19 11:03:49.662115+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (80, 10, 12, 'SARI MUTIA B. SAPPE, S.Si', '0010103000320', 20000000.00, '2025-12-19 11:03:49.663425+00', '2025-12-19 11:03:49.663425+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (81, 10, 13, 'LELY SUPU, S.Pd', '0040102008472', 15500000.00, '2025-12-19 11:03:49.66466+00', '2025-12-19 11:03:49.66466+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (82, 10, 14, 'VINA ANGRIANA, S.Sos', '0010103000714', 14500000.00, '2025-12-19 11:03:49.665833+00', '2025-12-19 11:03:49.665833+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (143, 28, 4, 'LISTIAWATI S. TAMA, SE', '0010103002313', 96516000.00, '2025-12-21 07:00:27.890625+00', '2025-12-21 07:00:27.890625+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (144, 27, 20, 'ASTUTY SULISTIYANTY, ST', '0010103240216', 31493000.00, '2025-12-21 07:00:44.650091+00', '2025-12-21 07:00:44.650091+00', 'tunai');
INSERT INTO public.pelimpahan_details VALUES (146, 30, 4, 'LISTIAWATI S. TAMA, SE', '0010103002313', 91534000.00, '2025-12-21 07:02:42.744872+00', '2025-12-21 07:02:42.744872+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (147, 31, 4, 'LISTIAWATI S. TAMA, SE', '0010103002313', 166884400.00, '2025-12-21 07:05:28.157463+00', '2025-12-21 07:05:28.157463+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (148, 31, 8, 'NURAFNI SETIAWATI, SP', '0010103002335', 381819400.00, '2025-12-21 07:05:28.159131+00', '2025-12-21 07:05:28.159131+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (149, 31, 5, 'NURMALA SARI SOULISA, ST.,M.A.P', '0010103002501', 457441500.00, '2025-12-21 07:05:28.16048+00', '2025-12-21 07:05:28.16048+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (150, 31, 6, 'NIDYA WIDIASTUTI, SM', '0010103002140', 182373050.00, '2025-12-21 07:05:28.161846+00', '2025-12-21 07:05:28.161846+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (151, 31, 7, 'ELYA ROSA YULIANTI, SE', '0010103001985', 53562000.00, '2025-12-21 07:05:28.163232+00', '2025-12-21 07:05:28.163232+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (152, 31, 9, 'SRI ASTUTI, S.SI', '0010103000600', 19348000.00, '2025-12-21 07:05:28.164244+00', '2025-12-21 07:05:28.164244+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (153, 31, 10, 'NOFRINCE LAGENTU, SE', '0010103000386', 20000000.00, '2025-12-21 07:05:28.165305+00', '2025-12-21 07:05:28.165305+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (154, 31, 12, 'SARI MUTIA B. SAPPE, S.Si', '0010103000320', 30000000.00, '2025-12-21 07:05:28.166472+00', '2025-12-21 07:05:28.166472+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (155, 31, 13, 'LELY SUPU, S.Pd', '0040102008472', 34500000.00, '2025-12-21 07:05:28.167484+00', '2025-12-21 07:05:28.167484+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (156, 31, 14, 'VINA ANGRIANA, S.Sos', '0010103000714', 35500000.00, '2025-12-21 07:05:28.168521+00', '2025-12-21 07:05:28.168521+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (158, 32, 20, 'ASTUTY SULISTIYANTY, ST', '0010103240216', 123185000.00, '2025-12-21 07:07:16.520144+00', '2025-12-21 07:07:16.520144+00', 'tunai');
INSERT INTO public.pelimpahan_details VALUES (159, 29, 20, 'ASTUTY SULISTIYANTY, ST', '0010103240216', 5100000.00, '2025-12-21 07:09:50.800891+00', '2025-12-21 07:09:50.800891+00', 'tunai');
INSERT INTO public.pelimpahan_details VALUES (161, 33, 11, 'SYAFRINI, SE', '0030103000045', 24740000.00, '2025-12-21 07:11:06.31592+00', '2025-12-21 07:11:06.31592+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (162, 34, 9, 'SRI ASTUTI, S.SI', '0010103000600', 35661500.00, '2025-12-21 07:14:00.146577+00', '2025-12-21 07:14:00.146577+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (163, 35, 4, 'LISTIAWATI S. TAMA, SE', '0010103002313', 108575000.00, '2025-12-21 07:14:32.473888+00', '2025-12-21 07:14:32.473888+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (164, 36, 4, 'LISTIAWATI S. TAMA, SE', '0010103002313', 20000000.00, '2025-12-21 07:15:44.297843+00', '2025-12-21 07:15:44.297843+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (165, 37, 4, 'LISTIAWATI S. TAMA, SE', '0010103002313', 276177000.00, '2025-12-21 07:16:17.726114+00', '2025-12-21 07:16:17.726114+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (166, 38, 7, 'ELYA ROSA YULIANTI, SE', '0010103001985', 53430000.00, '2025-12-21 07:19:00.829433+00', '2025-12-21 07:19:00.829433+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (167, 38, 14, 'VINA ANGRIANA, S.Sos', '0010103000714', 49912998.00, '2025-12-21 07:19:00.830834+00', '2025-12-21 07:19:00.830834+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (168, 39, 10, 'NOFRINCE LAGENTU, SE', '0010103000386', 39940300.00, '2025-12-21 07:24:50.446688+00', '2025-12-21 07:24:50.446688+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (169, 39, 13, 'LELY SUPU, S.Pd', '0040102008472', 42132250.00, '2025-12-21 07:24:50.448495+00', '2025-12-21 07:24:50.448495+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (170, 40, 4, 'LISTIAWATI S. TAMA, SE', '0010103002313', 149953200.00, '2025-12-21 07:26:06.504494+00', '2025-12-21 07:26:06.504494+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (171, 40, 6, 'NIDYA WIDIASTUTI, SM', '0010103002140', 153231000.00, '2025-12-21 07:26:06.507785+00', '2025-12-21 07:26:06.507785+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (180, 41, 4, 'LISTIAWATI S. TAMA, SE', '0010103002313', 20000000.00, '2025-12-21 07:32:58.911631+00', '2025-12-21 07:32:58.911631+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (181, 41, 8, 'NURAFNI SETIAWATI, SP', '0010103002335', 114221450.00, '2025-12-21 07:32:58.913896+00', '2025-12-21 07:32:58.913896+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (182, 41, 7, 'ELYA ROSA YULIANTI, SE', '0010103001985', 365154650.00, '2025-12-21 07:32:58.915413+00', '2025-12-21 07:32:58.915413+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (183, 41, 8, 'NURAFNI SETIAWATI, SP', '0010103002335', 250933200.00, '2025-12-21 07:32:58.916835+00', '2025-12-21 07:32:58.916835+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (184, 42, 11, 'SYAFRINI, SE', '0030103000045', 29869160.00, '2025-12-21 07:33:41.595067+00', '2025-12-21 07:33:41.595067+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (185, 43, 9, 'SRI ASTUTI, S.SI', '0010103000600', 39040000.00, '2025-12-21 07:35:03.060259+00', '2025-12-21 07:35:03.060259+00', 'bank');
INSERT INTO public.pelimpahan_details VALUES (186, 44, 4, 'LISTIAWATI S. TAMA, SE', '0010103002313', 70000000.00, '2025-12-21 07:35:36.519998+00', '2025-12-21 07:35:36.519998+00', 'bank');

-- Sequences
SELECT pg_catalog.setval('public.backup_histories_id_seq', 1, false);
SELECT pg_catalog.setval('public.backup_settings_id_seq', 1, true);
SELECT pg_catalog.setval('public.jenis_pelimpahans_id_seq', 4, true);
SELECT pg_catalog.setval('public.pelimpahan_details_id_seq', 186, true);
SELECT pg_catalog.setval('public.pelimpahans_id_seq', 44, true);
SELECT pg_catalog.setval('public.penarikan_tunais_id_seq', 7, true);
SELECT pg_catalog.setval('public.saldo_bendaharas_id_seq', 1, true);
SELECT pg_catalog.setval('public.settings_id_seq', 3, true);
SELECT pg_catalog.setval('public.top_up_saldos_id_seq', 20, true);
SELECT pg_catalog.setval('public.units_id_seq', 20, true);
SELECT pg_catalog.setval('public.users_id_seq', 3, true);

-- Constraints
ALTER TABLE ONLY public.backup_histories ADD CONSTRAINT backup_histories_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.backup_settings ADD CONSTRAINT backup_settings_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.jenis_pelimpahans ADD CONSTRAINT jenis_pelimpahans_kode_jenis_key UNIQUE (kode_jenis);
ALTER TABLE ONLY public.jenis_pelimpahans ADD CONSTRAINT jenis_pelimpahans_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.pelimpahan_details ADD CONSTRAINT pelimpahan_details_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.pelimpahans ADD CONSTRAINT pelimpahans_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.penarikan_tunais ADD CONSTRAINT penarikan_tunais_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.saldo_bendaharas ADD CONSTRAINT saldo_bendaharas_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.settings ADD CONSTRAINT settings_key_key UNIQUE (key);
ALTER TABLE ONLY public.settings ADD CONSTRAINT settings_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.top_up_saldos ADD CONSTRAINT top_up_saldos_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.units ADD CONSTRAINT units_kode_unit_key UNIQUE (kode_unit);
ALTER TABLE ONLY public.units ADD CONSTRAINT units_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.users ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE ONLY public.users ADD CONSTRAINT users_pkey PRIMARY KEY (id);

CREATE UNIQUE INDEX idx_users_username ON public.users USING btree (username);

-- Foreign Keys
ALTER TABLE ONLY public.backup_histories ADD CONSTRAINT fk_backup_histories_creator FOREIGN KEY (created_by) REFERENCES public.users(id);
ALTER TABLE ONLY public.pelimpahan_details ADD CONSTRAINT fk_pelimpahan_details_unit FOREIGN KEY (unit_id) REFERENCES public.units(id);
ALTER TABLE ONLY public.pelimpahans ADD CONSTRAINT fk_pelimpahans_creator FOREIGN KEY (created_by) REFERENCES public.users(id);
ALTER TABLE ONLY public.pelimpahan_details ADD CONSTRAINT fk_pelimpahans_details FOREIGN KEY (pelimpahan_id) REFERENCES public.pelimpahans(id);
ALTER TABLE ONLY public.pelimpahans ADD CONSTRAINT fk_pelimpahans_jenis_pelimpahan FOREIGN KEY (jenis_pelimpahan_id) REFERENCES public.jenis_pelimpahans(id);
ALTER TABLE ONLY public.penarikan_tunais ADD CONSTRAINT fk_penarikan_tunais_creator FOREIGN KEY (created_by) REFERENCES public.users(id);
ALTER TABLE ONLY public.saldo_bendaharas ADD CONSTRAINT fk_saldo_bendaharas_creator FOREIGN KEY (created_by) REFERENCES public.users(id);
ALTER TABLE ONLY public.top_up_saldos ADD CONSTRAINT fk_top_up_saldos_creator FOREIGN KEY (created_by) REFERENCES public.users(id);
