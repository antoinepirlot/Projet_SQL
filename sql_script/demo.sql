-- ETUDIANTS
INSERT INTO project_sql.etudiants (nom, prenom, email, mot_de_passe) VALUES ('Damas', 'Damas', 'damas@vinci.be', '$2a$10$1.C7UEpy5qhqzmmpbmFYaOMA21DbmdQ5rQxPQtlomc7yGn1GnF816');
INSERT INTO project_sql.etudiants (nom, prenom, email, mot_de_passe) VALUES ('Ferneeuw', 'Ferneeuw', 'ferneeuw@vinci.be', '$2a$10$smbMKwJKi0o4E6dlBlCXRevfJw6DprX/2w7geedsVdStHWjsYRev2');
INSERT INTO project_sql.etudiants (nom, prenom, email, mot_de_passe) VALUES ('Vander Meulen', 'Vander Meulen', 'vandermeulen@vinci.be', '$2a$10$y9OLSkOnfHhCduS/8PvZU.vJYoHQG5iJvExQQPgy1bGf4G.DeApj.');
INSERT INTO project_sql.etudiants (nom, prenom, email, mot_de_passe) VALUES ('Leconte', 'Leconte', 'leconte@vinci.be', '$2a$10$.pchNhK2q5nLm0KqnL1TX.lZTZzSn8IRRbtaFq1QgvCnLJE0oR5a.');

-- UES
INSERT INTO project_sql.ues (code_ue, nom, bloc, nombre_de_credits) VALUES ('BINV11', 'BD1', 1, 31);
INSERT INTO project_sql.ues (code_ue, nom, bloc, nombre_de_credits) VALUES ('BINV12', 'APOO', 1, 16);
INSERT INTO project_sql.ues (code_ue, nom, bloc, nombre_de_credits) VALUES ('BINV13', 'Algo', 1, 13);
INSERT INTO project_sql.ues (code_ue, nom, bloc, nombre_de_credits) VALUES ('BINV21', 'BD2', 2, 42);
INSERT INTO project_sql.ues (code_ue, nom, bloc, nombre_de_credits) VALUES ('BINV311', 'Anglais', 3, 16);
INSERT INTO project_sql.ues (code_ue, nom, bloc, nombre_de_credits) VALUES ('BINV32', 'Stage', 3, 44);

-- PREREQUIS
INSERT INTO project_sql.prerequis (id_ue, id_ue_prerequise) VALUES (4, 1);
INSERT INTO project_sql.prerequis (id_ue, id_ue_prerequise) VALUES (6, 4);

-- UES VALIDEES
INSERT INTO project_sql.ues_validees (id_etudiant, id_ue) VALUES (1, 2);
INSERT INTO project_sql.ues_validees (id_etudiant, id_ue) VALUES (1, 3);
INSERT INTO project_sql.ues_validees (id_etudiant, id_ue) VALUES (2, 1);
INSERT INTO project_sql.ues_validees (id_etudiant, id_ue) VALUES (2, 2);
INSERT INTO project_sql.ues_validees (id_etudiant, id_ue) VALUES (3, 1);
INSERT INTO project_sql.ues_validees (id_etudiant, id_ue) VALUES (3, 2);
INSERT INTO project_sql.ues_validees (id_etudiant, id_ue) VALUES (3, 3);
INSERT INTO project_sql.ues_validees (id_etudiant, id_ue) VALUES (4, 1);
INSERT INTO project_sql.ues_validees (id_etudiant, id_ue) VALUES (4, 2);
INSERT INTO project_sql.ues_validees (id_etudiant, id_ue) VALUES (4, 3);
INSERT INTO project_sql.ues_validees (id_etudiant, id_ue) VALUES (4, 4);
INSERT INTO project_sql.ues_validees (id_etudiant, id_ue) VALUES (4, 6);



INSERT INTO project_sql.etudiants (id_etudiant, nom, prenom, email, mot_de_passe, bloc, nombre_de_credits_valides) VALUES (DEFAULT, 'Pirlot', 'Antoine', 'antoine@vinci.be', '$2a$10$X3O5cj8RU.tLPgCgKAQwP.bmo0LSHoIBhp4PeSiTjj6DSkzik2u0u', DEFAULT, DEFAULT);
INSERT INTO project_sql.etudiants (id_etudiant, nom, prenom, email, mot_de_passe, bloc, nombre_de_credits_valides) VALUES (DEFAULT, 'Vogel', 'Anouck', 'anouck@ecole.be', '$2a$10$hkeGjz2tqJb4bhq0Izw9PepinBm0gMuqCxQHUHCO8iKndaF581OVS', DEFAULT, DEFAULT);
INSERT INTO project_sql.etudiants (id_etudiant, nom, prenom, email, mot_de_passe, bloc, nombre_de_credits_valides) VALUES (DEFAULT, 'Kamerling', 'Hugo', 'hugo@ecole.be', '$2a$10$IaRF3Hkmgoox8C1Fknx6NeoI2YTy1XWIPhK6Ujjmo29Xk6CQ/gClO', DEFAULT, DEFAULT);
INSERT INTO project_sql.etudiants (id_etudiant, nom, prenom, email, mot_de_passe, bloc, nombre_de_credits_valides) VALUES (DEFAULT, 'Vermeich', 'Lisa', 'lisa@ecole.be', '$2a$10$qnPOFtqyKk6tmNn8izLmz.Uqo1YthOd87o.7to7tcgPbsv2A3kvlK', DEFAULT, DEFAULT);
INSERT INTO project_sql.etudiants (id_etudiant, nom, prenom, email, mot_de_passe, bloc, nombre_de_credits_valides) VALUES (DEFAULT, 'Jordan', 'Alexander', 'alexander@ecole.be', '$2a$10$./DB3hMrmTdaBFEMSi9ICucHNzgwMd1E4CmEWApnuezg24mBFv70W', DEFAULT, DEFAULT);
INSERT INTO project_sql.etudiants (id_etudiant, nom, prenom, email, mot_de_passe, bloc, nombre_de_credits_valides) VALUES (DEFAULT, 'Lorie', 'Maude', 'maude@ecole.be', '$2a$10$9g/Xh7zU2daUIUvbJInS4.1AYq512oMaez2Ox0kRNqh7e04cBzJh.', DEFAULT, DEFAULT);

