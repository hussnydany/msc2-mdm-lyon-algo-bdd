-- ============================================================
--  E-COMMERCE RETAIL — Base de données Marketing RFM
--  Projet Final Algo & BDD 2026
--  Table des matières :
--    1. Création BDD & tables
--    2. Insertion des données
--    3. Requêtes SELECT analytiques (5+)
--    4. Vue (CREATE VIEW)
--    5. Fonction & Procédure stockées
-- ============================================================

DROP DATABASE IF EXISTS ecommerce_marketing;
CREATE DATABASE ecommerce_marketing CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_marketing;

-- ════════════════════════════════════════════════════════════
-- 1. CRÉATION DES TABLES
-- ════════════════════════════════════════════════════════════

-- Catégories de produits
CREATE TABLE categories (
    categorie_id   INT          AUTO_INCREMENT PRIMARY KEY,
    nom            VARCHAR(100) NOT NULL,
    description    TEXT
);

-- Produits
CREATE TABLE produits (
    produit_id     INT           AUTO_INCREMENT PRIMARY KEY,
    nom            VARCHAR(200)  NOT NULL,
    categorie_id   INT           NOT NULL,
    prix_ht        DECIMAL(10,2) NOT NULL,
    stock          INT           NOT NULL DEFAULT 0,
    CONSTRAINT fk_produit_categorie FOREIGN KEY (categorie_id) REFERENCES categories(categorie_id)
);

-- Clients
CREATE TABLE clients (
    client_id      INT          AUTO_INCREMENT PRIMARY KEY,
    nom            VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    ville          VARCHAR(100) NOT NULL,
    pays           VARCHAR(50)  NOT NULL DEFAULT 'France',
    devise         VARCHAR(10)  NOT NULL DEFAULT 'EUR',
    date_inscription DATE        NOT NULL
);

