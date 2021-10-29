-- Projet SQL

--SCHEMA
DROP SCHEMA IF EXISTS projet_sql CASCADE;
CREATE SCHEMA projet_sql;

--CREATE TABLES
CREATE TABLE projet_sql.etudiants
(
    id_etudiant               SERIAL PRIMARY KEY,
    nom                       VARCHAR(100) NOT NULL CHECK ( nom <> '' ),
    prenom                    VARCHAR(100) NOT NULL CHECK ( prenom <> '' ),
    email                     VARCHAR(150) NOT NULL UNIQUE CHECK ( email <> ''),
    mot_de_passe              VARCHAR(30)  NOT NULL CHECK ( mot_de_passe <> '' ),
    bloc                      INT CHECK ( bloc >= 1 AND bloc <= 3 ),
    nombre_de_credits_valides INT          NOT NULL CHECK ( nombre_de_credits_valides >= 0 AND nombre_de_credits_valides <= 180)
);

CREATE TABLE ues (
    code_ue --VARCHAR OR CHAR? probleme de conception voir dans cours
    --TODO
);

CREATE TABLE projet_sql.paes (
    code_pae SERIAL PRIMARY KEY ,
    etudiant INT NOT NULL UNIQUE,
    valide VARCHAR(10) CHECK ( valide = 'refusé' OR valide = 'accepté' OR valide = 'soumis' ),
    nombre_de_credits_total INT NOT NULL CHECK ( valide <> 'accepté' AND  )
    FOREIGN KEY (etudiant) REFERENCES projet_sql.etudiants(id_etudiant)
)
