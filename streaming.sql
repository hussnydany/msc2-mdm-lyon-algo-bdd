-- ============================================
-- Base de données : Streaming Musical Marketing
-- Projet Final - Algo & BDD 2026
-- ============================================

CREATE DATABASE IF NOT EXISTS streaming_marketing;
USE streaming_marketing;

-- ============================================
-- TABLES
-- ============================================

-- Table clients
CREATE TABLE clients (
    client_id    INT PRIMARY KEY AUTO_INCREMENT,
    nom          VARCHAR(100) NOT NULL,
    email        VARCHAR(150) UNIQUE NOT NULL,
    ville        VARCHAR(50),
    age          INT,
    date_inscription DATE NOT NULL
);

-- Table abonnements (type d'offre)
CREATE TABLE abonnements (
    abonnement_id   INT PRIMARY KEY AUTO_INCREMENT,
    nom_offre       VARCHAR(50) NOT NULL,
    prix_mensuel    DECIMAL(6,2) NOT NULL,
    qualite_audio   VARCHAR(20),   -- standard, high, lossless
    nb_appareils    INT NOT NULL DEFAULT 1
);

-- Table souscriptions (client <-> abonnement) : many-to-many + historique
CREATE TABLE souscriptions (
    souscription_id  INT PRIMARY KEY AUTO_INCREMENT,
    client_id        INT NOT NULL,
    abonnement_id    INT NOT NULL,
    date_debut       DATE NOT NULL,
    date_fin         DATE,
    actif            BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (client_id)    REFERENCES clients(client_id),
    FOREIGN KEY (abonnement_id) REFERENCES abonnements(abonnement_id)
);

-- Table artistes
CREATE TABLE artistes (
    artiste_id  INT PRIMARY KEY AUTO_INCREMENT,
    nom         VARCHAR(100) NOT NULL,
    genre       VARCHAR(50),
    pays        VARCHAR(50)
);

-- Table titres
CREATE TABLE titres (
    titre_id    INT PRIMARY KEY AUTO_INCREMENT,
    artiste_id  INT NOT NULL,
    nom_titre   VARCHAR(200) NOT NULL,
    duree_sec   INT NOT NULL,   -- durée en secondes
    annee       INT,
    FOREIGN KEY (artiste_id) REFERENCES artistes(artiste_id)
);

-- Table ecoutes (activité principale)
CREATE TABLE ecoutes (
    ecoute_id   INT PRIMARY KEY AUTO_INCREMENT,
    client_id   INT NOT NULL,
    titre_id    INT NOT NULL,
    date_ecoute DATETIME NOT NULL,
    complete    BOOLEAN NOT NULL DEFAULT TRUE,  -- écoute complète ou abandonnée
    FOREIGN KEY (client_id) REFERENCES clients(client_id),
    FOREIGN KEY (titre_id)  REFERENCES titres(titre_id)
);

-- Table campagnes marketing
CREATE TABLE campagnes (
    campagne_id  INT PRIMARY KEY AUTO_INCREMENT,
    nom          VARCHAR(100) NOT NULL,
    type_canal   VARCHAR(50),   -- email, push, sms
    date_envoi   DATE NOT NULL,
    segment_cible VARCHAR(50)   -- Champions, Fideles, A_risque, etc.
);

-- Table campagnes_clients : many-to-many entre campagnes et clients
CREATE TABLE campagnes_clients (
    id           INT PRIMARY KEY AUTO_INCREMENT,
    campagne_id  INT NOT NULL,
    client_id    INT NOT NULL,
    ouvert       BOOLEAN DEFAULT FALSE,
    converti     BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (campagne_id) REFERENCES campagnes(campagne_id),
    FOREIGN KEY (client_id)   REFERENCES clients(client_id)
);

-- Table segments RFM (résultats du pipeline Python)
CREATE TABLE rfm_segments (
    rfm_id       INT PRIMARY KEY AUTO_INCREMENT,
    client_id    INT NOT NULL UNIQUE,
    recence_j    INT,           -- jours depuis dernière écoute
    frequence    INT,           -- nb d'écoutes totales
    engagement   DECIMAL(5,2), -- % d'écoutes complètes
    score_r      INT,
    score_f      INT,
    score_e      INT,
    score_total  INT,
    segment      VARCHAR(50),
    date_calcul  DATE NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- ============================================
-- DONNÉES : Abonnements
-- ============================================

INSERT INTO abonnements (nom_offre, prix_mensuel, qualite_audio, nb_appareils) VALUES
('Gratuit',    0.00, 'standard', 1),
('Solo',       9.99, 'high',     1),
('Duo',       13.99, 'high',     2),
('Famille',   17.99, 'lossless', 6),
('Etudiant',   4.99, 'high',     1);

-- ============================================
-- DONNÉES : Clients (35 clients)
-- ============================================

INSERT INTO clients (nom, email, ville, age, date_inscription) VALUES
('Camille Renard',   'camille@mail.com',   'Lyon',        26, '2023-03-10'),
('Hugo Martinez',    'hugo@mail.com',      'Paris',       31, '2023-05-22'),
('Lea Fontaine',     'lea@mail.com',       'Marseille',   24, '2023-07-01'),
('Nathan Petit',     'nathan@mail.com',    'Lyon',        28, '2023-08-15'),
('Manon Leroy',      'manon@mail.com',     'Bordeaux',    22, '2023-09-05'),
('Lucas Girard',     'lucas@mail.com',     'Paris',       35, '2023-10-12'),
('Chloe Bonnet',     'chloe@mail.com',     'Toulouse',    29, '2024-01-18'),
('Enzo Marchand',    'enzo@mail.com',      'Nantes',      21, '2024-02-01'),
('Sarah Cohen',      'sarah@mail.com',     'Lyon',        27, '2024-02-22'),
('Theo Lambert',     'theo@mail.com',      'Paris',       33, '2024-03-05'),
('Ines Dubois',      'ines@mail.com',      'Lille',       25, '2024-04-10'),
('Adam Moreau',      'adam@mail.com',      'Strasbourg',  30, '2024-05-01'),
('Jade Rousseau',    'jade@mail.com',      'Lyon',        23, '2024-06-20'),
('Louis Bernard',    'louis@mail.com',     'Paris',       38, '2024-07-15'),
('Emma Dupont',      'emma@mail.com',      'Marseille',   20, '2024-08-01'),
('Raphael Simon',    'raphael@mail.com',   'Bordeaux',    32, '2024-09-10'),
('Lina Faure',       'lina@mail.com',      'Lyon',        26, '2024-10-01'),
('Gabriel Blanc',    'gabriel@mail.com',   'Nantes',      29, '2024-11-15'),
('Clara Martin',     'clara@mail.com',     'Paris',       22, '2024-12-01'),
('Jules Robert',     'jules@mail.com',     'Toulouse',    27, '2025-01-10'),
('Alice Morel',      'alice@mail.com',     'Paris',       24, '2025-02-01'),
('Baptiste Vidal',   'baptiste@mail.com',  'Lyon',        31, '2025-02-20'),
('Sophie Clement',   'sophie@mail.com',    'Bordeaux',    28, '2025-03-05'),
('Kevin Andre',      'kevin@mail.com',     'Nantes',      25, '2025-03-22'),
('Pauline Roux',     'pauline@mail.com',   'Paris',       23, '2025-04-10'),
('Mathieu Perez',    'mathieu@mail.com',   'Lyon',        36, '2025-05-01'),
('Julie Legrand',    'julie@mail.com',     'Marseille',   22, '2025-05-18'),
('Thomas Garnier',   'thomas@mail.com',    'Paris',       29, '2025-06-01'),
('Marine Chevalier', 'marine@mail.com',    'Lille',       27, '2025-07-10'),
('Nicolas Perrin',   'nicolas@mail.com',   'Toulouse',    34, '2025-08-01'),
('Amelie Leclercq',  'amelie@mail.com',    'Strasbourg',  26, '2025-09-15'),
('Florian Gautier',  'florian@mail.com',   'Paris',       30, '2025-10-01'),
('Laure Bertrand',   'laure@mail.com',     'Lyon',        21, '2025-11-20'),
('Pierre Bonnet',    'pierre@mail.com',    'Bordeaux',    33, '2026-01-05'),
('Yasmine Halim',    'yasmine@mail.com',   'Paris',       25, '2026-02-14');

-- ============================================
-- DONNÉES : Souscriptions
-- ============================================

INSERT INTO souscriptions (client_id, abonnement_id, date_debut, date_fin, actif) VALUES
-- Famille
(1,  4, '2023-03-10', NULL,         TRUE),
(9,  4, '2024-02-22', NULL,         TRUE),
(13, 4, '2024-06-20', NULL,         TRUE),
-- Solo
(2,  2, '2023-05-22', NULL,         TRUE),
(6,  2, '2023-10-12', NULL,         TRUE),
(11, 2, '2024-04-10', NULL,         TRUE),
(17, 2, '2024-10-01', NULL,         TRUE),
(22, 2, '2025-02-20', NULL,         TRUE),
(26, 2, '2025-05-01', NULL,         TRUE),
(29, 2, '2025-07-10', NULL,         TRUE),
-- Duo
(3,  3, '2023-07-01', NULL,         TRUE),
(7,  3, '2024-01-18', NULL,         TRUE),
(14, 3, '2024-07-15', NULL,         TRUE),
(21, 3, '2025-02-01', NULL,         TRUE),
(25, 3, '2025-04-10', NULL,         TRUE),
-- Etudiant
(5,  5, '2023-09-05', NULL,         TRUE),
(8,  5, '2024-02-01', NULL,         TRUE),
(15, 5, '2024-08-01', NULL,         TRUE),
(19, 5, '2024-12-01', NULL,         TRUE),
(23, 5, '2025-03-05', NULL,         TRUE),
(27, 5, '2025-05-18', NULL,         TRUE),
(33, 5, '2025-11-20', NULL,         TRUE),
(35, 5, '2026-02-14', NULL,         TRUE),
-- Gratuit (anciens ou désengagés)
(4,  1, '2023-08-15', NULL,         TRUE),
(10, 1, '2024-03-05', NULL,         TRUE),
(18, 1, '2024-11-15', NULL,         TRUE),
-- Abonnements résiliés (historique)
(2,  1, '2023-04-01', '2023-05-22', FALSE),
(16, 2, '2024-09-10', '2025-03-01', FALSE),
(30, 2, '2025-08-01', '2025-12-01', FALSE),
(12, 2, '2024-05-01', '2025-01-01', FALSE),
(12, 4, '2025-01-01', NULL,         TRUE),
(20, 5, '2025-01-10', NULL,         TRUE),
(24, 2, '2025-03-22', NULL,         TRUE),
(28, 2, '2025-06-01', NULL,         TRUE),
(31, 2, '2025-09-15', NULL,         TRUE),
(32, 2, '2025-10-01', NULL,         TRUE),
(34, 2, '2026-01-05', NULL,         TRUE),
(16, 3, '2025-03-01', NULL,         TRUE);

-- ============================================
-- DONNÉES : Artistes
-- ============================================

INSERT INTO artistes (nom, genre, pays) VALUES
('Daft Punk',       'Electronic', 'France'),
('Angele',          'Pop',        'Belgique'),
('Stromae',         'Pop',        'Belgique'),
('PNL',             'Rap',        'France'),
('Aya Nakamura',    'R&B',        'France'),
('Orelsan',         'Rap',        'France'),
('Clara Luciani',   'Pop',        'France'),
('Nekfeu',          'Rap',        'France'),
('Christine and the Queens', 'Pop', 'France'),
('Tayc',            'R&B',        'France'),
('Kendrick Lamar',  'Rap',        'USA'),
('The Weeknd',      'R&B',        'Canada'),
('Billie Eilish',   'Pop',        'USA'),
('Bad Bunny',       'Reggaeton',  'Porto Rico'),
('Doja Cat',        'Pop',        'USA');

-- ============================================
-- DONNÉES : Titres
-- ============================================

INSERT INTO titres (artiste_id, nom_titre, duree_sec, annee) VALUES
(1, 'Get Lucky',              248, 2013),
(1, 'One More Time',          321, 2001),
(2, 'Balance ton quoi',       178, 2018),
(2, 'Tout oublier',           195, 2018),
(3, 'Alors on danse',         214, 2010),
(3, 'Papaoutai',              245, 2013),
(4, 'Au DD',                  263, 2019),
(4, 'Que la famille',         285, 2019),
(5, 'Djadja',                 197, 2018),
(5, 'Copines',                184, 2019),
(6, 'La fete est finie',      252, 2017),
(6, 'San-Antonio',            198, 2021),
(7, 'Sauvages',               210, 2021),
(7, 'Coeur',                  225, 2019),
(8, 'Avant qu on parte',      243, 2015),
(8, 'Nique le systeme',       218, 2016),
(9, 'Saint Claude',           222, 2014),
(9, 'iT',                     196, 2018),
(10,'Fleur froide',           231, 2019),
(10,'Reve de elle',           208, 2021),
(11,'HUMBLE.',                177, 2017),
(11,'Alright',                215, 2015),
(12,'Blinding Lights',        200, 2019),
(12,'Save Your Tears',        215, 2020),
(13,'bad guy',                194, 2019),
(13,'Happier Than Ever',      298, 2021),
(14,'Dakiti',                 191, 2020),
(14,'Tití Me Preguntó',       298, 2022),
(15,'Say So',                 238, 2019),
(15,'Need to Know',           220, 2021);

-- ============================================
-- DONNÉES : Écoutes (~200 lignes, profils variés)
-- ============================================

-- Client 1 (Camille) - Champion, très actif
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(1,1,'2026-03-28 08:12:00',TRUE),(1,3,'2026-03-28 08:16:00',TRUE),
(1,23,'2026-03-27 20:30:00',TRUE),(1,7,'2026-03-26 09:00:00',TRUE),
(1,13,'2026-03-25 18:45:00',TRUE),(1,5,'2026-03-24 07:55:00',TRUE),
(1,25,'2026-03-23 22:10:00',TRUE),(1,2,'2026-03-22 17:00:00',TRUE),
(1,9,'2026-03-21 08:30:00',TRUE),(1,15,'2026-03-20 19:15:00',TRUE),
(1,17,'2026-03-19 11:00:00',TRUE),(1,11,'2026-03-18 08:45:00',TRUE);

-- Client 2 (Hugo) - Fidèle, régulier
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(2,5,'2026-03-25 12:00:00',TRUE),(2,10,'2026-03-20 09:30:00',TRUE),
(2,22,'2026-03-15 18:00:00',TRUE),(2,4,'2026-03-10 07:45:00',TRUE),
(2,8,'2026-03-05 20:00:00',TRUE),(2,19,'2026-02-28 11:30:00',TRUE),
(2,29,'2026-02-20 09:15:00',TRUE),(2,1,'2026-02-15 17:45:00',TRUE);

-- Client 3 (Lea) - Active mais en baisse
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(3,6,'2026-02-15 10:00:00',TRUE),(3,12,'2026-02-01 19:30:00',TRUE),
(3,24,'2026-01-20 08:00:00',TRUE),(3,3,'2026-01-05 17:00:00',TRUE),
(3,18,'2025-12-20 21:00:00',FALSE),(3,7,'2025-12-01 09:00:00',TRUE);

-- Client 4 (Nathan) - Endormi, gratuit
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(4,2,'2025-10-01 14:00:00',TRUE),(4,20,'2025-09-15 10:00:00',FALSE),
(4,5,'2025-08-20 18:00:00',FALSE);

-- Client 5 (Manon) - Rare mais engagée
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(5,25,'2026-03-20 22:00:00',TRUE),(5,26,'2026-03-20 22:15:00',TRUE),
(5,27,'2026-02-10 20:00:00',TRUE),(5,28,'2026-02-10 20:20:00',TRUE),
(5,29,'2025-12-05 21:00:00',TRUE);

-- Client 6 (Lucas) - Petit consommateur régulier
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(6,1,'2026-03-22 08:00:00',TRUE),(6,3,'2026-03-15 08:00:00',TRUE),
(6,5,'2026-03-08 08:00:00',TRUE),(6,7,'2026-03-01 08:00:00',TRUE),
(6,9,'2026-02-22 08:00:00',TRUE),(6,11,'2026-02-15 08:00:00',TRUE),
(6,13,'2026-02-08 08:00:00',TRUE),(6,15,'2026-02-01 08:00:00',TRUE);

-- Client 7 (Chloe) - Moyenne, régulière
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(7,4,'2026-03-18 19:00:00',TRUE),(7,8,'2026-03-05 20:30:00',TRUE),
(7,14,'2026-02-20 18:45:00',TRUE),(7,16,'2026-02-05 09:15:00',FALSE),
(7,20,'2026-01-25 21:00:00',TRUE),(7,22,'2026-01-10 17:30:00',TRUE);

-- Client 8 (Enzo) - Nouveau, peu d'écoutes
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(8,25,'2026-03-20 15:00:00',TRUE),(8,13,'2026-03-10 16:00:00',TRUE),
(8,29,'2026-02-28 14:00:00',FALSE);

-- Client 9 (Sarah) - Montée en puissance
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(9,23,'2026-03-29 21:00:00',TRUE),(9,25,'2026-03-28 20:30:00',TRUE),
(9,27,'2026-03-27 22:00:00',TRUE),(9,24,'2026-03-26 19:45:00',TRUE),
(9,13,'2026-03-25 21:15:00',TRUE),(9,9,'2026-03-20 20:00:00',TRUE),
(9,5,'2026-03-15 18:30:00',TRUE),(9,3,'2026-03-10 19:00:00',TRUE),
(9,1,'2026-03-05 20:00:00',TRUE),(9,7,'2026-02-28 21:30:00',TRUE);

-- Client 10 (Theo) - A décroché, un seul usage récent
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(10,2,'2025-09-10 10:00:00',FALSE),(10,6,'2025-07-05 11:00:00',FALSE);

-- Client 11 (Ines) - Correcte, régulière
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(11,10,'2026-03-15 20:00:00',TRUE),(11,14,'2026-03-01 19:30:00',TRUE),
(11,18,'2026-02-15 21:00:00',TRUE),(11,20,'2026-02-01 18:45:00',TRUE),
(11,22,'2026-01-18 20:30:00',TRUE),(11,4,'2026-01-05 19:00:00',TRUE);

-- Client 12 (Adam) - Deux gros pics d'activité
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(12,7,'2026-01-15 10:00:00',TRUE),(12,8,'2026-01-15 10:30:00',TRUE),
(12,11,'2026-01-15 11:00:00',TRUE),(12,12,'2026-01-15 11:30:00',TRUE),
(12,19,'2025-09-20 09:00:00',TRUE),(12,20,'2025-09-20 09:30:00',TRUE);

-- Client 13 (Jade) - Très actif, fans pop
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(13,3,'2026-03-30 07:30:00',TRUE),(13,4,'2026-03-29 07:30:00',TRUE),
(13,9,'2026-03-28 07:30:00',TRUE),(13,10,'2026-03-27 07:30:00',TRUE),
(13,13,'2026-03-26 07:30:00',TRUE),(13,14,'2026-03-25 07:30:00',TRUE),
(13,17,'2026-03-24 07:30:00',TRUE),(13,18,'2026-03-23 07:30:00',TRUE),
(13,25,'2026-03-22 07:30:00',TRUE),(13,26,'2026-03-21 07:30:00',TRUE),
(13,29,'2026-03-20 07:30:00',TRUE),(13,30,'2026-03-19 07:30:00',TRUE);

-- Client 14 (Louis) - Très actif puis arrêté
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(14,1,'2025-11-20 09:00:00',TRUE),(14,2,'2025-11-19 09:00:00',TRUE),
(14,5,'2025-11-18 09:00:00',TRUE),(14,6,'2025-11-17 09:00:00',TRUE),
(14,11,'2025-11-10 10:00:00',TRUE),(14,15,'2025-11-05 11:00:00',TRUE);

-- Client 15 (Emma) - Récente, peu d'écoutes
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(15,25,'2026-03-10 22:00:00',TRUE),(15,26,'2026-02-20 21:30:00',TRUE),
(15,13,'2026-02-01 20:00:00',TRUE);

-- Client 16 (Raphael) - Récent, reprise d'activité
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(16,23,'2026-03-05 18:00:00',TRUE),(16,24,'2026-02-15 19:00:00',TRUE),
(16,11,'2026-01-20 20:00:00',TRUE),(16,7,'2025-12-10 09:00:00',FALSE);

-- Client 17 (Lina) - Bonne cliente, montants variés
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(17,5,'2026-03-20 20:00:00',TRUE),(17,6,'2026-03-10 19:30:00',TRUE),
(17,9,'2026-02-28 21:00:00',TRUE),(17,10,'2026-02-15 20:45:00',TRUE),
(17,3,'2026-02-01 19:00:00',TRUE),(17,17,'2026-01-20 22:00:00',TRUE),
(17,19,'2026-01-08 20:30:00',TRUE);

-- Clients 18-35 : données allégées mais suffisantes
INSERT INTO ecoutes (client_id, titre_id, date_ecoute, complete) VALUES
(18,1,'2025-06-10 10:00:00',TRUE),(18,2,'2025-06-10 10:30:00',FALSE),
(19,29,'2026-03-28 21:00:00',TRUE),(19,30,'2026-03-25 20:00:00',TRUE),(19,27,'2026-03-20 19:00:00',TRUE),
(20,11,'2026-03-15 09:00:00',TRUE),(20,12,'2026-03-01 09:30:00',TRUE),(20,15,'2026-02-10 10:00:00',TRUE),(20,16,'2026-01-20 11:00:00',TRUE),
(21,3,'2026-03-22 19:00:00',TRUE),(21,9,'2026-03-10 20:00:00',TRUE),(21,25,'2026-02-25 21:00:00',TRUE),
(22,7,'2026-03-18 08:00:00',TRUE),(22,13,'2026-03-05 08:30:00',TRUE),(22,1,'2026-02-20 09:00:00',TRUE),(22,5,'2026-02-10 08:00:00',TRUE),(22,19,'2026-01-30 08:15:00',TRUE),
(23,25,'2026-03-12 22:00:00',TRUE),(23,26,'2026-02-28 21:30:00',TRUE),(23,13,'2026-02-10 20:00:00',FALSE),
(24,3,'2026-03-20 18:00:00',TRUE),(24,4,'2026-03-10 19:00:00',TRUE),(24,5,'2026-02-28 20:00:00',TRUE),(24,6,'2026-02-15 18:30:00',TRUE),
(25,9,'2026-03-25 20:00:00',TRUE),(25,10,'2026-03-15 19:30:00',TRUE),(25,23,'2026-03-05 21:00:00',TRUE),(25,24,'2026-02-20 20:00:00',TRUE),(25,7,'2026-02-10 19:00:00',TRUE),
(26,11,'2026-03-28 12:00:00',TRUE),(26,15,'2026-03-20 11:30:00',TRUE),(26,17,'2026-03-10 12:00:00',TRUE),
(27,29,'2026-03-15 22:00:00',TRUE),(27,30,'2026-03-05 21:00:00',FALSE),(27,13,'2026-02-20 20:00:00',TRUE),
(28,1,'2026-03-22 09:00:00',TRUE),(28,2,'2026-03-10 09:30:00',TRUE),(28,5,'2026-02-28 08:00:00',TRUE),(28,6,'2026-02-15 09:15:00',TRUE),
(29,23,'2026-03-18 20:00:00',TRUE),(29,25,'2026-03-05 19:30:00',TRUE),(29,7,'2026-02-20 21:00:00',TRUE),
(30,5,'2025-11-15 10:00:00',TRUE),(30,6,'2025-10-20 11:00:00',FALSE),(30,11,'2025-09-10 09:00:00',TRUE),
(31,3,'2026-03-20 19:00:00',TRUE),(31,9,'2026-03-10 20:00:00',TRUE),(31,13,'2026-02-25 21:00:00',TRUE),(31,17,'2026-02-10 18:30:00',TRUE),
(32,25,'2026-03-25 22:00:00',TRUE),(32,26,'2026-03-15 21:30:00',TRUE),(32,27,'2026-03-05 20:00:00',TRUE),(32,13,'2026-02-25 22:00:00',TRUE),
(33,29,'2026-03-28 21:00:00',TRUE),(33,30,'2026-03-20 20:30:00',TRUE),(33,27,'2026-03-10 22:00:00',TRUE),(33,28,'2026-03-01 21:00:00',TRUE),
(34,1,'2026-03-10 09:00:00',TRUE),(34,3,'2026-02-20 08:30:00',TRUE),
(35,25,'2026-03-20 21:00:00',TRUE),(35,26,'2026-03-10 20:30:00',TRUE),(35,13,'2026-02-25 22:00:00',TRUE);

-- ============================================
-- DONNÉES : Campagnes marketing
-- ============================================

INSERT INTO campagnes (nom, type_canal, date_envoi, segment_cible) VALUES
('Reactivation_endormis_jan',   'email', '2026-01-15', 'Endormi'),
('Upsell_gratuit_fev',          'push',  '2026-02-01', 'Gratuit'),
('Fidelisation_vip_mars',       'email', '2026-03-01', 'Champions'),
('Promo_etudiants_printemps',   'sms',   '2026-03-10', 'Etudiant'),
('Retargeting_inactif_mars',    'email', '2026-03-20', 'A_risque');

-- Associations campagnes <-> clients
INSERT INTO campagnes_clients (campagne_id, client_id, ouvert, converti) VALUES
-- Réactivation endormis
(1,4,TRUE,FALSE),(1,10,FALSE,FALSE),(1,14,FALSE,FALSE),(1,18,TRUE,FALSE),(1,30,TRUE,TRUE),
-- Upsell gratuit
(2,4,TRUE,FALSE),(2,10,FALSE,FALSE),(2,18,FALSE,FALSE),
-- Fidélisation VIP
(3,1,TRUE,TRUE),(3,9,TRUE,TRUE),(3,13,TRUE,FALSE),(3,22,TRUE,TRUE),
-- Promo étudiants
(4,5,TRUE,TRUE),(4,8,TRUE,FALSE),(4,15,FALSE,FALSE),(4,19,TRUE,TRUE),(4,23,TRUE,FALSE),(4,27,TRUE,TRUE),(4,33,TRUE,TRUE),
-- Retargeting inactif
(5,3,TRUE,FALSE),(5,7,FALSE,FALSE),(5,12,TRUE,FALSE),(5,14,FALSE,FALSE),(5,16,TRUE,TRUE);

-- ============================================
-- REQUÊTES SELECT (exigences du cahier des charges)
-- ============================================

-- 1. Top 10 clients par nombre d'écoutes, ville filtrée
SELECT c.nom, c.ville, COUNT(e.ecoute_id) AS nb_ecoutes
FROM clients c
JOIN ecoutes e ON c.client_id = e.client_id
WHERE e.complete = TRUE
GROUP BY c.client_id, c.nom, c.ville
HAVING COUNT(e.ecoute_id) >= 3
ORDER BY nb_ecoutes DESC
LIMIT 10;

-- 2. Chiffre d'affaires mensuel par offre d'abonnement
SELECT a.nom_offre, COUNT(s.souscription_id) AS nb_actifs,
       ROUND(COUNT(s.souscription_id) * a.prix_mensuel, 2) AS ca_mensuel_eur
FROM abonnements a
JOIN souscriptions s ON a.abonnement_id = s.abonnement_id
WHERE s.actif = TRUE
GROUP BY a.abonnement_id, a.nom_offre, a.prix_mensuel
ORDER BY ca_mensuel_eur DESC;

-- 3. Artistes les plus écoutés avec genre
SELECT ar.nom AS artiste, ar.genre,
       COUNT(e.ecoute_id) AS nb_ecoutes,
       ROUND(AVG(t.duree_sec)/60, 2) AS duree_moy_min
FROM artistes ar
JOIN titres t   ON ar.artiste_id = t.artiste_id
JOIN ecoutes e  ON t.titre_id    = e.titre_id
GROUP BY ar.artiste_id, ar.nom, ar.genre
ORDER BY nb_ecoutes DESC
LIMIT 10;

-- 4. Clients sans aucune écoute (sous-requête)
SELECT c.client_id, c.nom, c.email, c.date_inscription
FROM clients c
WHERE c.client_id NOT IN (
    SELECT DISTINCT client_id FROM ecoutes
)
ORDER BY c.date_inscription;

-- 5. Taux de conversion par campagne (jointure 3 tables)
SELECT ca.nom AS campagne, ca.type_canal, ca.segment_cible,
       COUNT(cc.id) AS nb_envoyes,
       SUM(cc.ouvert)    AS nb_ouverts,
       SUM(cc.converti)  AS nb_convertis,
       ROUND(SUM(cc.converti) / COUNT(cc.id) * 100, 1) AS taux_conversion_pct
FROM campagnes ca
JOIN campagnes_clients cc ON ca.campagne_id = cc.campagne_id
JOIN clients c            ON cc.client_id   = c.client_id
GROUP BY ca.campagne_id, ca.nom, ca.type_canal, ca.segment_cible
ORDER BY taux_conversion_pct DESC;

-- ============================================
-- CTE : calcul RFM brut
-- ============================================

WITH derniere_ecoute AS (
    SELECT client_id, MAX(date_ecoute) AS last_listen
    FROM ecoutes
    GROUP BY client_id
),
stats_client AS (
    SELECT client_id,
           COUNT(*)  AS frequence,
           ROUND(SUM(complete) / COUNT(*) * 100, 1) AS pct_complete
    FROM ecoutes
    GROUP BY client_id
)
SELECT c.client_id, c.nom,
       DATEDIFF('2026-04-01', d.last_listen) AS recence_jours,
       s.frequence,
       s.pct_complete
FROM clients c
LEFT JOIN derniere_ecoute d ON c.client_id = d.client_id
LEFT JOIN stats_client    s ON c.client_id = s.client_id
ORDER BY recence_jours;

-- ============================================
-- VUE : profil complet client
-- ============================================

CREATE OR REPLACE VIEW vue_profil_client AS
SELECT
    c.client_id,
    c.nom,
    c.ville,
    c.age,
    a.nom_offre                                              AS abonnement,
    COUNT(DISTINCT e.ecoute_id)                              AS nb_ecoutes,
    ROUND(SUM(e.complete)/COUNT(e.ecoute_id)*100,1)          AS pct_ecoutes_completes,
    MAX(e.date_ecoute)                                       AS derniere_ecoute,
    DATEDIFF('2026-04-01', MAX(e.date_ecoute))               AS recence_jours
FROM clients c
LEFT JOIN souscriptions s  ON c.client_id = s.client_id AND s.actif = TRUE
LEFT JOIN abonnements a    ON s.abonnement_id = a.abonnement_id
LEFT JOIN ecoutes e        ON c.client_id = e.client_id
GROUP BY c.client_id, c.nom, c.ville, c.age, a.nom_offre;

-- ============================================
-- FONCTION : segment RFM selon score total
-- ============================================

DELIMITER $$

CREATE FUNCTION IF NOT EXISTS get_rfm_segment(score INT)
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    DECLARE seg VARCHAR(30);
    IF    score >= 13 THEN SET seg = 'Champions';
    ELSEIF score >= 10 THEN SET seg = 'Fideles';
    ELSEIF score >= 7  THEN SET seg = 'Potentiel';
    ELSEIF score >= 4  THEN SET seg = 'A_risque';
    ELSE                    SET seg = 'Endormi';
    END IF;
    RETURN seg;
END$$

DELIMITER ;

-- ============================================
-- PROCÉDURE STOCKÉE : résumé marketing ville
-- ============================================

DELIMITER $$

CREATE PROCEDURE IF NOT EXISTS resume_ville(IN p_ville VARCHAR(50))
BEGIN
    SELECT
        c.ville,
        COUNT(DISTINCT c.client_id)          AS nb_clients,
        ROUND(AVG(
            DATEDIFF('2026-04-01', e.date_ecoute)
        ),1)                                 AS recence_moy_j,
        COUNT(e.ecoute_id)                   AS total_ecoutes,
        ROUND(SUM(e.complete)/COUNT(e.ecoute_id)*100,1) AS pct_engagement
    FROM clients c
    LEFT JOIN ecoutes e ON c.client_id = e.client_id
    WHERE c.ville = p_ville
    GROUP BY c.ville;
END$$

DELIMITER ;

-- Test
CALL resume_ville('Lyon');
