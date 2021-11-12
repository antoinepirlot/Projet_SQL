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

CREATE TABLE projet_sql.ues
(
    id_ue             SERIAL PRIMARY KEY,
    code_ue           VARCHAR(15) NOT NULL UNIQUE,
    nom               VARCHAR(50) NOT NULL,
    bloc              INT         NOT NULL CHECK (bloc = 1 OR bloc = 2 OR bloc = 3),
    nombre_de_credits INT         NOT NULL CHECK ( nombre_de_credits > 0 ),
    nombre_d_inscrits INT         NOT NULL CHECK (nombre_d_inscrits > 0)
);

CREATE TABLE projet_sql.prerequis
(

    id_ue           INT NOT NULL CHECK ( id_ue <> id_ue_prerequis ),---- Attention WARNING AU CHECK
    id_ue_prerequis INT NOT NULL CHECK ( id_ue <> id_ue_prerequis ),
    CONSTRAINT id_prerequis PRIMARY KEY (id_ue, id_ue_prerequis),
    FOREIGN KEY (id_ue) REFERENCES projet_sql.ues (id_ue),
    FOREIGN KEY (id_ue_prerequis) REFERENCES projet_sql.ues (id_ue)

);

CREATE TABLE projet_sql.paes
(
    code_pae                SERIAL PRIMARY KEY,
    etudiant                INT NOT NULL UNIQUE,
    valide                  VARCHAR(7) CHECK ( valide = 'refusé' OR valide = 'accepté' OR valide = 'soumis' ),
    nombre_de_credits_total INT NOT NULL CHECK ( valide <> 'accepté' ), -- check pour ne pas changer le nbr de credit quand le pae est validé
    FOREIGN KEY (etudiant) REFERENCES projet_sql.etudiants (id_etudiant)
);

CREATE TABLE projet_sql.ues_validees
(
    id_etudiant INT NOT NULL,
    id_ue       INT NOT NULL,
    CONSTRAINT id_ue_validee PRIMARY KEY (id_etudiant, id_ue),
    FOREIGN KEY (id_etudiant) REFERENCES projet_sql.etudiants (id_etudiant),
    FOREIGN KEY (id_ue) REFERENCES projet_sql.ues (id_ue)
);

CREATE TABLE projet_sql.lignes_pae
(
    code_pae INT NOT NULL,
    id_ue    INT NOT NULL,
    CONSTRAINT id_ligne_pae PRIMARY KEY (code_pae, id_ue),
    FOREIGN KEY (code_pae) REFERENCES projet_sql.paes (code_pae),
    FOREIGN KEY (id_ue) REFERENCES projet_sql.ues (id_ue)
);









