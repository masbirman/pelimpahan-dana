-- Seed admin user (password: admin123)
INSERT INTO users (name, email, password, role, is_active) VALUES 
('Super Administrator', 'admin@pelimpahan.local', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin', true),
('Bendahara Utama', 'bendahara@pelimpahan.local', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'bendahara', true),
('Operator Input', 'operator@pelimpahan.local', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'operator', true)
ON CONFLICT (email) DO NOTHING;

-- Seed jenis pelimpahan
INSERT INTO jenis_pelimpahan (kode_jenis, nama_jenis) VALUES 
('UP', 'Uang Persediaan'),
('GU', 'Ganti Uang'),
('TU', 'Tambahan Uang'),
('LS', 'Langsung')
ON CONFLICT (kode_jenis) DO NOTHING;

-- Seed sample units
INSERT INTO units (kode_unit, nama_unit, nama_pimpinan, nama_bendahara, nomor_rekening) VALUES 
('001', 'Dinas Pendidikan', 'Kepala Dinas', 'Bendahara Dinas', '1234567890'),
('002', 'Bidang SD', 'Kabid SD', 'Bendahara Bidang SD', '1234567891'),
('003', 'Bidang SMP', 'Kabid SMP', 'Bendahara Bidang SMP', '1234567892'),
('004', 'Bidang SMA', 'Kabid SMA', 'Bendahara Bidang SMA', '1234567893'),
('005', 'Sekretariat', 'Sekretaris', 'Bendahara Sekretariat', '1234567894')
ON CONFLICT (kode_unit) DO NOTHING;
