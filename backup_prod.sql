--
-- PostgreSQL database dump
--

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
-- Data for Name: jenis_pelimpahans; Type: TABLE DATA; Schema: public; Owner: pelimpahan
--

TRUNCATE public.jenis_pelimpahans CASCADE;
INSERT INTO public.jenis_pelimpahans (id, kode_jenis, nama_jenis, created_at, updated_at) VALUES
(1, 'UP', 'Uang Persediaan', '2025-12-18 07:20:40.462038+00', '2025-12-18 07:20:40.462038+00'),
(2, 'GU', 'Ganti Uang', '2025-12-18 07:20:40.464654+00', '2025-12-18 07:20:40.464654+00'),
(3, 'TU', 'Tambahan Uang', '2025-12-18 07:20:40.466179+00', '2025-12-18 07:20:40.466179+00'),
(4, 'LS', 'Langsung', '2025-12-18 07:20:40.467708+00', '2025-12-18 07:20:40.467708+00');
SELECT setval('public.jenis_pelimpahans_id_seq', 4, true);

--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: pelimpahan
--

TRUNCATE public.users CASCADE;
INSERT INTO public.users (id, name, email, password, role, avatar, is_active, created_at, updated_at) VALUES
(1, 'Asriyanto', 'admin@pelimpahan.local', '$2a$10$d7UGOabDOTi.jYEpeDd8LOJq9KP.Vk5rCbbUyy8Ds.RMp/lAqNMUS', 'super_admin', NULL, true, '2025-12-18 07:20:40.456917+00', '2025-12-19 05:37:53.758728+00'),
(2, 'Astuty Sulistiyanti, ST', 'bendahara@pelimpahan.local', '$2a$10$d7UGOabDOTi.jYEpeDd8LOJq9KP.Vk5rCbbUyy8Ds.RMp/lAqNMUS', 'bendahara', NULL, true, '2025-12-18 07:20:40.459772+00', '2025-12-18 08:54:48.963773+00'),
(3, 'Operator Input', 'operator@pelimpahan.local', '$2a$10$d7UGOabDOTi.jYEpeDd8LOJq9KP.Vk5rCbbUyy8Ds.RMp/lAqNMUS', 'operator', NULL, true, '2025-12-18 07:20:40.460935+00', '2025-12-18 07:20:40.460935+00');
SELECT setval('public.users_id_seq', 3, true);

--
-- Data for Name: units; Type: TABLE DATA; Schema: public; Owner: pelimpahan
--

TRUNCATE public.units CASCADE;
INSERT INTO public.units (id, kode_unit, nama_unit, nama_pimpinan, nama_bendahara, nomor_rekening, created_at, updated_at) VALUES
(4, '001', 'Sekretariat', 'Dr. ASRUL ACHMAD, S.Pd.,M.Si', 'LISTIAWATI S. TAMA, SE', '0010103002313', '2025-12-18 07:45:56.61689+00', '2025-12-18 07:45:56.61689+00'),
(5, '002', 'Bidang Pembinaan SMK', 'ZULFIKAR IS PAUDI, S.Pd.,M.Si', 'NURMALA SARI SOULISA, ST.,M.A.P', '0010103002501', '2025-12-18 07:45:56.627056+00', '2025-12-18 07:45:56.627056+00'),
(6, '003', 'Bidang PKPLK & IP', 'NURSEHA, S.Sos.,M.Si', 'NIDYA WIDIASTUTI, SM', '0010103002140', '2025-12-18 07:45:56.629986+00', '2025-12-18 07:45:56.629986+00'),
(7, '004', 'Bidang PTK & Fasilitasi Tugas Pembantuan', 'MUNASHIR, SE.,MM', 'ELYA ROSA YULIANTI, SE', '0010103001985', '2025-12-18 07:45:56.633172+00', '2025-12-18 07:45:56.633172+00'),
(8, '005', 'Bidang Pembinaan SMA', 'M. YUNUS, SE', 'NURAFNI SETIAWATI, SP', '0010103002335', '2025-12-18 07:45:56.637266+00', '2025-12-18 07:45:56.637266+00'),
(9, '006', 'Cabang Dinas Wilayah 1', 'KRISTI ARIA PRATAMA, SH.,M.Si', 'SRI ASTUTI, S.SI', '0010103000600', '2025-12-18 07:45:56.639723+00', '2025-12-18 07:45:56.639723+00'),
(10, '007', 'Cabang Dinas Wilayah 2', 'SARIFAH, S.Pd.,M.Pd', 'NOFRINCE LAGENTU, SE', '0010103000386', '2025-12-18 07:45:56.64311+00', '2025-12-18 07:45:56.64311+00'),
(11, '008', 'Cabang Dinas Wilayah 3', 'ALWI ACHMAD MUSA, S.Sos', 'SYAFRINI, SE', '0030103000045', '2025-12-18 07:45:56.645992+00', '2025-12-18 07:45:56.645992+00'),
(12, '009', 'Cabang Dinas Wilayah 4', 'SOFIAN, SE.,MM', 'SARI MUTIA B. SAPPE, S.Si', '0010103000320', '2025-12-18 07:45:56.648448+00', '2025-12-18 07:45:56.648448+00'),
(13, '010', 'Cabang Dinas Wilayah 5', 'YASSER MASULILI, S.Ag.,M.A.P', 'LELY SUPU, S.Pd', '0040102008472', '2025-12-18 07:45:56.650238+00', '2025-12-18 07:45:56.650238+00'),
(14, '011', 'Cabang Dinas Wilayah 6', 'FITRIYAH IHWANI, S.Sos.,MM', 'VINA ANGRIANA, S.Sos', '0010103000714', '2025-12-18 07:45:56.651941+00', '2025-12-18 07:45:56.651941+00'),
(15, '012', 'DAK SMK', NULL, 'ASTUTY SULISTIYANTY, ST', '0010103240216', '2025-12-18 11:01:44.513308+00', '2025-12-18 11:02:39.721616+00'),
(18, '013', 'DAK SMA', NULL, 'ASTUTY SULISTIYANTY, ST', '0010103240216', '2025-12-18 12:43:05.224711+00', '2025-12-19 06:05:19.470667+00'),
(19, '014', 'UPTD. BLPT', 'YUDIAWATI', 'ASTUTY SULISTIYANTY, ST', '0010103240216', '2025-12-18 12:43:31.917733+00', '2025-12-18 12:43:31.917733+00');
SELECT setval('public.units_id_seq', 19, true);

