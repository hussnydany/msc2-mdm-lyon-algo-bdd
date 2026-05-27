

-- fonction
DELIMITER //

CREATE FUNCTION score_recence(jours INT)  
RETURNS INT                               
DETERMINISTIC                        
BEGIN
    IF jours < 30 THEN RETURN 3;           
    ELSEIF jours < 90 THEN RETURN 2;       
    ELSE RETURN 1;                         
    END IF;
END //

DELIMITER ;

-- tester la fonction
SELECT score_recence(10);  
SELECT score_recence(50);  
SELECT score_recence(120); 

-- utiliser la fonction dans une requete
SELECT
    nom,
    DATEDIFF(CURDATE(), MAX(date_achat)) AS jours,          
    score_recence(DATEDIFF(CURDATE(), MAX(date_achat))) AS score_r 
FROM ecommerce_rfm.clients c
INNER JOIN ecommerce_rfm.achats a ON c.client_id = a.client_id
GROUP BY c.client_id, c.nom;


-- procedure

DELIMITER //

CREATE PROCEDURE clients_par_ville(
    IN v VARCHAR(50)     
)
BEGIN
    SELECT nom, ville, date_inscription
    FROM ecommerce_rfm.clients
    WHERE ville = v   
    ORDER BY date_inscription DESC;
END //

DELIMITER ;

-- appeler la procedure
CALL clients_par_ville('Lyon');  
CALL clients_par_ville('Paris'); 

-- supprimer une fonction ou une procedure
-- DROP FUNCTION IF EXISTS score_recence;
-- DROP PROCEDURE IF EXISTS clients_par_ville;
