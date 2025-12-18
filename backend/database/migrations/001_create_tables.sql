-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'operator',
    avatar VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create units table
CREATE TABLE IF NOT EXISTS units (
    id SERIAL PRIMARY KEY,
    kode_unit VARCHAR(50) UNIQUE NOT NULL,
    nama_unit VARCHAR(255) NOT NULL,
    nama_pimpinan VARCHAR(255),
    nama_bendahara VARCHAR(255) NOT NULL,
    nomor_rekening VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create jenis_pelimpahan table
CREATE TABLE IF NOT EXISTS jenis_pelimpahan (
    id SERIAL PRIMARY KEY,
    kode_jenis VARCHAR(50) UNIQUE NOT NULL,
    nama_jenis VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create pelimpahans table
CREATE TABLE IF NOT EXISTS pelimpahans (
    id SERIAL PRIMARY KEY,
    nomor_pelimpahan INT NOT NULL,
    waktu_pelimpahan TIMESTAMP NOT NULL,
    tanggal_pelimpahan DATE NOT NULL,
    uraian_pelimpahan TEXT,
    jenis_pelimpahan_id INT REFERENCES jenis_pelimpahan(id),
    created_by INT REFERENCES users(id),
    total_jumlah DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create pelimpahan_details table
CREATE TABLE IF NOT EXISTS pelimpahan_details (
    id SERIAL PRIMARY KEY,
    pelimpahan_id INT REFERENCES pelimpahans(id) ON DELETE CASCADE,
    unit_id INT REFERENCES units(id),
    nama_penerima VARCHAR(255) NOT NULL,
    nomor_rekening VARCHAR(50) NOT NULL,
    jumlah DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_pelimpahans_jenis ON pelimpahans(jenis_pelimpahan_id);
CREATE INDEX idx_pelimpahans_created_by ON pelimpahans(created_by);
CREATE INDEX idx_pelimpahan_details_pelimpahan ON pelimpahan_details(pelimpahan_id);
CREATE INDEX idx_pelimpahan_details_unit ON pelimpahan_details(unit_id);
