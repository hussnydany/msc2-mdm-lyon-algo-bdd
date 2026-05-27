-- ============================================
-- Base e-commerce pour demo RFM
-- Seance 4 - Algo & BDD
-- ============================================

CREATE DATABASE IF NOT EXISTS ecommerce_rfm;
USE ecommerce_rfm;

-- ============================================
-- TABLES
-- ============================================

CREATE TABLE clients (
    client_id INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    ville VARCHAR(50),
    date_inscription DATE
);

CREATE TABLE achats (
    achat_id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    montant DECIMAL(10,2) NOT NULL,
    date_achat DATE NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- ============================================
-- DONNEES : 20 clients, profils varies
-- ============================================

INSERT INTO clients (nom, email, ville, date_inscription) VALUES
('Camille Renard', 'camille@mail.com', 'Lyon', '2024-06-15'),
('Hugo Martinez', 'hugo@mail.com', 'Paris', '2024-08-20'),
('Lea Fontaine', 'lea@mail.com', 'Marseille', '2024-09-01'),
('Nathan Petit', 'nathan@mail.com', 'Lyon', '2024-10-10'),
('Manon Leroy', 'manon@mail.com', 'Bordeaux', '2024-11-05'),
('Lucas Girard', 'lucas@mail.com', 'Paris', '2025-01-12'),
('Chloe Bonnet', 'chloe@mail.com', 'Toulouse', '2025-02-18'),
('Enzo Marchand', 'enzo@mail.com', 'Nantes', '2025-03-01'),
('Sarah Cohen', 'sarah@mail.com', 'Lyon', '2025-03-22'),
('Theo Lambert', 'theo@mail.com', 'Paris', '2025-04-05'),
('Ines Dubois', 'ines@mail.com', 'Lille', '2025-05-10'),
('Adam Moreau', 'adam@mail.com', 'Strasbourg', '2025-06-01'),
('Jade Rousseau', 'jade@mail.com', 'Lyon', '2025-06-20'),
('Louis Bernard', 'louis@mail.com', 'Paris', '2025-07-15'),
('Emma Dupont', 'emma@mail.com', 'Marseille', '2025-08-01'),
('Raphael Simon', 'raphael@mail.com', 'Bordeaux', '2025-09-10'),
('Lina Faure', 'lina@mail.com', 'Lyon', '2025-10-01'),
('Gabriel Blanc', 'gabriel@mail.com', 'Nantes', '2025-11-15'),
('Clara Martin', 'clara@mail.com', 'Paris', '2025-12-01'),
('Jules Robert', 'jules@mail.com', 'Toulouse', '2026-01-10');

-- ============================================
-- ACHATS : ~100 achats, profils contrastes
-- ============================================

-- Camille : VIP, achete souvent, gros montants, tres recente
INSERT INTO achats (client_id, montant, date_achat) VALUES
(1, 89.90, '2025-10-15'), (1, 145.00, '2025-11-02'), (1, 67.50, '2025-12-18'),
(1, 210.00, '2026-01-05'), (1, 55.00, '2026-01-28'), (1, 178.00, '2026-02-14'),
(1, 92.00, '2026-03-01'), (1, 135.50, '2026-03-20');

-- Hugo : Fidele, achats reguliers, montants moyens
INSERT INTO achats (client_id, montant, date_achat) VALUES
(2, 45.00, '2025-09-10'), (2, 32.00, '2025-10-22'), (2, 58.90, '2025-11-15'),
(2, 41.00, '2025-12-30'), (2, 27.50, '2026-02-08'), (2, 63.00, '2026-03-15');

-- Lea : Bonne cliente mais commence a decrocher
INSERT INTO achats (client_id, montant, date_achat) VALUES
(3, 120.00, '2025-06-20'), (3, 85.00, '2025-08-14'), (3, 95.50, '2025-10-01'),
(3, 42.00, '2025-12-05'), (3, 31.00, '2026-01-18');

-- Nathan : Endormi, plus d'achat depuis longtemps
INSERT INTO achats (client_id, montant, date_achat) VALUES
(4, 25.00, '2025-03-10'), (4, 18.50, '2025-04-22'), (4, 33.00, '2025-06-01');

-- Manon : Grosse depensiere mais rare
INSERT INTO achats (client_id, montant, date_achat) VALUES
(5, 350.00, '2025-11-20'), (5, 420.00, '2026-02-25');

-- Lucas : Petit acheteur regulier
INSERT INTO achats (client_id, montant, date_achat) VALUES
(6, 15.00, '2025-08-05'), (6, 12.00, '2025-09-18'), (6, 19.90, '2025-10-30'),
(6, 8.50, '2025-12-12'), (6, 14.00, '2026-01-25'), (6, 11.00, '2026-02-20'),
(6, 16.50, '2026-03-18');

-- Chloe : Moyenne en tout
INSERT INTO achats (client_id, montant, date_achat) VALUES
(7, 55.00, '2025-09-05'), (7, 48.00, '2025-11-11'), (7, 62.00, '2026-01-20'),
(7, 39.90, '2026-03-10');

-- Enzo : Nouveau client, un seul achat
INSERT INTO achats (client_id, montant, date_achat) VALUES
(8, 29.90, '2026-03-15');

-- Sarah : Cliente recente, monte en puissance
INSERT INTO achats (client_id, montant, date_achat) VALUES
(9, 22.00, '2025-12-01'), (9, 45.00, '2026-01-14'), (9, 78.00, '2026-02-10'),
(9, 110.00, '2026-03-05'), (9, 95.00, '2026-03-22');

-- Theo : A achete une fois et plus rien
INSERT INTO achats (client_id, montant, date_achat) VALUES
(10, 67.00, '2025-07-20');

-- Ines : Cliente correcte, reguliere
INSERT INTO achats (client_id, montant, date_achat) VALUES
(11, 38.00, '2025-10-05'), (11, 52.00, '2025-12-18'), (11, 44.50, '2026-02-01'),
(11, 61.00, '2026-03-12');

-- Adam : Deux gros achats espaces
INSERT INTO achats (client_id, montant, date_achat) VALUES
(12, 195.00, '2025-09-15'), (12, 230.00, '2026-01-08');

-- Jade : Acheteuse impulsive, petits montants frequents
INSERT INTO achats (client_id, montant, date_achat) VALUES
(13, 12.00, '2025-11-01'), (13, 8.50, '2025-11-15'), (13, 15.00, '2025-12-02'),
(13, 9.90, '2025-12-20'), (13, 11.00, '2026-01-05'), (13, 7.50, '2026-01-22'),
(13, 13.00, '2026-02-08'), (13, 10.00, '2026-02-25'), (13, 14.50, '2026-03-10'),
(13, 8.00, '2026-03-25');

-- Louis : Gros panier mais s'est arrete
INSERT INTO achats (client_id, montant, date_achat) VALUES
(14, 280.00, '2025-08-10'), (14, 195.00, '2025-09-25'), (14, 310.00, '2025-11-02');

-- Emma : Petite acheteuse recente
INSERT INTO achats (client_id, montant, date_achat) VALUES
(15, 19.00, '2026-02-15'), (15, 24.50, '2026-03-08');

-- Raphael : Un achat moyen recent
INSERT INTO achats (client_id, montant, date_achat) VALUES
(16, 75.00, '2026-03-01');

-- Lina : Bonne cliente, montants varies
INSERT INTO achats (client_id, montant, date_achat) VALUES
(17, 88.00, '2025-12-10'), (17, 42.00, '2026-01-18'), (17, 155.00, '2026-02-22'),
(17, 63.00, '2026-03-18');

-- Gabriel : Endormi depuis longtemps
INSERT INTO achats (client_id, montant, date_achat) VALUES
(18, 55.00, '2025-05-12'), (18, 38.00, '2025-06-25');

-- Clara : Tres recente, un seul achat
INSERT INTO achats (client_id, montant, date_achat) VALUES
(19, 47.00, '2026-03-28');

-- Jules : Inscrit recemment, deux petits achats
INSERT INTO achats (client_id, montant, date_achat) VALUES
(20, 15.00, '2026-02-20'), (20, 22.00, '2026-03-15');
