-- quels artistes ont des albums sortis apres 2020
SELECT nom FROM artistes
WHERE artiste_id IN (
    -- cette sous-requete s'execute en premier
    -- elle renvoie une liste d'artiste_id (ex: 2, 4)
    SELECT artiste_id FROM albums WHERE annee > 2020
);
-- la requete principale garde les artistes dont l'id est dans cette liste

-- NOT IN : ne fait PAS partie de cette liste


-- quels utilisateurs n'ont cree aucune playlist
SELECT prenom FROM utilisateurs
WHERE utilisateur_id NOT IN (
    -- liste des utilisateur_id qui ont au moins une playlist
    SELECT utilisateur_id FROM playlists
);
-- on garde ceux qui ne sont PAS dans cette liste

-- quels titres durent plus longtemps que la moyenne
SELECT nom, duree_sec FROM titres
WHERE duree_sec > (
    -- cette sous-requete renvoie la moyenne de duree
    SELECT AVG(duree_sec) FROM titres
);
-- on garde les titres dont la duree est superieure a ce chiffre

-- Sous-requete dans le FROM
-- quel est le nombre moyen d'ecoutes par utilisateur
SELECT ROUND(AVG(nb_ecoutes), 1) AS moyenne_ecoutes_par_user
FROM (
    -- compter les ecoutes par utilisateur
    SELECT utilisateur_id, COUNT(*) AS nb_ecoutes
    FROM ecoutes
    GROUP BY utilisateur_id
) AS compteur; 
