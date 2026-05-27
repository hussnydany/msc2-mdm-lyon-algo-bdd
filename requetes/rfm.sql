-- Explorer les donnees
SELECT * FROM clients;
SELECT * FROM achats;

-- calculer r 
SELECT
    c.nom,                                                 
    MAX(a.date_achat) AS dernier_achat,                     
    DATEDIFF(CURDATE(), MAX(a.date_achat)) AS recence_jours 
FROM clients c
INNER JOIN achats a ON c.client_id = a.client_id           
GROUP BY c.client_id, c.nom                                 
ORDER BY recence_jours;                                

-- calculer r, f, m
SELECT
    c.nom,
    DATEDIFF(CURDATE(), MAX(a.date_achat)) AS recence_jours,
    COUNT(a.achat_id) AS frequence,                          
    ROUND(SUM(a.montant), 2) AS montant_total           
FROM clients c
INNER JOIN achats a ON c.client_id = a.client_id
GROUP BY c.client_id, c.nom
ORDER BY montant_total DESC;                                



-- calculer r, f, m et les scores
WITH rfm AS (
    SELECT
        c.client_id,
        c.nom,
        c.ville,
        DATEDIFF(CURDATE(), MAX(a.date_achat)) AS recence_jours,
        COUNT(a.achat_id) AS frequence,
        ROUND(SUM(a.montant), 2) AS montant_total,
        CASE
            WHEN DATEDIFF(CURDATE(), MAX(a.date_achat)) < 30 THEN 3  
            WHEN DATEDIFF(CURDATE(), MAX(a.date_achat)) < 90 THEN 2  
            ELSE 1                                                     
        END AS score_r,
        CASE
            WHEN COUNT(a.achat_id) >= 5 THEN 3   
            WHEN COUNT(a.achat_id) >= 3 THEN 2   
            ELSE 1                                
        END AS score_f,
        CASE
            WHEN SUM(a.montant) >= 500 THEN 3    
            WHEN SUM(a.montant) >= 200 THEN 2   
            ELSE 1                               
        END AS score_m
    FROM clients c
    INNER JOIN achats a ON c.client_id = a.client_id
    GROUP BY c.client_id, c.nom, c.ville
)
-- Maintenant on peut utiliser score_r, score_f, score_m parce qu'ils existent dans le CTE
SELECT
    nom, ville,
    recence_jours, frequence, montant_total,
    score_r, score_f, score_m,
    score_r + score_f + score_m AS score_total, 
    CASE
        WHEN score_r + score_f + score_m >= 8 THEN 'VIP'            
        WHEN score_r + score_f + score_m >= 6 THEN 'Fidele'        
        WHEN score_r + score_f + score_m >= 4 THEN 'A reactiver'    
        ELSE 'Endormi'                                               
    END AS segment
FROM rfm
ORDER BY score_total DESC;

-- creer une vue pour stocker ce resultat et pouvoir le reutiliser
CREATE VIEW vue_rfm AS
WITH rfm AS (
    SELECT
        c.client_id, c.nom, c.ville,
        DATEDIFF(CURDATE(), MAX(a.date_achat)) AS recence_jours,
        COUNT(a.achat_id) AS frequence,
        ROUND(SUM(a.montant), 2) AS montant_total,
        CASE
            WHEN DATEDIFF(CURDATE(), MAX(a.date_achat)) < 30 THEN 3
            WHEN DATEDIFF(CURDATE(), MAX(a.date_achat)) < 90 THEN 2
            ELSE 1
        END AS score_r,
        CASE
            WHEN COUNT(a.achat_id) >= 5 THEN 3
            WHEN COUNT(a.achat_id) >= 3 THEN 2
            ELSE 1
        END AS score_f,
        CASE
            WHEN SUM(a.montant) >= 500 THEN 3
            WHEN SUM(a.montant) >= 200 THEN 2
            ELSE 1
        END AS score_m
    FROM clients c
    INNER JOIN achats a ON c.client_id = a.client_id
    GROUP BY c.client_id, c.nom, c.ville
)
SELECT
    nom, ville, recence_jours, frequence, montant_total,
    score_r, score_f, score_m,
    score_r + score_f + score_m AS score_total,
    CASE
        WHEN score_r + score_f + score_m >= 8 THEN 'VIP'
        WHEN score_r + score_f + score_m >= 6 THEN 'Fidele'
        WHEN score_r + score_f + score_m >= 4 THEN 'A reactiver'
        ELSE 'Endormi'
    END AS segment
FROM rfm;

-- tester la vue
SELECT * FROM vue_rfm;

-- Stats par segment : combien de clients et panier moyen
SELECT
    segment,
    COUNT(*) AS nb_clients,                      
    ROUND(AVG(montant_total), 2) AS panier_moyen
FROM vue_rfm
GROUP BY segment
ORDER BY nb_clients DESC;
