---------------------------------------------------------------------------
-------------------------------PROJET-SQL----------------------------------
---------------------------------------------------------------------------

---------------------------------------------------------------------------
------------------------------CREATE-SCHEMA--------------------------------
---------------------------------------------------------------------------

DROP SCHEMA IF EXISTS project_sql CASCADE;
CREATE SCHEMA project_sql;

---------------------------------------------------------------------------
-----------------------------CREATE-TABLES---------------------------------
---------------------------------------------------------------------------

CREATE TABLE project_sql.etudiants
(
    id_etudiant               SERIAL PRIMARY KEY,
    nom                       VARCHAR(100) NOT NULL CHECK ( nom <> '' ),
    prenom                    VARCHAR(100) NOT NULL CHECK ( prenom <> '' ),
    email                     VARCHAR(150) NOT NULL UNIQUE CHECK ( email <> ''),
    mot_de_passe              CHAR(60)     NOT NULL CHECK ( mot_de_passe <> '' ),
    bloc                      INT CHECK ( (bloc >= 1 AND bloc <= 3)),
    nombre_de_credits_valides INT          NOT NULL DEFAULT 0 CHECK ( nombre_de_credits_valides >= 0 AND nombre_de_credits_valides <= 180)
);

CREATE TABLE project_sql.ues
(
    id_ue             SERIAL PRIMARY KEY,
    code_ue           VARCHAR(15) NOT NULL UNIQUE,
    nom               VARCHAR(50) NOT NULL,
    bloc              INT         NOT NULL CHECK (bloc = 1 OR bloc = 2 OR bloc = 3),
    nombre_de_credits INT         NOT NULL CHECK ( nombre_de_credits > 0 ),
    nombre_d_inscrits INT         NOT NULL DEFAULT 0 CHECK (nombre_d_inscrits >= 0)
);

CREATE TABLE project_sql.prerequis
(

    id_ue            INT NOT NULL CHECK ( id_ue <> id_ue_prerequise ),
    id_ue_prerequise INT NOT NULL CHECK ( id_ue <> id_ue_prerequise ),
    CONSTRAINT id_prerequis PRIMARY KEY (id_ue, id_ue_prerequise),
    FOREIGN KEY (id_ue) REFERENCES project_sql.ues (id_ue),
    FOREIGN KEY (id_ue_prerequise) REFERENCES project_sql.ues (id_ue)

);

CREATE TABLE project_sql.paes
(
    code_pae                SERIAL PRIMARY KEY,
    id_etudiant             INT  NOT NULL UNIQUE,
    valide                  BOOL NOT NULL DEFAULT FALSE,
    nombre_de_credits_total INT  NOT NULL DEFAULT 0 CHECK ( valide IS FALSE AND nombre_de_credits_total >= 0 ),
    FOREIGN KEY (id_etudiant) REFERENCES project_sql.etudiants (id_etudiant)
);

CREATE TABLE project_sql.ues_validees
(
    id_etudiant INT NOT NULL,
    id_ue       INT NOT NULL,
    CONSTRAINT id_ue_validee PRIMARY KEY (id_etudiant, id_ue),
    FOREIGN KEY (id_etudiant) REFERENCES project_sql.etudiants (id_etudiant),
    FOREIGN KEY (id_ue) REFERENCES project_sql.ues (id_ue)
);

CREATE TABLE project_sql.ues_pae
(
    code_pae INT NOT NULL,
    id_ue    INT NOT NULL,
    CONSTRAINT id_ues_pae PRIMARY KEY (code_pae, id_ue),
    FOREIGN KEY (code_pae) REFERENCES project_sql.paes (code_pae),
    FOREIGN KEY (id_ue) REFERENCES project_sql.ues (id_ue)
);

---------------------------------------------------------------------------
-----------------------APPLICATION-CENTRALE-ADMIN--------------------------
---------------------------------------------------------------------------

/**
  Ajoute une ue dans la table ues
 */
CREATE OR REPLACE FUNCTION project_sql.ajouter_ue(_code_ue VARCHAR(15), _nom VARCHAR(50), _bloc INT,
                                                  _nombre_de_credits INT) RETURNS VOID AS
$$
BEGIN
    INSERT INTO project_sql.ues VALUES (DEFAULT, _code_ue, _nom, _bloc, _nombre_de_credits, DEFAULT);
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------

/**
  Ajoute un prérequis à une ue
 */
