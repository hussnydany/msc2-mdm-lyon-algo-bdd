-- update

SELECT * FROM utilisateurs WHERE prenom = 'Noah';

UPDATE utilisateurs     
SET pays = 'France'     
WHERE prenom = 'Noah';  


-- verifier
SELECT * FROM utilisateurs WHERE prenom = 'Noah';


-- ATTENTION : un UPDATE sans WHERE modifie TOUTES les lignes


-- delete
SELECT * FROM ecoutes WHERE date_ecoute < '2026-02-01';

DELETE FROM ecoutes                      
WHERE date_ecoute < '2026-02-01';     

-- ATTENTION : un DELETE sans WHERE supprime TOUTES les lignes

