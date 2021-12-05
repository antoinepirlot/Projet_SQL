-- Authors: Dimitriadis Nicolas & Pirlot Antoine
DROP SCHEMA IF EXISTS project_sql CASCADE;
CREATE SCHEMA project_sql;

CREATE TABLE project_sql.etudiants
(
    id_etudiant               SERIAL PRIMARY KEY,
    nom                       VARCHAR(100) NOT NULL CHECK ( nom <> '' ),
    prenom                    VARCHAR(100) NOT NULL CHECK ( prenom <> '' ),
    email                     VARCHAR(150) NOT NULL UNIQUE CHECK ( email <> ''),
    mot_de_passe              CHAR(60)     NOT NULL CHECK ( mot_de_passe <> '' ),
    bloc                      INT CHECK ( bloc IS NULL OR bloc IN (1, 2, 3)),
    nombre_de_credits_valides INT          NOT NULL DEFAULT 0 CHECK ( nombre_de_credits_valides >= 0 AND nombre_de_credits_valides <= 180)
);

CREATE TABLE project_sql.ues
(
    id_ue             SERIAL PRIMARY KEY,
    code_ue           VARCHAR(15)  NOT NULL UNIQUE CHECK ( code_ue LIKE 'BINV1%'
        OR code_ue LIKE 'BINV2%'
        OR code_ue LIKE 'BINV3%'),
    nom               VARCHAR(150) NOT NULL,
    bloc              INT          NOT NULL CHECK ((bloc = 1 AND code_ue LIKE 'BINV1%')
        OR (bloc = 2 AND code_ue LIKE 'BINV2%')
        OR (bloc = 3 AND code_ue LIKE 'BINV3%')),
    nombre_de_credits INT          NOT NULL CHECK ( nombre_de_credits > 0 ),
    nombre_d_inscrits INT          NOT NULL DEFAULT 0 CHECK (nombre_d_inscrits >= 0)
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
    id_etudiant             INT     NOT NULL UNIQUE,
    valide                  BOOLEAN NOT NULL DEFAULT FALSE,
    nombre_de_credits_total INT     NOT NULL DEFAULT 0 CHECK (nombre_de_credits_total >= 0 ),
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
-----------------------PROCEDURE-WHITOUT-TRIGGERS--------------------------
---------------------------------------------------------------------------
/**
  Ajoute une ue dans la table ues
  On ne sait pas pourquoi mais il faut relancer le script une deuxième fois à cause du bug:
  unterminated dollar-quoted string at or near "$$[...]" POSITION: 184
 */
CREATE OR REPLACE FUNCTION project_sql.ajouter_ue(_code_ue VARCHAR(15), _nom VARCHAR(150), _bloc INT,
                                                  _nombre_de_credits INT) RETURNS VOID AS
$$
BEGIN
    INSERT INTO project_sql.ues VALUES (DEFAULT, _code_ue, _nom, _bloc, _nombre_de_credits, DEFAULT);
    -- Le bloc est déterminé grâce au trigger_verifier_ue
END;
$$ LANGUAGE plpgsql;

/**
  Ajoute un prérequis à une ue
 */
CREATE OR REPLACE FUNCTION project_sql.ajouter_prerequis_ue(_code_ue VARCHAR(15), _code_ue_prerequise VARCHAR(15)) RETURNS VOID AS
$$
DECLARE
    _ue            RECORD;
    _ue_prerequise RECORD;
BEGIN
    SELECT id_ue
    FROM project_sql.ues
    WHERE code_ue = _code_ue
    INTO _ue;

    SELECT id_ue
    FROM project_sql.ues
    WHERE code_ue = _code_ue_prerequise
    INTO _ue_prerequise;

    INSERT INTO project_sql.prerequis
    VALUES (_ue.id_ue, _ue_prerequise.id_ue);
    -- Vérification si l'ajout peut se faire grâce au trigger_verifier_ajout_prerequis_ue
END;
$$ LANGUAGE plpgsql;

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

/**
  Ajoute une UE validé à la table ue_validees
 */
CREATE OR REPLACE FUNCTION project_sql.encoder_ue_validee(_email VARCHAR(150), _code_ue VARCHAR(15)) RETURNS VOID AS
$$
DECLARE
    _ue       RECORD;
    _etudiant RECORD;
BEGIN
    SELECT id_ue
    FROM project_sql.ues
    WHERE code_ue = _code_ue
    INTO _ue;

    SELECT id_etudiant
    FROM project_sql.etudiants
    WHERE email = _email
    INTO _etudiant;

    INSERT INTO project_sql.ues_validees
    VALUES (_etudiant.id_etudiant, _ue.id_ue);
    -- Les vérifications se font grâce au trigger_augmenter_credits_valides
    -- Le nombre de crédits validés de l'étudiant est augmenté grâce au trigger_augmenter_credits_valides
END;
$$ LANGUAGE plpgsql;

/**
  Ajoute une ue au pae de l'étudiant
 */
CREATE OR REPLACE FUNCTION project_sql.ajouter_ue_pae(_email VARCHAR(150), _code_ue VARCHAR(15)) RETURNS VOID AS
$$
DECLARE
    _pae RECORD;
    _ue  RECORD;
BEGIN
    SELECT p.code_pae
    FROM project_sql.paes p,
         project_sql.etudiants e
    WHERE e.id_etudiant = p.id_etudiant
      AND e.email = _email
    INTO _pae;

    SELECT id_ue
    FROM project_sql.ues
    WHERE code_ue = _code_ue
    INTO _ue;

    INSERT INTO project_sql.ues_pae
    VALUES (_pae.code_pae, _ue.id_ue);
    --L'augmentation du nombre de crédits total du pae se fait grâce au trigger_augmenter_nombre_de_credits_pae
END;
$$ LANGUAGE plpgsql;

/**
  Enlève une UE au PAE de l'étudiant
 */
CREATE OR REPLACE FUNCTION project_sql.enlever_ue_pae(_email VARCHAR(150), _code_ue VARCHAR(15)) RETURNS VOID AS
$$
DECLARE
    _ue  RECORD;
    _pae RECORD;
BEGIN
    SELECT code_pae
    FROM project_sql.etudiants e,
         project_sql.paes p
    WHERE e.id_etudiant = p.id_etudiant
      AND e.email = _email
    INTO _pae;

    SELECT id_ue
    FROM project_sql.ues
    WHERE code_ue = _code_ue
    INTO _ue;
    --Cette vérification ne fonctionne pas dans le trigger
    IF _ue.id_ue NOT IN (SELECT id_ue
                         FROM project_sql.ues_pae
                         WHERE code_pae = _pae.code_pae) THEN
        RAISE 'L''ue n''est pas présente dans le pae.';
    END IF;

    DELETE
    FROM project_sql.ues_pae
    WHERE code_pae = _pae.code_pae
      AND id_ue = _ue.id_ue;
    -- La diminution du nombre de crédits total du pae se fait grâce au trigger_diminuer_nombre_de_credits_pae
END;
$$ LANGUAGE plpgsql;

/**
  Valide le PAE de l'étudiant
 */
CREATE OR REPLACE FUNCTION project_sql.valider_pae(_email VARCHAR(150)) RETURNS VOID AS
$$
DECLARE
    _pae RECORD;
BEGIN
    SELECT code_pae
    FROM project_sql.etudiants e,
         project_sql.paes p
    WHERE e.id_etudiant = p.id_etudiant
      AND e.email = _email
    INTO _pae;

    UPDATE project_sql.paes
    SET valide = TRUE
    WHERE code_pae = _pae.code_pae;
    -- Le bloc de l'étudiant est déterminé grâce au trigger_determiner_bloc_etudiant
    -- Le nombre d'inscrit est augmenté de 1 pour chaque ue grâce au trigger_augmenter_nombre_etudiants_inscrits
END;
$$ LANGUAGE plpgsql;

/**
  Réinitialise le PAE de l'étudiant
 */
CREATE OR REPLACE FUNCTION project_sql.reinitialiser_pae(_email VARCHAR(150)) RETURNS VOID AS
$$
DECLARE
    _pae RECORD;
BEGIN
    SELECT p.code_pae
    FROM project_sql.etudiants e,
         project_sql.paes p
    WHERE e.id_etudiant = p.id_etudiant
      AND e.email = _email
    INTO _pae;

    -- Supprime toutes les ues du pae de l'étudiant
    DELETE
    FROM project_sql.ues_pae
    WHERE code_pae = _pae.code_pae;
    -- Les vérifications se font grâce au trigger_verifier_pae_reinitialisation
END;
$$ LANGUAGE plpgsql;

/**
  Connexion d'un étudiant
 */
CREATE OR REPLACE FUNCTION project_sql.connexion_etudiant(_email VARCHAR(150)) RETURNS SETOF CHAR(60) AS
$$
DECLARE
    _etudiant RECORD;
BEGIN
    IF NOT EXISTS(SELECT id_etudiant
                  FROM project_sql.etudiants
                  WHERE email = _email) THEN
        RAISE 'L''étudiant n''existe pas' ;
    END IF;

    SELECT id_etudiant, COUNT(*) AS "count"
    FROM project_sql.etudiants
    WHERE email = _email
    GROUP BY id_etudiant
    INTO _etudiant;

    IF _etudiant.count = 0 THEN
        RAISE 'L''émail ou le mot de passe est incorrect';
    END IF;

    RETURN QUERY
        SELECT mot_de_passe
        FROM project_sql.etudiants e
        WHERE e.email = _email;
END;
$$ LANGUAGE plpgsql;

/**
  Vérifie que les ues prérequises ont été vzalidé,
  renvoie true si c'est le cas, false sinon.
 */
CREATE OR REPLACE FUNCTION project_sql.a_valider_les_ues_prerequises(_id_ue INT, _id_etudiant INT) RETURNS BOOLEAN AS
$$
DECLARE
    _ue_prerequise RECORD;
BEGIN
    FOR _ue_prerequise IN (SELECT id_ue_prerequise
                           FROM project_sql.prerequis
                           WHERE id_ue = _id_ue)
        LOOP
            IF _ue_prerequise.id_ue_prerequise NOT IN (SELECT id_ue
                                                       FROM project_sql.ues_validees
                                                       WHERE id_etudiant = _id_etudiant) THEN
                RETURN FALSE;
            END IF;
        END LOOP;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------------
-----------------------PROCEDURES-WITH-TRIGGERS----------------------------
---------------------------------------------------------------------------
/**
  Ajoute un pae à l'étudiant qui vient d'être créé.
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
  Vérifie que l'ue prerequise peut être ajoutée.
 */
CREATE OR REPLACE FUNCTION project_sql.verifier_ajout_prerequis_ue() RETURNS TRIGGER AS
$$
DECLARE
    _ue            RECORD;
    _ue_prerequise RECORD;
BEGIN
    SELECT bloc
    FROM project_sql.ues
    WHERE ues.id_ue = NEW.id_ue
    INTO _ue;

    SELECT bloc
    FROM project_sql.ues
    WHERE id_ue = NEW.id_ue_prerequise
    INTO _ue_prerequise;

    IF _ue_prerequise.bloc > _ue.bloc THEN
        RAISE 'Le bloc du prérequis est supérieur au bloc de cette ue.';
    END IF;

    IF _ue_prerequise.bloc = _ue.bloc THEN
        RAISE 'Le bloc du prérequis est égal au bloc de cette ue.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verifier_ajout_prerequis_ue
    BEFORE INSERT
    ON project_sql.prerequis
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.verifier_ajout_prerequis_ue();

/**
  Augmente le nombre de crédits total d'un pae après q'une ue à été ajouté à celui-ci.
 */
CREATE OR REPLACE FUNCTION project_sql.augmenter_nombre_de_credits_pae() RETURNS TRIGGER AS
$$
DECLARE
    _etudiant_et_pae RECORD;
    _ue              RECORD;
    _ue_prerequise   RECORD;
BEGIN
    SELECT p.id_etudiant, p.valide, e.nombre_de_credits_valides
    FROM project_sql.paes p,
         project_sql.etudiants e
    WHERE p.id_etudiant = e.id_etudiant
      AND p.code_pae = NEW.code_pae
    INTO _etudiant_et_pae;

    SELECT id_ue, bloc, nombre_de_credits
    FROM project_sql.ues
    WHERE ues.id_ue = NEW.id_ue
    INTO _ue;

    -- Si le PAE est déjà validé
    IF _etudiant_et_pae.valide IS TRUE THEN
        RAISE 'Ce PAE a déjà été validé, il est impossible d''ajouter une ue.';
    END IF;

    -- Si l’étudiant a déjà validé cette UE précédemment
    IF (SELECT COUNT(*)
        FROM project_sql.ues_validees
        WHERE id_ue = _ue.id_ue
          AND id_etudiant = _etudiant_et_pae.id_etudiant) <> 0 THEN

        RAISE 'Cette ue a déjà été validée par l''étudiant';
    END IF;

    -- Si l’étudiant a validé moins de 45 ects et que l’UE n’est pas du bloc 1
    IF _etudiant_et_pae.nombre_de_credits_valides < 30 AND _ue.bloc != 1 THEN
        RAISE 'L''étudiant a validé moins de 30 crédits et cette ue ne figure pas au bloc 1.';
    END IF;

    -- Si l’étudiant n’a pas validé tous les prérequis de cette UE
    -- Avec les vérifications de la fonction encoder_ue_validee, il est impossible que le prérequis ai été validé sans
    -- sans son prérequis.
    FOR _ue_prerequise IN (SELECT id_ue_prerequise
                           FROM project_sql.prerequis
                           WHERE id_ue = _ue.id_ue) LOOP
            IF (SELECT COUNT(*)
                FROM project_sql.ues_validees
                WHERE id_ue = _ue_prerequise.id_ue_prerequise
                  AND id_etudiant = _etudiant_et_pae.id_etudiant) = 0 THEN
                RAISE 'L''étudiant n''a pas validé une ue prérequise.';
            END IF;
    END LOOP;

    --Augmente le nombre de credit
    UPDATE project_sql.paes
    SET nombre_de_credits_total = nombre_de_credits_total + _ue.nombre_de_credits
    WHERE code_pae = NEW.code_pae;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_augmenter_nombre_de_credits_pae
    BEFORE INSERT
    ON project_sql.ues_pae
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.augmenter_nombre_de_credits_pae();

/**
  Diminue le nombre de credits du pae lors de la suppression d'une ue dans le pae
 */
CREATE OR REPLACE FUNCTION project_sql.diminuer_nombre_de_credits_pae() RETURNS TRIGGER AS
$$
DECLARE
    _ue  RECORD;
    _pae RECORD;
BEGIN
    SELECT p.valide
    FROM project_sql.paes p,
         project_sql.etudiants e
    WHERE p.id_etudiant = e.id_etudiant
      AND p.code_pae = OLD.code_pae
    INTO _pae;

    IF _pae.valide IS TRUE THEN
        RAISE 'Impossible de supprimer une ue d''un pae déjà validé';
    END IF;

    SELECT nombre_de_credits
    FROM project_sql.ues ue
    WHERE id_ue = OLD.id_ue
    INTO _ue;

    --Diminue le nombre de crédits dans le pae
    UPDATE project_sql.paes
    SET nombre_de_credits_total = nombre_de_credits_total - _ue.nombre_de_credits
    WHERE code_pae = OLD.code_pae;
    RETURN OLD;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_diminuer_nombre_de_credits_pae
    BEFORE DELETE
    ON project_sql.ues_pae
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.diminuer_nombre_de_credits_pae();

/**
  Augmente le nombre d'étudiants inscrits
 */
CREATE OR REPLACE FUNCTION project_sql.augmenter_nombre_etudiants_inscrits() RETURNS TRIGGER AS
$$
DECLARE
    _ue RECORD;
BEGIN
    FOR _ue IN (SELECT id_ue
                FROM project_sql.ues_pae
                WHERE code_pae = NEW.code_pae) LOOP
            UPDATE project_sql.ues
            SET nombre_d_inscrits = nombre_d_inscrits + 1
            WHERE id_ue = _ue.id_ue;
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

/**
  Augmente le nombre de crédits validés dans la table étudiant après qu'une ue a été validée.
 */
CREATE OR REPLACE FUNCTION project_sql.augmenter_credits_valides() RETURNS TRIGGER AS
$$
DECLARE
    _ue            RECORD;
    _ue_prerequise RECORD;
    _etudiant      RECORD;
BEGIN
    SELECT id_ue,
           nombre_de_credits,
           bloc
    FROM project_sql.ues
    WHERE id_ue = NEW.id_ue
    INTO _ue;

    SELECT id_ue_prerequise,
           COUNT(*) AS "nombre_de_prerequis"
    FROM project_sql.prerequis
    WHERE id_ue = NEW.id_ue
    GROUP BY id_ue_prerequise
    INTO _ue_prerequise;

    SELECT nombre_de_credits_valides
    FROM project_sql.etudiants
    WHERE id_etudiant = NEW.id_etudiant
    INTO _etudiant;

    -- Si il y a une ue prérequise et qu'elle n'est pas validée, alors on ne peut pas valider cette ue.
    IF _ue_prerequise.nombre_de_prerequis <> 0
        AND (SELECT COUNT(*)
             FROM project_sql.ues_validees
             WHERE id_ue = _ue_prerequise.id_ue_prerequise
               AND id_etudiant = NEW.id_etudiant) = 0 THEN

        RAISE 'L''étudiant n''a pas validé le prérequis de ce cours.';
    END IF;

    IF _etudiant.nombre_de_credits_valides < 30 AND _ue.bloc <> 1 THEN
        RAISE 'L''étudiant n''a pas validé assez de crédit';
    END IF;

    UPDATE project_sql.etudiants
    SET nombre_de_credits_valides = nombre_de_credits_valides + _ue.nombre_de_credits
    WHERE id_etudiant = NEW.id_etudiant;
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_augmenter_credits_valides
    AFTER INSERT
    ON project_sql.ues_validees
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.augmenter_credits_valides();

/**
  Détermine le bloc de l'étudiant après qu'il ait validé son PAE
 */
CREATE OR REPLACE FUNCTION project_sql.determiner_bloc_etudiant() RETURNS TRIGGER AS
$$
DECLARE
    _etudiant_et_pae RECORD ;

BEGIN
    --SELECT des données que l'on stockes dans des variables
    SELECT p.id_etudiant,
           p.nombre_de_credits_total,
           e.nombre_de_credits_valides,
           e.bloc
    FROM project_sql.etudiants e,
         project_sql.paes p
    WHERE e.id_etudiant = p.id_etudiant
      AND e.id_etudiant = NEW.id_etudiant
    INTO _etudiant_et_pae;

    --Mets l'étudiant en bloc 1 si ses crédits validés sont strictement inférieur à 45
    IF _etudiant_et_pae.nombre_de_credits_valides < 45 THEN
        UPDATE project_sql.etudiants
        SET bloc = 1
        WHERE id_etudiant = _etudiant_et_pae.id_etudiant;

        --Mets un etudiant au bloc 3 si la somme de ses crédits en cours et ceux validé sont de 180 ou plus
    ELSIF _etudiant_et_pae.nombre_de_credits_total + _etudiant_et_pae.nombre_de_credits_valides >= 180 THEN
        UPDATE project_sql.etudiants
        SET bloc = 3
        WHERE id_etudiant = _etudiant_et_pae.id_etudiant;

        --Mets l'étudiant en bloc 2 si les 2 conditions ci-dessus n'ont pas été true
    ELSE
        UPDATE project_sql.etudiants
        SET bloc = 2
        WHERE id_etudiant = _etudiant_et_pae.id_etudiant;
    END IF;
    -- La vérification des crédits dans le pae se fait grâce au trigger_verifier_bloc_validation
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--TRIGGER
-- Après la validation du pae de l'étudiant
CREATE TRIGGER trigger_determiner_bloc_etudiant
    BEFORE UPDATE
        OF valide
    ON project_sql.paes
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.determiner_bloc_etudiant();

/**
  Vérifie que les crédits du pae de l'étudiant sont suffisant
 */
CREATE OR REPLACE FUNCTION project_sql.verifier_bloc_validation() RETURNS TRIGGER AS
$$
DECLARE
    _etudiant_et_pae RECORD;
BEGIN

    SELECT p.nombre_de_credits_total,
           p.valide,
           e.nombre_de_credits_valides,
           e.bloc
    FROM project_sql.etudiants e,
         project_sql.paes p
    WHERE e.id_etudiant = p.id_etudiant
      AND e.id_etudiant = NEW.id_etudiant
    INTO _etudiant_et_pae;

    -- Verifie que le pae n'est pas déjà validé
    IF _etudiant_et_pae.valide IS TRUE THEN
        RAISE 'PAE déjà validé';
    END IF;

    -- Vérifie que l'étudiant n'a pas validé un pae vide
    IF _etudiant_et_pae.nombre_de_credits_total = 0 THEN
        RAISE 'Ton PAE ne peut pas être vide.';
    END IF;

    -- Si l’étudiant n’a pas validé au moins 45 crédits dans le passé, alors son PAE ne pourra
    -- pas dépasser 60 crédits
    IF _etudiant_et_pae.nombre_de_credits_valides < 45 AND _etudiant_et_pae.nombre_de_credits_total > 60 THEN
        RAISE 'Ton pae ne peut pas avoir plus de 60 crédits car tu as validés moins de 45 crédits.';
    END IF;

    -- Si l'étudiant est en bloc 2, le nombre de crédit du PAE devra être entre 55 et 74 crédits
    IF (_etudiant_et_pae.nombre_de_credits_total < 55 OR _etudiant_et_pae.nombre_de_credits_total > 74)
        AND _etudiant_et_pae.bloc = 2 THEN
        RAISE 'Impossible de valider le pae, tu dois avoir entre 55 et 74 crédits dans ton pae.';
    END IF;

    -- Si la somme des crédits précédemment validés et ceux du PAE atteignent 180, le PAE
    -- ne peut pas dépasser 74 crédits
    IF (_etudiant_et_pae.nombre_de_credits_valides + _etudiant_et_pae.nombre_de_credits_total = 180 AND
        _etudiant_et_pae.nombre_de_credits_total > 74) THEN
        RAISE 'Impossible de valider le pae, il doit y avoir au maximum 74 crédits.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verifier_bloc_validation
    AFTER UPDATE
        OF bloc
    ON project_sql.etudiants
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.verifier_bloc_validation();

/**
  Vérifie que le pae peut être réinitialisé
 */
CREATE OR REPLACE FUNCTION project_sql.verifier_pae_reinitialisation() RETURNS TRIGGER AS
$$
DECLARE
    _pae RECORD;
BEGIN
    SELECT valide
    FROM project_sql.paes
    WHERE code_pae = OLD.code_pae
    INTO _pae;

    IF _pae.valide IS TRUE THEN
        RAISE 'Le pae ne peut pas être réinitialisé car il est déjà validé.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_verifier_pae_reinitialisation
    BEFORE DELETE
    ON project_sql.ues_pae
    FOR EACH ROW
EXECUTE PROCEDURE project_sql.verifier_pae_reinitialisation();
---------------------------------------------------------------------------
-------------------------------VIEWS---------------------------------------
---------------------------------------------------------------------------
/**
  Visualise les étudiants avec le bloc
 */
CREATE OR REPLACE VIEW project_sql.visualiser_tous_les_etudiants_bloc AS
SELECT DISTINCT nom                       AS "nom",
                prenom                    AS "prenom",
                nombre_de_credits_valides AS "nombre_de_credits_valides",
                bloc                      AS "bloc"
FROM project_sql.etudiants;

/**
  Visualise les ues qui sont dans le pae de l'étudiant
 */
CREATE OR REPLACE VIEW project_sql.visualiser_pae as
SELECT DISTINCT ue.code_ue           AS "code_ue",
                ue.nom               AS "nom",
                ue.nombre_de_credits AS "nombre_de_credits",
                ue.bloc              AS "bloc",
                e.email              AS "email"
FROM project_sql.ues ue,
     project_sql.etudiants e,
     project_sql.paes pae,
     project_sql.ues_pae ue_pae
WHERE pae.id_etudiant = e.id_etudiant
  AND ue_pae.code_pae = pae.code_pae
  AND ue.id_ue = ue_pae.id_ue
ORDER BY ue.code_ue;

/**
  Visualise les étudiants qui n'ont pas encore validés leur pae
 */
CREATE OR REPLACE VIEW project_sql.visualiser_etudiant_pae_non_valide AS
SELECT DISTINCT e.nom                       AS "nom",
                e.prenom                    AS "prenom",
                e.nombre_de_credits_valides AS "Nombre de credits valide"
FROM project_sql.etudiants e,
     project_sql.paes p
WHERE e.id_etudiant = p.id_etudiant
  AND p.valide IS FALSE;

/**
  Visualise les ues que l'étudiant peut ajouter à son pae
 */
CREATE OR REPLACE VIEW project_sql.visualiser_ue_disponible_pae AS
SELECT ue.code_ue           AS "code_ue",
       ue.nom               AS "nom",
       ue.nombre_de_credits AS "nombre_de_credits",
       ue.bloc              AS "bloc",
       e.email              AS "email"
FROM project_sql.etudiants e,
     project_sql.paes p,
     project_sql.ues ue
WHERE p.id_etudiant = e.id_etudiant
  AND p.valide IS FALSE
  AND (ue.id_ue NOT IN (SELECT up.id_ue
                        FROM project_sql.ues_pae up,
                             project_sql.paes p
                        WHERE up.code_pae = p.code_pae
                          AND p.id_etudiant = e.id_etudiant)
    AND ue.id_ue NOT IN (SELECT uv.id_ue
                         FROM project_sql.ues_validees uv
                         WHERE uv.id_etudiant = e.id_etudiant))
  AND ((e.nombre_de_credits_valides >= 30 AND project_sql.a_valider_les_ues_prerequises(ue.id_ue, e.id_etudiant))
    OR (e.nombre_de_credits_valides < 30 AND ue.bloc = 1));

/**
  Visualise les ue par bloc
 */
CREATE OR REPLACE VIEW project_sql.visualier_ue_bloc AS
SELECT code_ue           AS "code_ue",
       nom               AS "nom",
       nombre_d_inscrits AS "nombre_inscrits",
       bloc              AS "bloc"
FROM project_sql.ues
ORDER BY nombre_d_inscrits;

/**
  Visualise tous les étudiants
 */
CREATE OR REPLACE VIEW project_sql.visualiser_tous_les_etudiants AS
SELECT DISTINCT e.nom                     AS "nom",
                e.prenom                  AS "prenom",
                e.bloc,
                p.nombre_de_credits_total AS "nombre_de_credits_pae"
FROM project_sql.etudiants e,
     project_sql.paes p
WHERE e.id_etudiant = p.id_etudiant
ORDER BY p.nombre_de_credits_total;
---------------------------------------------------------------------------
-------------------------------GRANTS--------------------------------------
---------------------------------------------------------------------------
GRANT CONNECT ON DATABASE
    dbantoinepirlot TO nicolasdimitriadis;

GRANT USAGE ON SCHEMA
    project_sql TO nicolasdimitriadis;

GRANT SELECT ON TABLE
    project_sql.etudiants,
    project_sql.ues,
    project_sql.ues_pae,
    project_sql.paes,
    project_sql.ues_validees,
    project_sql.prerequis,
    project_sql.visualiser_pae,
    project_sql.visualiser_ue_disponible_pae TO nicolasdimitriadis;

GRANT INSERT ON TABLE
    project_sql.ues_pae TO nicolasdimitriadis;

GRANT UPDATE ON TABLE
    project_sql.ues,
    project_sql.paes,
    project_sql.etudiants TO nicolasdimitriadis;

GRANT DELETE ON TABLE
    project_sql.ues_pae TO nicolasdimitriadis;