--
-- Data for Name: saldo_bendaharas; Type: TABLE DATA; Schema: public; Owner: pelimpahan
--

TRUNCATE public.saldo_bendaharas CASCADE;
INSERT INTO public.saldo_bendaharas (id, tanggal, saldo_bank, saldo_tunai, keterangan, created_by, created_at, updated_at) VALUES
(1, '2025-02-05', 3000000000.00, 0.00, 'Saldo Awal Uang Persediaan (UP)', 1, '2025-12-18 10:01:46.464592+00', '2025-12-18 10:01:46.464592+00');
SELECT setval('public.saldo_bendaharas_id_seq', 1, true);

--
-- Data for Name: top_up_saldos; Type: TABLE DATA; Schema: public; Owner: pelimpahan
--

TRUNCATE public.top_up_saldos CASCADE;
SELECT setval('public.top_up_saldos_id_seq', 1, false);

--
-- Data for Name: penarikan_tunais; Type: TABLE DATA; Schema: public; Owner: pelimpahan
--

TRUNCATE public.penarikan_tunais CASCADE;
INSERT INTO public.penarikan_tunais (id, tanggal, jumlah, keterangan, created_by, created_at, updated_at) VALUES
(2, '2025-03-04', 31493000.00, 'UPTD BLPT', 1, '2025-12-19 11:48:22.561038+00', '2025-12-19 11:48:22.561038+00'),
(3, '2025-03-06', 5100000.00, 'DAK SMK', 1, '2025-12-19 11:48:48.598679+00', '2025-12-19 11:48:48.598679+00');
SELECT setval('public.penarikan_tunais_id_seq', 3, true);

--
-- Data for Name: pelimpahans; Type: TABLE DATA; Schema: public; Owner: pelimpahan
--

TRUNCATE public.pelimpahans CASCADE;
INSERT INTO public.pelimpahans (id, nomor_pelimpahan, waktu_pelimpahan, tanggal_pelimpahan, uraian_pelimpahan, jenis_pelimpahan_id, created_by, total_jumlah, created_at, updated_at, sumber_dana) VALUES
(10, 1, '2025-12-19 11:03:49.648689+00', '2025-02-19', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 385247000.00, '2025-12-19 11:03:49.649232+00', '2025-12-19 11:03:49.649232+00', 'bank'),
(11, 2, '2025-12-19 11:45:50.086109+00', '2025-03-05', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 96516000.00, '2025-12-19 11:45:50.086428+00', '2025-12-19 11:45:50.086428+00', 'bank'),
(12, 3, '2025-12-19 11:50:18.424158+00', '2025-03-04', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 31493000.00, '2025-12-19 11:50:18.42446+00', '2025-12-19 11:50:53.997105+00', 'bank'),
(13, 4, '2025-12-19 11:50:36.217041+00', '2025-03-06', 'Pelimpahan Uang Persediaan (UP)', 1, 1, 5100000.00, '2025-12-19 11:50:36.217352+00', '2025-12-19 12:14:39.197362+00', 'bank');
SELECT setval('public.pelimpahans_id_seq', 13, true);

--
-- Data for Name: pelimpahan_details; Type: TABLE DATA; Schema: public; Owner: pelimpahan
--

