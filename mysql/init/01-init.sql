-- Create database if not exists
CREATE DATABASE IF NOT EXISTS salonmanager CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user if not exists
CREATE USER IF NOT EXISTS 'salonmanager'@'%' IDENTIFIED BY 'salonmanager_password';
GRANT ALL PRIVILEGES ON salonmanager.* TO 'salonmanager'@'%';
FLUSH PRIVILEGES;

-- Set timezone
SET time_zone = '+00:00';