CREATE OR REPLACE FUNCTION project_sql.ajouter_prerequis_ue(_code_ue VARCHAR(15), _code_ue_prerequise VARCHAR(15)) RETURNS VOID AS
$$
DECLARE
    _ue            RECORD;
    _ue_prerequise RECORD;
BEGIN
    SELECT id_ue, bloc
    FROM project_sql.ues
    WHERE code_ue = _code_ue
    INTO _ue;

    SELECT id_ue, bloc
    FROM project_sql.ues
    WHERE code_ue = _code_ue_prerequise
    INTO _ue_prerequise;

    IF _ue_prerequise.bloc > _ue.bloc THEN
        RAISE 'Le bloc du prérequis est supérieur au bloc de cette ue.';
    END IF;

    IF _ue_prerequise.bloc = _ue.bloc THEN
        RAISE 'Le bloc du prérequis est égal au bloc de cette ue.';
    END IF;

    INSERT INTO project_sql.prerequis
    VALUES (_ue.id_ue, _ue_prerequise.id_ue);
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------

/**
  Ajoute un étudiant à la table etudiants
 */
CREATE OR REPLACE FUNCTION project_sql.ajouter_etudiant(_nom VARCHAR(100), _prenom VARCHAR(100), _email VARCHAR(150),
                                                        _mot_de_passe CHAR(60)) RETURNS VOID AS
$$
BEGIN
    INSERT INTO project_sql.etudiants
    VALUES (DEFAULT, _nom, _prenom, _email, _mot_de_passe, DEFAULT, DEFAULT);

    -- Le pae (vide) de l'étudiant est créé grâce au trigger_ajouter_pae
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------

/**
  Ajoute une UE validé à la table ue_validees
 */
CREATE OR REPLACE FUNCTION project_sql.encoder_ue_validee(_email VARCHAR(150), _code_ue VARCHAR(15)) RETURNS VOID AS
$$
DECLARE
    _ue            RECORD;
    _ue_prerequise RECORD;
    _etudiant      RECORD;
BEGIN
    SELECT id_ue
    FROM project_sql.ues
    WHERE code_ue = _code_ue
    INTO _ue;

    SELECT id_ue_prerequise, COUNT(*) AS "count"
    FROM project_sql.prerequis
    WHERE id_ue = _ue.id_ue
    GROUP BY id_ue_prerequise
    INTO _ue_prerequise;

    SELECT id_etudiant
    FROM project_sql.etudiants
    WHERE email = _email
    INTO _etudiant;

    -- Si il y a une ue prérequise et qu'elle n'est pas validée, alors on ne peut pas valider cette ue.
    IF _ue_prerequise.count <> 0
        AND (SELECT COUNT(*)
             FROM project_sql.ues_validees
             WHERE id_ue = _ue_prerequise.id_ue_prerequise
               AND id_etudiant = _etudiant.id_etudiant) = 0 THEN

        RAISE 'L''étudiant n''a pas validé le prérequis de ce cours.';
    END IF;

    -- Pas besoin de vérifier si l'ue est déjà validée car il y a la contrainte d'unicité qui vérifie cela
    -- La contrainte référentiel aussi vérifie que l'ue est déjà présente dans la DB
    INSERT INTO project_sql.ues_validees
    VALUES (_etudiant.id_etudiant, _ue.id_ue);

    --Le nombre de crédits validés de l'étudiant est augmenté grâce au trigger_augmenter_credits_valides
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------
------------------APPLICATION-CENTRALE-ETUDIANT----------------------
---------------------------------------------------------------------

/**
  Ajoute une ue au pae de l'étudiant
 */
CREATE OR REPLACE FUNCTION project_sql.ajouter_ue_pae(_email VARCHAR(150), _code_ue VARCHAR(15)) RETURNS VOID AS
$$
DECLARE
    _etudiant      RECORD;
    _pae           RECORD;
    _ue            RECORD;
    _ue_prerequise RECORD;
