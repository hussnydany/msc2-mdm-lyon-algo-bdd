WITH compteur AS (
    -- on donne le nom compteur a cette requete intermediaire
    SELECT utilisateur_id, COUNT(*) AS nb_ecoutes
    FROM ecoutes
    GROUP BY utilisateur_id
)
-- on utilise compteur comme si c'etait une table
SELECT ROUND(AVG(nb_ecoutes), 1) AS moyenne
FROM compteur;

-- un artiste avec plus d'ecoutes que la moyenne
WITH ecoutes_par_artiste AS (
    -- CTE 1 : nombre d'ecoutes par artiste
    SELECT ar.nom, COUNT(e.ecoute_id) AS nb_ecoutes
    FROM artistes ar
    LEFT JOIN albums al ON ar.artiste_id = al.artiste_id 
    LEFT JOIN titres t ON al.album_id = t.album_id
    LEFT JOIN ecoutes e ON t.titre_id = e.titre_id
    GROUP BY ar.nom
),
moyenne AS (
    --  la moyenne des ecoutes calculée a partir du CTE 1
    SELECT AVG(nb_ecoutes) AS moy FROM ecoutes_par_artiste
)
-- requete finale : on utilise les deux CTE ensemble
SELECT nom, nb_ecoutes
FROM ecoutes_par_artiste, moyenne   
WHERE nb_ecoutes > moy          
ORDER BY nb_ecoutes DESC;
