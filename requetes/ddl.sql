
-- Creer la table playlists
CREATE TABLE playlists (
    playlist_id INT PRIMARY KEY AUTO_INCREMENT,  
    nom VARCHAR(100) NOT NULL,                   
    utilisateur_id INT NOT NULL,                 
    date_creation DATE,                          
    FOREIGN KEY (utilisateur_id)                 
        REFERENCES utilisateurs(utilisateur_id) 
);

-- Creer la table de liaison playlist_titres 
CREATE TABLE playlist_titres (
    playlist_id INT NOT NULL,                        
    titre_id INT NOT NULL,                           
    ordre INT,                                       
    PRIMARY KEY (playlist_id, titre_id),             
    FOREIGN KEY (playlist_id)                        
        REFERENCES playlists(playlist_id),
    FOREIGN KEY (titre_id)                           
        REFERENCES titres(titre_id)
);

-- ajouter une colonne a une table existante
ALTER TABLE playlists ADD COLUMN description VARCHAR(255);

-- supprimer une colonne
ALTER TABLE playlists DROP COLUMN description;

-- supprimer une table
-- Attention a l'ordre : d'abord les tables enfants puis les parents
-- DROP TABLE playlist_titres;  -- enfant d'abord
-- DROP TABLE playlists;        -- parent ensuite


INSERT INTO playlists (nom, utilisateur_id, date_creation) VALUES
('Chill du soir', 1, '2026-03-01'),
('Workout', 3, '2026-03-05'),
('Classics FR', 1, '2026-03-10'),
('Decouvertes', 4, '2026-02-20');

INSERT INTO playlist_titres (playlist_id, titre_id, ordre) VALUES
(1, 3, 1), (1, 7, 2), (1, 8, 3),         
(2, 1, 1), (2, 2, 2), (2, 4, 3), (2, 5, 4),
(3, 6, 1), (3, 9, 2), (3, 11, 3), (3, 13, 4), 
(4, 4, 1), (4, 8, 2);                      

SELECT * FROM playlist_titres;
