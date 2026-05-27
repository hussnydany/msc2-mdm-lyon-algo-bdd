-- Lister toutes les tables
SHOW TABLES;

-- structure d'une table
DESCRIBE artistes;

-- voir la requete CREATE TABLE 
SHOW CREATE TABLE albums;

-- voir toutes les cles etrangeres de la base
SELECT
    TABLE_NAME,                   
    COLUMN_NAME,                 
    REFERENCED_TABLE_NAME,        
    REFERENCED_COLUMN_NAME       
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE  
WHERE TABLE_SCHEMA = 'spotifaille'     
  AND REFERENCED_TABLE_NAME IS NOT NULL;
