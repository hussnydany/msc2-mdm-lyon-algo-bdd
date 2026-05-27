CREATE VIEW view_exemple AS
SELECT prenom, pays FROM utilisateurs WHERE pays = 'France';

SELECT * FROM view_exemple;

-- Supprimer la view
DROP VIEW IF EXISTS view_exemple;


-- view profil utilisateurs
CREATE VIEW view_profil_utilisateurs AS
SELECT
    u.prenom,                                     
    u.pays,                                       
    u.abonnement,                                  
    COUNT(e.ecoute_id) AS nb_ecoutes,              
    MAX(e.date_ecoute) AS derniere_activite        
FROM utilisateurs u
LEFT JOIN ecoutes e                                
    ON u.utilisateur_id = e.utilisateur_id
GROUP BY u.prenom, u.pays, u.abonnement;       

-- tester la view
SELECT * FROM view_profil_utilisateurs;

SELECT * FROM view_profil_utilisateurs WHERE nb_ecoutes = 0;       
SELECT * FROM view_profil_utilisateurs WHERE abonnement = 'Premium';


-- view stats artistes
CREATE VIEW view_stats_artistes AS
SELECT
    ar.nom AS artiste,                            
    COUNT(DISTINCT al.album_id) AS nb_albums,     
    COUNT(DISTINCT t.titre_id) AS nb_titres,       
    COUNT(e.ecoute_id) AS nb_ecoutes               
FROM artistes ar
LEFT JOIN albums al ON ar.artiste_id = al.artiste_id  
LEFT JOIN titres t ON al.album_id = t.album_id         
LEFT JOIN ecoutes e ON t.titre_id = e.titre_id         
GROUP BY ar.nom;

-- tester la view
SELECT * FROM view_stats_artistes ORDER BY nb_ecoutes DESC;