TRUNCATE public.pelimpahan_details CASCADE;
INSERT INTO public.pelimpahan_details (id, pelimpahan_id, unit_id, nama_penerima, nomor_rekening, jumlah, created_at, updated_at, sumber_dana) VALUES
(73, 10, 4, 'LISTIAWATI S. TAMA, SE', '0010103002313', 259025000.00, '2025-12-19 11:03:49.652782+00', '2025-12-19 11:03:49.652782+00', 'bank'),
(74, 10, 8, 'NURAFNI SETIAWATI, SP', '0010103002335', 4470000.00, '2025-12-19 11:03:49.655766+00', '2025-12-19 11:03:49.655766+00', 'bank'),
(75, 10, 5, 'NURMALA SARI SOULISA, ST.,M.A.P', '0010103002501', 12780000.00, '2025-12-19 11:03:49.65728+00', '2025-12-19 11:03:49.65728+00', 'bank'),
(76, 10, 7, 'ELYA ROSA YULIANTI, SE', '0010103001985', 7680000.00, '2025-12-19 11:03:49.658502+00', '2025-12-19 11:03:49.658502+00', 'bank'),
(77, 10, 9, 'SRI ASTUTI, S.SI', '0010103000600', 20652000.00, '2025-12-19 11:03:49.659668+00', '2025-12-19 11:03:49.659668+00', 'bank'),
(78, 10, 10, 'NOFRINCE LAGENTU, SE', '0010103000386', 20000000.00, '2025-12-19 11:03:49.660851+00', '2025-12-19 11:03:49.660851+00', 'bank'),
(79, 10, 11, 'SYAFRINI, SE', '0030103000045', 10640000.00, '2025-12-19 11:03:49.662115+00', '2025-12-19 11:03:49.662115+00', 'bank'),
(80, 10, 12, 'SARI MUTIA B. SAPPE, S.Si', '0010103000320', 20000000.00, '2025-12-19 11:03:49.663425+00', '2025-12-19 11:03:49.663425+00', 'bank'),
(81, 10, 13, 'LELY SUPU, S.Pd', '0040102008472', 15500000.00, '2025-12-19 11:03:49.66466+00', '2025-12-19 11:03:49.66466+00', 'bank'),
(82, 10, 14, 'VINA ANGRIANA, S.Sos', '0010103000714', 14500000.00, '2025-12-19 11:03:49.665833+00', '2025-12-19 11:03:49.665833+00', 'bank'),
(83, 11, 4, 'LISTIAWATI S. TAMA, SE', '0010103002313', 96516000.00, '2025-12-19 11:45:50.090606+00', '2025-12-19 11:45:50.090606+00', 'bank'),
(86, 12, 19, 'ASTUTY SULISTIYANTY, ST', '0010103240216', 31493000.00, '2025-12-19 11:50:54.001051+00', '2025-12-19 11:50:54.001051+00', 'bank'),
(90, 13, 15, 'ASTUTY SULISTIYANTY, ST', '0010103240216', 5100000.00, '2025-12-19 12:14:39.203359+00', '2025-12-19 12:14:39.203359+00', 'bank');
SELECT setval('public.pelimpahan_details_id_seq', 90, true);

--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: pelimpahan
--

TRUNCATE public.settings CASCADE;
INSERT INTO public.settings (id, key, value, created_at, updated_at) VALUES
(1, 'countdown', '{"active":true,"description":"Penatausahaan Keuangan akan berakhir tanggal 31 Desember 2025","target_date":"2025-12-31T00:00","title":"Jadwal Penatausahaan Tahun 2025"}', '2025-12-18 08:46:06.739945+00', '2025-12-18 14:57:26.031844+00'),
(2, 'branding', '{"app_name":"Sistem Pelimpahan","app_subtitle":"Dana UP/GU","logo_url":"https://pelimpahan.keudisdiksulteng.web.id/uploads/logo_20251218225558.png"}', '2025-12-18 09:10:40.094805+00', '2025-12-18 14:56:02.124362+00'),
(3, 'report_header', '{"header":{"alamat":"Jalan Setia Budi No. 9 Palu Telp. (0451) 421290, 421090, 421190 Faxmile 428490","dinas":"DINAS PENDIDIKAN","instansi":"PEMERINTAH PROVINSI SULAWESI TENGAH","logo_url":"/uploads/report_logo_20251219193752.png"},"signatory_left":{"jabatan":"Bendahara Pengeluaran,","nama":"ASTUTY SULISTIYANTY, ST","nip":"NIP. 19800924 201001 2 004"},"signatory_right":{"jabatan":"Pengguna Anggaran,","nama":"YUDIAWATI V. WINDARRUSLIANA, SKM., M.Kes","nip":"NIP. 19670712 199003 2 013"}}', '2025-12-19 11:38:50.432805+00', '2025-12-19 11:38:50.432805+00');
SELECT setval('public.settings_id_seq', 3, true);