BEGIN
    SELECT id_etudiant
    FROM project_sql.etudiants
    WHERE email = _email
    INTO _etudiant;

    SELECT valide, nombre_de_credits_total
    FROM project_sql.paes
    WHERE id_etudiant = _etudiant.id_etudiant
    INTO _pae;

    SELECT id_ue, bloc
    FROM project_sql.ues
    WHERE code_ue = _code_ue
    INTO _ue;

    -- Si le PAE est déjà validé
    IF _pae.valide IS TRUE THEN
        RAISE 'Ce PAE a déjà été validé, il est impossible d''ajouter une ue.';
    END IF;

    -- Si l’étudiant a déjà validé cette UE précédemment
    IF (SELECT COUNT(*)
        FROM project_sql.ues_validees
        WHERE id_ue = _ue.id_ue
          AND id_etudiant = _etudiant.id_etudiant) <> 0 THEN

        RAISE 'Cette ue a déjà été validée par l''étudiant';
    END IF;

    -- Si l’étudiant a validé moins de 30 ects et que l’UE n’est pas du bloc 1
    IF (SELECT nombre_de_credits_valides
        FROM project_sql.etudiants
        WHERE id_etudiant = _etudiant.id_etudiant) < 30 AND _ue.bloc != 1 THEN

        RAISE 'L''étudiant a validé moins de 30 crédits et cette ue ne figure pas au bloc 1.';
    END IF;

    -- Si l’étudiant n’a pas validé tous les prérequis de cette UE
    -- Avec les vérifications de la fonction encoder_ue_validee, il est impossible que le prérequis ai été validé sans
    -- sans son prérequis.
    FOR _ue_prerequise IN (SELECT id_ue_prerequise
                           FROM project_sql.prerequis
                           WHERE id_ue = _ue.id_ue)
        LOOP
            IF (SELECT COUNT(*)
                FROM project_sql.ues_validees
                WHERE id_ue = _ue_prerequise.id_ue_prerequise
                  AND id_etudiant = _etudiant.id_etudiant) = 0 THEN
                RAISE 'L''étudiant n''a pas validé une ue prérequise.';
            END IF;
        END LOOP;

    --L'augmentation du nombre de crédits total du pae se fait grâce au trigger_augmenter_nombre_de_credits_pae
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------

/**
  Enlève une UE au PAE de l'étudiant
 */
CREATE OR REPLACE FUNCTION project_sql.enlever_ue_pae(_email VARCHAR(150), _code_ue VARCHAR(15)) RETURNS VOID AS
$$
DECLARE
    _ue       RECORD;
    _etudiant RECORD;
BEGIN
    SELECT id_etudiant
    FROM project_sql.etudiants
    WHERE email = _email
    INTO _etudiant;

    IF (SELECT valide
        FROM project_sql.paes
        WHERE id_etudiant = _etudiant.id_etudiant) IS TRUE THEN

        RAISE 'Impossible de supprimer une ue d''un pae déjà validé';
    END IF;

    SELECT id_ue
    FROM project_sql.ues
    WHERE code_ue = _code_ue
    INTO _ue;

    DELETE
    FROM project_sql.ues_pae
    WHERE id_ue = _ue.id_ue;

    -- La diminution du nombre de crédits total du pae se fait grâce au trigger_diminuer_nombre_de_credits_pae
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------

/**
  Valide le PAE de l'étudiant
 */
CREATE OR REPLACE FUNCTION project_sql.valider_pae(_email VARCHAR(150)) RETURNS VOID AS
$$
DECLARE
    _etudiant RECORD;
    _pae      RECORD;
    _etudiant RECORD;
BEGIN
    SELECT id_etudiant, nombre_de_credits_valides
    FROM project_sql.etudiants
    WHERE email = _email
    INTO _etudiant;

    SELECT code_pae, nombre_de_credits_total
    FROM project_sql.paes
    WHERE id_etudiant = _etudiant.id_etudiant
    INTO _pae;

    -- Verifie que le pae n'est pas déjà validé
    IF (SELECT valide
        FROM project_sql.paes
        WHERE code_pae = _pae.code_pae) IS TRUE THEN
        RAISE 'PAE déjà validé';
    END IF;

    -- Si la somme des crédits précédemment validés et ceux du PAE atteignent 180, le PAE
    -- ne peut pas dépasser 74 crédits
    IF (_etudiant.nombre_de_credits_valides + _pae.nombre_de_credits_total = 180 AND _pae > 74) THEN
        RAISE 'Impossible de valider le pae, il doit y avoir au maximum 74 crédits.';
    END IF;

    -- Si l’étudiant n’a pas validé au moins 45 crédits dans le passé, alors son PAE ne pourra
    -- pas dépasser 60 crédits
    IF (_etudiant.nombre_de_credits_valides < 45 AND _pae.nombre_de_credits_total > 60) THEN
        RAISE 'Impossible de valider le pae, il doit y avoir maximum 60 crédits car tu as validé moins de 46 crédits';
    END IF;

    -- Sinon, le nombre de crédit du PAE devra être entre 55 et 74 crédits
    IF (_pae.nombre_de_credits_total < 55 OR _pae.nombre_de_credits_total > 74) THEN
        RAISE 'Impossible de valider le pae, tu dois avoir entre 55 et 74 crédits dans ton pae.';
    END IF;

    UPDATE project_sql.paes
    SET valide = TRUE
    WHERE code_pae = _pae.code_pae;

    -- Le bloc de l'étudiant est déterminé grâce au trigger_determiner_bloc_etudiant
    -- Le nombre d'inscrit est augmenté de 1 pour chaque ue grâce au trigger_augmenter_nombre_etudiants_inscrits
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------

