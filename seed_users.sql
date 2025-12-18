-- Reset and seed users with proper bcrypt hash for 'password'
DELETE FROM users;

-- Hash for 'password' is: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
INSERT INTO users (name, email, password, role, is_active) VALUES 
('Super Administrator', 'admin@pelimpahan.local', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'super_admin', true),
('Bendahara Utama', 'bendahara@pelimpahan.local', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'bendahara', true),
('Operator Input', 'operator@pelimpahan.local', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'operator', true);

SELECT id, email, LEFT(password, 30) as password_preview FROM users;
