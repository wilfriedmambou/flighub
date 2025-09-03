-- =====================================================
-- FLIGHTHUB - AJOUT DES AÉROPORTS CANADIENS
-- =====================================================
-- Script pour ajouter les aéroports canadiens manquants
-- =====================================================

-- Vérifier les aéroports canadiens existants
SELECT 'Aéroports canadiens existants:' as info;
SELECT id, iata_code, name, city FROM airports 
WHERE iata_code IN ('YUL', 'YVR', 'YYZ', 'YYC', 'YEG', 'YOW', 'YHZ', 'YWG')
ORDER BY iata_code;

-- Ajouter les aéroports canadiens manquants
INSERT INTO airports (iata_code, name, city, country, created_at, updated_at) VALUES
('YVR', 'Vancouver International Airport', 'Vancouver', 'Canada', NOW(), NOW()),
('YYZ', 'Toronto Pearson International Airport', 'Toronto', 'Canada', NOW(), NOW()),
('YYC', 'Calgary International Airport', 'Calgary', 'Canada', NOW(), NOW()),
('YEG', 'Edmonton International Airport', 'Edmonton', 'Canada', NOW(), NOW()),
('YOW', 'Ottawa Macdonald-Cartier International Airport', 'Ottawa', 'Canada', NOW(), NOW()),
('YHZ', 'Halifax Stanfield International Airport', 'Halifax', 'Canada', NOW(), NOW()),
('YWG', 'Winnipeg James Armstrong Richardson International Airport', 'Winnipeg', 'Canada', NOW(), NOW())
ON CONFLICT (iata_code) DO NOTHING;

-- Vérifier les aéroports canadiens après ajout
SELECT 'Aéroports canadiens après ajout:' as info;
SELECT id, iata_code, name, city FROM airports 
WHERE iata_code IN ('YUL', 'YVR', 'YYZ', 'YYC', 'YEG', 'YOW', 'YHZ', 'YWG')
ORDER BY iata_code;