/**
  Réinitialise le PAE de l'étudiant
 */
CREATE OR REPLACE FUNCTION project_sql.reinitialiser_pae(_email VARCHAR(150)) RETURNS VOID AS
$$
DECLARE
    _etudiant RECORD;
    _pae      RECORD;
BEGIN
    SELECT id_etudiant
    FROM project_sql.etudiants
    WHERE email = _email
    INTO _etudiant;

    IF (SELECT valide
        FROM project_sql.paes
        WHERE id_etudiant = _etudiant.id_etudiant) IS TRUE THEN

        RAISE 'Le pae ne peut pas être réinitialisé car il est déjà validé.';
    END IF;

    -- Mets le code_pae du pae de l'étudiant dans _pae
    SELECT code_pae
    FROM project_sql.paes
    WHERE id_etudiant = _etudiant.id_etudiant
    INTO _pae;

    -- Supprime toutes les ues du pae de l'étudiant
    DELETE
    FROM project_sql.ues_pae
    WHERE code_pae = _pae.code_pae;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------

/**
  Connexion d'un étudiant
 */
CREATE OR REPLACE FUNCTION project_sql.connexion_etudiant(_email VARCHAR(150), _mot_de_passe CHAR(60)) RETURNS INT AS
$$
DECLARE
    _etudiant RECORD;
BEGIN
    SELECT id_etudiant, COUNT(*) AS "count"
    FROM project_sql.etudiants
    WHERE email = _email
      AND mot_de_passe = _mot_de_passe
    GROUP BY id_etudiant
    INTO _etudiant;

    IF _etudiant.count = 0 THEN
        RAISE 'L''émail ou le mot de passe est incorrect';
    END IF;

    --TODO CREATE USER etc
    RETURN _etudiant.id_etudiant;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------------------
----------------------PROCEDURES-WITH-TRIGGER------------------------------
---------------------------------------------------------------------------

/**
  Ajoute un pae à l'étudiant qui vient d'être créé.
  Il n'est pas nécéssaire de vérifier si l'étudiant a déjà un PAE car cette fonction est
  appelée après avoir fait un INSERT pour créer un nouvel étudiant dont l'id est défini en DEFAULT
  (dans notre DB, cet ID est autoincrémenté et ne sera donc jamais le même).
 */
CREATE OR REPLACE FUNCTION project_sql.ajouter_pae() RETURNS TRIGGER AS
$$
DECLARE
    _id_etudiant INT := NEW.id_etudiant;
BEGIN

    INSERT INTO project_sql.paes (id_etudiant)
    VALUES (_id_etudiant);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_ajouter_pae
    AFTER INSERT
    ON project_sql.etudiants
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.ajouter_pae();

/**
  Augmente le nombre de crédits total d'un pae après q'une ue à été ajouté à celui-ci.
 */
CREATE OR REPLACE FUNCTION project_sql.augmenter_nombre_de_credits_pae() RETURNS TRIGGER AS
$$
DECLARE
    _code_pae         INT := NEW.code_pae;
    _id_ue            INT := NEW.id_ue;
    _nombre_credit_ue RECORD;
BEGIN

    --Mets le nombre de crédit de l'ue dans _nombre_credit_ue
    SELECT nombre_de_credits
    FROM project_sql.ues
    WHERE id_ue = _id_ue
    INTO _nombre_credit_ue;

    --Augmente le nombre de credit
    UPDATE project_sql.paes
    SET nombre_de_credits_total = nombre_de_credits_total + _nombre_credit_ue
    WHERE code_pae = _code_pae;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_augmenter_nombre_de_credits_pae
    AFTER INSERT
    ON project_sql.ues_pae
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.augmenter_nombre_de_credits_pae();