-- Commandes
CREATE TABLE commandes (
    commande_id    INT           AUTO_INCREMENT PRIMARY KEY,
    client_id      INT           NOT NULL,
    date_commande  DATE          NOT NULL,
    statut         ENUM('livree','annulee','en_cours') NOT NULL DEFAULT 'en_cours',
    montant_total  DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_commande_client FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- Lignes de commande (relation many-to-many commandes <-> produits)
CREATE TABLE lignes_commande (
    ligne_id       INT           AUTO_INCREMENT PRIMARY KEY,
    commande_id    INT           NOT NULL,
    produit_id     INT           NOT NULL,
    quantite       INT           NOT NULL DEFAULT 1,
    prix_unitaire  DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_ligne_commande FOREIGN KEY (commande_id) REFERENCES commandes(commande_id),
    CONSTRAINT fk_ligne_produit  FOREIGN KEY (produit_id)  REFERENCES produits(produit_id)
);

-- Campagnes marketing
CREATE TABLE campagnes (
    campagne_id    INT          AUTO_INCREMENT PRIMARY KEY,
    nom            VARCHAR(150) NOT NULL,
    type_campagne  ENUM('email','sms','push','social') NOT NULL,
    date_debut     DATE         NOT NULL,
    date_fin       DATE         NOT NULL,
    budget         DECIMAL(10,2)
);

-- Association clients <-> campagnes (many-to-many)
CREATE TABLE campagnes_clients (
    campagne_id    INT  NOT NULL,
    client_id      INT  NOT NULL,
    ouvert         TINYINT(1) NOT NULL DEFAULT 0,
    clique         TINYINT(1) NOT NULL DEFAULT 0,
    converti       TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (campagne_id, client_id),
    CONSTRAINT fk_cc_campagne FOREIGN KEY (campagne_id) REFERENCES campagnes(campagne_id),
    CONSTRAINT fk_cc_client   FOREIGN KEY (client_id)   REFERENCES clients(client_id)
);

-- Avis produits
CREATE TABLE avis (
    avis_id        INT  AUTO_INCREMENT PRIMARY KEY,
    client_id      INT  NOT NULL,
    produit_id     INT  NOT NULL,
    note           TINYINT NOT NULL CHECK (note BETWEEN 1 AND 5),
    commentaire    TEXT,
    date_avis      DATE NOT NULL,
    CONSTRAINT fk_avis_client  FOREIGN KEY (client_id)  REFERENCES clients(client_id),
    CONSTRAINT fk_avis_produit FOREIGN KEY (produit_id) REFERENCES produits(produit_id)
);

-- Résultats RFM (alimentée par le pipeline Python)
CREATE TABLE rfm_segments (
    client_id      INT          NOT NULL UNIQUE,
    recence_j      INT          NOT NULL,
    frequence      INT          NOT NULL,
    montant_total  DECIMAL(10,2) NOT NULL,
    score_r        TINYINT      NOT NULL,
    score_f        TINYINT      NOT NULL,
    score_m        TINYINT      NOT NULL,
    score_total    TINYINT      NOT NULL,
    segment        VARCHAR(50)  NOT NULL,
    date_calcul    DATE         NOT NULL,
    taux_change    FLOAT        DEFAULT NULL,
    montant_eur    DECIMAL(10,2) DEFAULT NULL,
    CONSTRAINT fk_rfm_client FOREIGN KEY (client_id) REFERENCES clients(client_id)
);


-- ════════════════════════════════════════════════════════════
-- 2. INSERTION DES DONNÉES
-- ════════════════════════════════════════════════════════════

INSERT INTO categories (nom, description) VALUES
('Électronique',    'Smartphones, ordinateurs, accessoires'),
('Mode',            'Vêtements, chaussures, accessoires de mode'),
('Maison & Déco',   'Mobilier, décoration intérieure'),
('Sport & Loisirs', 'Équipement sportif et outdoor'),
('Beauté & Santé',  'Cosmétiques, soins, bien-être');

INSERT INTO produits (nom, categorie_id, prix_ht, stock) VALUES
('Smartphone Pro X',         1, 799.00,  45),
('Écouteurs Bluetooth',      1,  89.99, 120),
('Chargeur USB-C 65W',       1,  29.99, 200),
('Tablette 10 pouces',       1, 349.00,  30),
('Veste en cuir noir',       2, 199.00,  60),
('Sneakers Running V2',      2,  79.99,  80),
('Robe d\'été florale',      2,  59.99,  90),
('Jean slim stretch',        2,  49.99, 110),
('Lampe de bureau LED',      3,  44.99,  75),
('Miroir mural scandinave',  3,  89.00,  40),
('Coussin velours 50x50',    3,  24.99, 150),
('Tapis bohème 160x230',     3, 129.00,  25),
('Tapis de yoga 6mm',        4,  34.99,  95),
('Gourde isotherme 750ml',   4,  27.99, 180),
('Casque vélo urbain',       4,  59.99,  50),
('Haltères réglables 20kg',  4, 149.00,  20),
('Crème hydratante SPF50',   5,  22.99, 200),
('Sérum vitamine C',         5,  38.99, 130),
('Brosse nettoyante visage', 5,  49.99,  65),
('Coffret parfum 100ml',     5,  89.00,  45);

INSERT INTO clients (nom, email, ville, pays, devise, date_inscription) VALUES
('Alice Martin',      'alice.martin@email.fr',      'Paris',     'France',      'EUR', '2023-01-15'),
('Bob Dupont',        'bob.dupont@email.fr',         'Lyon',      'France',      'EUR', '2023-02-20'),
('Clara Rousseau',    'clara.rousseau@email.fr',     'Bordeaux',  'France',      'EUR', '2023-03-10'),
('David Chen',        'david.chen@email.com',        'Londres',   'Royaume-Uni', 'GBP', '2023-04-05'),
('Emma Weiss',        'emma.weiss@email.de',         'Berlin',    'Allemagne',   'EUR', '2023-04-18'),
('Fabien Moreau',     'fabien.moreau@email.fr',      'Nantes',    'France',      'EUR', '2023-05-01'),
('Giulia Ricci',      'giulia.ricci@email.it',       'Rome',      'Italie',      'EUR', '2023-05-22'),
('Hugo Bernard',      'hugo.bernard@email.fr',       'Marseille', 'France',      'EUR', '2023-06-08'),
('Isabelle Petit',    'isabelle.petit@email.fr',     'Toulouse',  'France',      'EUR', '2023-06-30'),
('James Smith',       'james.smith@email.com',       'New York',  'USA',         'USD', '2023-07-12'),
('Katia Novak',       'katia.novak@email.cz',        'Prague',    'Tchéquie',    'CZK', '2023-07-25'),
('Lucas Silva',       'lucas.silva@email.br',        'São Paulo', 'Brésil',      'BRL', '2023-08-10'),
('Marie Leconte',     'marie.leconte@email.fr',      'Strasbourg','France',      'EUR', '2023-08-28'),
('Nathan Wright',     'nathan.wright@email.com',     'Chicago',   'USA',         'USD', '2023-09-15'),
('Olivia Garcia',     'olivia.garcia@email.es',      'Madrid',    'Espagne',     'EUR', '2023-09-30'),
('Pierre Lambert',    'pierre.lambert@email.fr',     'Lille',     'France',      'EUR', '2023-10-12'),
('Qing Zhang',        'qing.zhang@email.cn',         'Shanghai',  'Chine',       'CNY', '2023-10-20'),
('Rosa Fernandez',    'rosa.fernandez@email.mx',     'Mexico',    'Mexique',     'MXN', '2023-11-05'),
('Samuel Durand',     'samuel.durand@email.fr',      'Rennes',    'France',      'EUR', '2023-11-18'),
('Tina Hofer',        'tina.hofer@email.at',         'Vienne',    'Autriche',    'EUR', '2023-12-01'),
('Ugo Barbieri',      'ugo.barbieri@email.it',       'Milan',     'Italie',      'EUR', '2023-12-15'),
('Valérie Leroux',    'valerie.leroux@email.fr',     'Paris',     'France',      'EUR', '2024-01-08'),
('William Taylor',    'william.taylor@email.com',    'Toronto',   'Canada',      'CAD', '2024-01-22'),
('Xander Muller',     'xander.muller@email.nl',      'Amsterdam', 'Pays-Bas',    'EUR', '2024-02-10'),
('Yuki Tanaka',       'yuki.tanaka@email.jp',        'Tokyo',     'Japon',       'JPY', '2024-02-28'),
('Zoé Blanchard',     'zoe.blanchard@email.fr',      'Nice',      'France',      'EUR', '2024-03-15'),
('Antoine Roux',      'antoine.roux@email.fr',       'Paris',     'France',      'EUR', '2024-04-02'),
('Beatriz Costa',     'beatriz.costa@email.pt',      'Lisbonne',  'Portugal',    'EUR', '2024-04-20'),
('Carlos Mendez',     'carlos.mendez@email.ar',      'Buenos Aires','Argentine', 'ARS', '2024-05-10'),
('Diane Fontaine',    'diane.fontaine@email.fr',     'Grenoble',  'France',      'EUR', '2024-05-25'),
('Elias Svensson',    'elias.svensson@email.se',     'Stockholm', 'Suède',       'SEK', '2024-06-08'),
('Fatima El Amrani',  'fatima.el@email.ma',          'Casablanca','Maroc',       'MAD', '2024-06-22'),
('Gaël Thomas',       'gael.thomas@email.fr',        'Lyon',      'France',      'EUR', '2024-07-05'),
('Helena Koch',       'helena.koch@email.de',        'Munich',    'Allemagne',   'EUR', '2024-07-20'),
('Ivan Petrov',       'ivan.petrov@email.ru',        'Moscou',    'Russie',      'RUB', '2024-08-10');

-- Commandes (variées sur 2023-2026)
INSERT INTO commandes (client_id, date_commande, statut, montant_total) VALUES
(1,  '2024-01-10', 'livree',   245.98),
(1,  '2024-06-15', 'livree',   89.99),
(1,  '2024-11-20', 'livree',   199.00),
(1,  '2025-02-14', 'livree',   349.00),
(1,  '2025-12-01', 'livree',   129.99),
(1,  '2026-03-18', 'livree',   799.00),
(2,  '2024-03-05', 'livree',   79.99),
(2,  '2024-09-12', 'livree',   149.00),
(2,  '2025-04-20', 'livree',   89.00),
(2,  '2026-01-08', 'livree',   44.99),
(3,  '2024-02-28', 'livree',   59.99),
(3,  '2024-07-04', 'livree',   49.99),
(3,  '2025-01-15', 'livree',   38.99),
(4,  '2024-05-10', 'livree',   799.00),
(4,  '2024-10-22', 'livree',   89.99),
(4,  '2025-03-30', 'livree',   349.00),
(4,  '2025-11-05', 'livree',   199.00),
(4,  '2026-02-28', 'livree',   89.00),
(5,  '2024-04-18', 'livree',   129.00),
(5,  '2025-08-09', 'livree',   24.99),
(5,  '2026-03-01', 'livree',   149.00),
(6,  '2024-06-01', 'livree',   34.99),
(6,  '2025-02-10', 'livree',   27.99),
(7,  '2024-08-14', 'livree',   22.99),
(7,  '2025-05-20', 'livree',   49.99),
(7,  '2025-12-10', 'livree',   89.00),
(8,  '2024-09-01', 'livree',   799.00),
(8,  '2025-01-18', 'livree',   199.00),
(8,  '2025-07-22', 'livree',   79.99),
(8,  '2026-03-10', 'livree',   349.00),
(9,  '2024-10-15', 'livree',   59.99),
(9,  '2025-06-08', 'livree',   44.99),
(10, '2024-11-01', 'livree',   349.00),
(10, '2025-04-15', 'livree',   89.99),
(10, '2026-01-20', 'livree',   799.00),
(11, '2024-12-05', 'livree',   24.99),
(12, '2025-01-10', 'livree',   59.99),
(12, '2025-09-14', 'livree',   34.99),
(13, '2025-02-01', 'livree',   199.00),
(13, '2025-10-08', 'livree',   89.99),
(13, '2026-02-14', 'livree',   129.00),
(14, '2025-03-20', 'livree',   799.00),
(14, '2025-11-30', 'livree',   349.00),
(14, '2026-03-05', 'livree',   199.00),
(15, '2025-04-10', 'livree',   49.99),
(15, '2025-12-18', 'livree',   79.99),
(16, '2025-05-15', 'livree',   89.00),
(16, '2026-01-25', 'livree',   44.99),
(17, '2025-06-20', 'livree',   799.00),
(17, '2025-12-01', 'livree',   199.00),
(18, '2025-07-08', 'livree',   129.00),
(19, '2025-08-15', 'livree',   22.99),
(19, '2026-02-20', 'livree',   89.99),
(20, '2025-09-01', 'livree',   349.00),
(21, '2025-10-12', 'livree',   59.99),
(21, '2026-03-22', 'livree',   199.00),
(22, '2025-11-05', 'livree',   89.00),
(22, '2026-02-08', 'livree',   349.00),
(22, '2026-03-30', 'livree',   799.00),
(23, '2025-12-10', 'livree',   149.00),
(24, '2026-01-15', 'livree',   44.99),
(24, '2026-03-20', 'livree',   129.00),
(25, '2026-02-01', 'livree',   89.99),
(26, '2026-03-10', 'livree',   349.00),
(27, '2026-03-15', 'livree',   59.99),
(28, '2026-03-18', 'livree',   24.99),
(29, '2024-05-10', 'annulee',  99.00),
(30, '2024-12-20', 'livree',   199.00),
(31, '2025-02-14', 'livree',   79.99),
(32, '2025-04-01', 'livree',   38.99),
(32, '2025-11-11', 'livree',   89.00),
(33, '2025-06-15', 'livree',   349.00),
(33, '2026-01-10', 'livree',   199.00),
(34, '2025-08-20', 'livree',   149.00),
(35, '2025-10-05', 'annulee',  59.99);

-- Lignes de commande (quelques exemples significatifs)
INSERT INTO lignes_commande (commande_id, produit_id, quantite, prix_unitaire) VALUES
(1,  1,  1, 799.00), (1,  2,  1, 89.99),
(2,  2,  1, 89.99),
(3,  5,  1, 199.00),
(4,  4,  1, 349.00),
(5,  12, 1, 129.00),
(6,  1,  1, 799.00),
(7,  6,  1, 79.99),
(8,  16, 1, 149.00),
(9,  10, 1, 89.00),
(10, 9,  1, 44.99),
(11, 7,  1, 59.99),
(12, 8,  1, 49.99),
(13, 18, 1, 38.99),
(14, 1,  1, 799.00),
(15, 2,  1, 89.99),
(16, 4,  1, 349.00),
(17, 5,  1, 199.00),
(18, 10, 1, 89.00),
(19, 12, 1, 129.00),
(20, 11, 1, 24.99),
(21, 16, 1, 149.00),
(22, 13, 1, 34.99),
(23, 14, 1, 27.99),
(24, 17, 1, 22.99),
(25, 19, 1, 49.99),
(26, 10, 1, 89.00),
(27, 1,  1, 799.00),
(28, 5,  1, 199.00),
(29, 6,  1, 79.99),
(30, 4,  1, 349.00);

-- Campagnes marketing
INSERT INTO campagnes (nom, type_campagne, date_debut, date_fin, budget) VALUES
('Black Friday 2025',       'email',  '2025-11-20', '2025-11-30', 5000.00),
('Soldes Hiver 2026',       'email',  '2026-01-08', '2026-01-31', 3500.00),
('Réactivation Endormis',   'sms',    '2026-02-01', '2026-02-28', 2000.00),
('Champions VIP Spring',    'push',   '2026-03-01', '2026-03-31', 1500.00),
('Nouveautés Printemps',    'social', '2026-04-01', '2026-04-30', 4000.00);

-- Association campagnes / clients
INSERT INTO campagnes_clients (campagne_id, client_id, ouvert, clique, converti) VALUES
(1, 1, 1, 1, 1), (1, 4, 1, 1, 1), (1, 8, 1, 1, 0), (1, 10, 1, 0, 0),
(1, 14, 1, 1, 1), (1, 22, 1, 1, 1), (1, 33, 1, 0, 0),
(2, 2, 1, 1, 0), (2, 5, 1, 1, 1), (2, 13, 1, 0, 0), (2, 16, 1, 1, 1),
(2, 24, 1, 1, 0), (2, 30, 1, 1, 1),
(3, 6, 0, 0, 0), (3, 11, 1, 0, 0), (3, 12, 0, 0, 0), (3, 18, 1, 1, 0),
(3, 29, 0, 0, 0), (3, 35, 1, 0, 0),
(4, 1, 1, 1, 1), (4, 4, 1, 1, 1), (4, 8, 1, 1, 1), (4, 14, 1, 1, 1),
(4, 22, 1, 1, 0), (4, 33, 1, 1, 1),
(5, 3, 1, 0, 0), (5, 7, 1, 1, 1), (5, 9, 1, 0, 0), (5, 15, 1, 1, 0),
(5, 19, 1, 1, 1), (5, 26, 1, 0, 0), (5, 27, 1, 1, 1);

-- Avis produits
INSERT INTO avis (client_id, produit_id, note, commentaire, date_avis) VALUES
(1,  1, 5, 'Excellent smartphone, très rapide !',         '2024-01-20'),
(1,  2, 4, 'Bonne qualité son, batterie un peu courte.',  '2024-06-25'),
(4,  1, 5, 'Top product, fast delivery!',                 '2024-05-18'),
(8,  1, 4, 'Super téléphone, rapport qualité-prix ok.',   '2024-09-10'),
(10, 4, 5, 'Great tablet for work and play.',             '2025-04-22'),
(14, 1, 5, 'Amazing phone, best I have had.',             '2025-03-12'),
(2,  16, 4, 'Haltères solides et pratiques.',             '2024-09-20'),
(3,  7, 3, 'Belle robe mais taille un peu grande.',       '2024-07-10'),
(13, 5, 5, 'Veste magnifique, très bien coupée.',         '2025-02-08'),
(22, 1, 5, 'Parfait, livraison rapide !',                 '2026-03-01');


-- ════════════════════════════════════════════════════════════
-- 3. REQUÊTES SELECT ANALYTIQUES
-- ════════════════════════════════════════════════════════════

-- ──────────────────────────────────────────────────────────
-- Requête 1 : Chiffre d'affaires par catégorie (GROUP BY + ORDER BY)
-- ──────────────────────────────────────────────────────────
SELECT
    cat.nom                             AS categorie,
    COUNT(DISTINCT lc.commande_id)      AS nb_commandes,
    SUM(lc.quantite)                    AS unites_vendues,
    ROUND(SUM(lc.quantite * lc.prix_unitaire), 2) AS ca_total
FROM lignes_commande lc
JOIN produits p   ON lc.produit_id  = p.produit_id
JOIN categories cat ON p.categorie_id = cat.categorie_id
JOIN commandes c  ON lc.commande_id = c.commande_id
WHERE c.statut = 'livree'
GROUP BY cat.nom
ORDER BY ca_total DESC;

-- ──────────────────────────────────────────────────────────
-- Requête 2 : Top 5 clients par montant total dépensé (HAVING + LIMIT)
-- ──────────────────────────────────────────────────────────
SELECT
    cl.client_id,
    cl.nom,
    cl.ville,
    COUNT(co.commande_id)            AS nb_commandes,
    ROUND(SUM(co.montant_total), 2)  AS ca_client
FROM clients cl
JOIN commandes co ON cl.client_id = co.client_id
WHERE co.statut = 'livree'
GROUP BY cl.client_id, cl.nom, cl.ville
HAVING ca_client > 100
ORDER BY ca_client DESC
LIMIT 5;

-- ──────────────────────────────────────────────────────────
-- Requête 3 : Taux d'ouverture et conversion par campagne (3 tables)
-- ──────────────────────────────────────────────────────────
SELECT
    c.nom                                              AS campagne,
    c.type_campagne,
    COUNT(cc.client_id)                                AS nb_destinataires,
    ROUND(AVG(cc.ouvert)  * 100, 1)                   AS taux_ouverture_pct,
    ROUND(AVG(cc.clique)  * 100, 1)                   AS taux_clic_pct,
    ROUND(AVG(cc.converti)* 100, 1)                   AS taux_conversion_pct
FROM campagnes c
JOIN campagnes_clients cc ON c.campagne_id = cc.campagne_id
JOIN clients cl            ON cc.client_id  = cl.client_id
GROUP BY c.campagne_id, c.nom, c.type_campagne
ORDER BY taux_conversion_pct DESC;

-- ──────────────────────────────────────────────────────────
-- Requête 4 : Clients n'ayant jamais commandé (sous-requête NOT IN)
-- ──────────────────────────────────────────────────────────
SELECT
    client_id,
    nom,
    email,
    date_inscription
FROM clients
WHERE client_id NOT IN (
    SELECT DISTINCT client_id FROM commandes WHERE statut = 'livree'
)
ORDER BY date_inscription;

-- ──────────────────────────────────────────────────────────
-- Requête 5 : CTE double — profil RFM brut par client
-- ──────────────────────────────────────────────────────────
WITH derniere_commande AS (
    SELECT client_id, MAX(date_commande) AS last_order
    FROM commandes
    WHERE statut = 'livree'
    GROUP BY client_id
),
stats_client AS (
    SELECT
        client_id,
        COUNT(*)                       AS frequence,
        ROUND(SUM(montant_total), 2)   AS montant_total
    FROM commandes
    WHERE statut = 'livree'
    GROUP BY client_id
)
SELECT
    cl.client_id,
    cl.nom,
    cl.devise,
    DATEDIFF('2026-04-01', dc.last_order) AS recence_jours,
    sc.frequence,
    sc.montant_total
FROM clients cl
LEFT JOIN derniere_commande dc ON cl.client_id = dc.client_id
LEFT JOIN stats_client      sc ON cl.client_id = sc.client_id
WHERE dc.last_order IS NOT NULL
ORDER BY recence_jours;

-- ──────────────────────────────────────────────────────────
-- Requête 6 : Note moyenne par produit (WHERE + HAVING)
-- ──────────────────────────────────────────────────────────
SELECT
    p.nom                        AS produit,
    cat.nom                      AS categorie,
    COUNT(a.avis_id)             AS nb_avis,
    ROUND(AVG(a.note), 2)        AS note_moyenne
FROM produits p
JOIN categories cat ON p.categorie_id = cat.categorie_id
LEFT JOIN avis a    ON p.produit_id   = a.produit_id
GROUP BY p.produit_id, p.nom, cat.nom
HAVING nb_avis > 0
ORDER BY note_moyenne DESC, nb_avis DESC;


-- ════════════════════════════════════════════════════════════
-- 4. VUE
-- ════════════════════════════════════════════════════════════

CREATE OR REPLACE VIEW vue_profil_client AS
SELECT
    cl.client_id,
    cl.nom,
    cl.email,
    cl.ville,
    cl.pays,
    cl.devise,
    cl.date_inscription,
    COUNT(co.commande_id)            AS nb_commandes,
    ROUND(SUM(co.montant_total), 2)  AS ca_total,
    MAX(co.date_commande)            AS derniere_commande,
    DATEDIFF('2026-04-01', MAX(co.date_commande)) AS recence_jours
FROM clients cl
LEFT JOIN commandes co ON cl.client_id = co.client_id AND co.statut = 'livree'
GROUP BY cl.client_id, cl.nom, cl.email, cl.ville, cl.pays, cl.devise, cl.date_inscription;


-- ════════════════════════════════════════════════════════════
-- 5. FONCTION ET PROCÉDURE STOCKÉES
-- ════════════════════════════════════════════════════════════

DELIMITER //

-- Fonction : retourne le label du segment RFM selon le score total
CREATE FUNCTION get_rfm_segment(score INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE seg VARCHAR(20);
    IF score >= 13 THEN SET seg = 'Champions';
    ELSEIF score >= 10 THEN SET seg = 'Fideles';
    ELSEIF score >= 7  THEN SET seg = 'Potentiel';
    ELSEIF score >= 4  THEN SET seg = 'A_risque';
    ELSE SET seg = 'Endormi';
    END IF;
    RETURN seg;
END //

-- Procédure : résumé commercial d'un pays
CREATE PROCEDURE resume_pays(IN p_pays VARCHAR(50))
BEGIN
    SELECT
        cl.pays,
        COUNT(DISTINCT cl.client_id)     AS nb_clients,
        COUNT(co.commande_id)            AS nb_commandes,
        ROUND(SUM(co.montant_total), 2)  AS ca_total,
        ROUND(AVG(co.montant_total), 2)  AS panier_moyen
    FROM clients cl
    JOIN commandes co ON cl.client_id = co.client_id
    WHERE cl.pays = p_pays AND co.statut = 'livree'
    GROUP BY cl.pays;
END //

DELIMITER ;

-- Appel exemple :
-- CALL resume_pays('France');
-- SELECT get_rfm_segment(12);