---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION project_sql.diminuer_nombre_de_credits_pae() RETURNS TRIGGER AS
$$
DECLARE
    _id_ue             INT := NEW.id_ue;
    _code_pae          INT := NEW.code_pae;
    _nombre_de_credits INT;
BEGIN
    SELECT nombre_de_credits
    FROM project_sql.ues
    WHERE id_ue = _id_ue;

    --Diminue le nombre de crédits dans le pae
    UPDATE project_sql.paes
    SET nombre_de_credits_total = nombre_de_credits_total - _nombre_de_credits
    WHERE code_pae = _code_pae;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_diminuer_nombre_de_credits_pae
    AFTER DELETE
    ON project_sql.ues_pae
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.diminuer_nombre_de_credits_pae();


---------------------------------------------------------------------

/**
  Augmente le nombre d'étudiants inscrits
 */
CREATE OR REPLACE FUNCTION project_sql.augmenter_nombre_etudiants_inscrits() RETURNS TRIGGER AS
$$
DECLARE
    _code_pae INT := NEW.code_pae;
    _id_ue    RECORD;
BEGIN
    FOR _id_ue IN (SELECT id_ue
                   FROM project_sql.ues_pae
                   WHERE code_pae = _code_pae)
        LOOP
            UPDATE project_sql.ues
            SET nombre_d_inscrits = nombre_d_inscrits + 1
            WHERE id_ue = _id_ue;
        END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--TRIGGER
CREATE TRIGGER trigger_augmenter_nombre_etudiants_inscrits
    AFTER UPDATE
        OF valide
    ON project_sql.paes
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.augmenter_nombre_etudiants_inscrits();

---------------------------------------------------------------------

/**
  Augmente le nombre de crédits validés dans la table étudiant après qu'une ue a été validée.
 */
CREATE OR REPLACE FUNCTION project_sql.augmenter_credits_valides() RETURNS TRIGGER AS
$$
DECLARE
    _id_etudiant INT := NEW.id_etudiant;
    _credits_ue  RECORD;
BEGIN
    UPDATE project_sql.etudiants
    SET nombre_de_credits_valides = nombre_de_credits_valides + _credits_ue.nombre_de_credits
    WHERE id_etudiant = _id_etudiant;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_augmenter_credits_valides
    AFTER INSERT
    ON project_sql.ues_validees
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.augmenter_credits_valides();

---------------------------------------------------------------------

/**
  Détermine le bloc de l'étudiant après qu'il ait validé son PAE
 */
CREATE OR REPLACE FUNCTION project_sql.determiner_bloc_etudiant() RETURNS TRIGGER AS
$$
DECLARE
    _id_etudiant                        INT := NEW.id_etudiant;
    _nombre_de_credits_valides_etudiant RECORD ;
    _nombre_de_credits_pae              RECORD ;

BEGIN

    --SELECT des données que l'on stockes dans des variables
    SELECT nombre_de_credits_total
    FROM project_sql.paes
    WHERE id_etudiant = _id_etudiant
    INTO _nombre_de_credits_pae;

    SELECT nombre_de_credits_valides
    FROM project_sql.etudiants
    WHERE id_etudiant = _id_etudiant
    INTO _nombre_de_credits_valides_etudiant;

    --Début des vérifications
    --Mets un etudiant au bloc 3 si la somme de ses crédits en cours et ceux validé sont de 180 ou plus
    IF _nombre_de_credits_valides_etudiant + _nombre_de_credits_pae >= 180 THEN
        UPDATE project_sql.etudiants
        SET bloc = 3
        WHERE id_etudiant = _id_etudiant;

        --Mets l'étudiant en bloc 1 si ses crédits validés sont strictement inférieur à 45
    ELSIF _nombre_de_credits_valides_etudiant < 45 THEN
        UPDATE project_sql.etudiants
        SET bloc = 1
        WHERE id_etudiant = _id_etudiant;

        --Mets l'étudiant en bloc 2 si les 2 conditions ci-dessus n'ont pas été true
    ELSE
        UPDATE project_sql.etudiants
        SET bloc = 2
        WHERE id_etudiant = _id_etudiant;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--TRIGGER
-- Après la validation du pae de l'étudiant
CREATE TRIGGER trigger_determiner_bloc_etudiant
    AFTER UPDATE
        OF valide
    ON project_sql.paes
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.determiner_bloc_etudiant();

---------------------------------------------------------------------

