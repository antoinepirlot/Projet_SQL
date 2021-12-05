/**
 * @Author Pirlot Antoine
 * @Author Dimitriadis Nicolas
 */

import java.sql.*;
import java.util.Scanner;

public class MainCentrale {
    private final Connection CONNEXION = connexionDb();
    private final Scanner SCANNER = new Scanner(System.in);

    public void afficherMenu(){
        System.out.println();
        System.out.println("Que voulez vous faire?");
        System.out.println();

        System.out.println("1 -> Ajouter une ue.");
        System.out.println("2 -> Ajouter un prerequis à une ue existante.");
        System.out.println("3 -> Ajouter un étudiant.");
        System.out.println("4 -> Encoder une ue validée pour un étudiant.");
        System.out.println("5 -> Visualiser tous les étudiants d'un bloc particulier.");
        System.out.println("6 -> Visualiser tous les étudiants et leur nombre de crédits dans le pae.");
        System.out.println("7 -> Visualiser tous les étudiants qui n'ont pas encore validé leur PAE.");
        System.out.println("8 -> Visualiser les UEs d'un bloc en particulier.");
        System.out.println("Autre -> Quitter l'application.");
    }

    public void ajouterUe() {
        System.out.println("Quel est le code de l'ue?");
        String codeUe = SCANNER.nextLine().toUpperCase();

        System.out.println("Quel est le nom de l'ue?");
        String nomUe = SCANNER.nextLine();

        System.out.println("Quel est le numéro du bloc?");
        int bloc = SCANNER.nextInt();
        SCANNER.nextLine();

        System.out.println("Quel est le nombre de crédits pour cette ue?");
        int nombreDeCredits = SCANNER.nextInt();
        SCANNER.nextLine();

        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT project_sql.ajouter_ue(?, ?, ?, ?);");
            ps.setString(1, codeUe);
            ps.setString(2, nomUe);
            ps.setInt(3, bloc);
            ps.setInt(4, nombreDeCredits);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("L'ue a bien été ajoutée.");
                }
            }

        } catch (SQLException e) {
            System.out.println("Erreur lors de l'insertion!");
            System.out.println(e.getMessage());
        }
    }

    public void ajouterPrerequis() {
        System.out.println("Quel est le code de l'ue?");
        String code_ue = SCANNER.nextLine().toUpperCase();

        System.out.println("Quel est le code de l'ue prérequise?");
        String code_ue_prerequise = SCANNER.nextLine().toUpperCase();

        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT project_sql.ajouter_prerequis_ue(?, ?);");
            ps.setString(1, code_ue);
            ps.setString(2, code_ue_prerequise);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("Ajout réussi!");
                }
            }
        } catch (SQLException e) {
            System.out.println("Problème lors de l'insertion.");
            System.out.println(e.getMessage());
        }
    }

    public void ajouterEtudiant() {
        System.out.println("Quel est le nom de l'étudiant?");
        String nomEtudiant = SCANNER.nextLine();

        System.out.println("Quel est le prénom de l'étudiant?");
        String prenomEtudiant = SCANNER.nextLine();

        System.out.println("Quel est l'email de l'étudiant?");
        String emailEtudiant = SCANNER.nextLine();

        System.out.println("Quel est le mot de passe de l'étudiant?");
        String sel = BCrypt.gensalt();
        String motDePassse = BCrypt.hashpw(SCANNER.nextLine(), sel);

        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT project_sql.ajouter_etudiant(?, ?, ?, ?)");
            ps.setString(1, nomEtudiant);
            ps.setString(2, prenomEtudiant);
            ps.setString(3, emailEtudiant);
            ps.setString(4, motDePassse);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("Ajout réussi!");
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    public void encoderUeValidee() {
        System.out.println("Quel est l'email de l'étudiant?");
        String emailEtudiant = SCANNER.nextLine();

        System.out.println("Quel est le code de l'ue a valider?");
        String codeUe = SCANNER.nextLine().toUpperCase();

        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT project_sql.encoder_ue_validee(?, ?);");
            ps.setString(1, emailEtudiant);
            ps.setString(2, codeUe);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("Validation réussie");
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    public void visualiserTousLesEtudiantDUnBloc() {
        int bloc = 0;
        while (bloc < 1 || bloc > 3) {
            System.out.println("De quel bloc voulez vous voir les étudiant?");
            System.out.println("1 -> Bloc 1");
            System.out.println("2 -> Bloc 2");
            System.out.println("3 -> Bloc 3");
            bloc = SCANNER.nextInt();
            SCANNER.nextLine();
        }
        String query;
        try {
            query = "SELECT nom, prenom, nombre_de_credits_valides FROM project_sql.etudiants WHERE \"bloc\" =" + bloc + "";
            Statement statement = CONNEXION.createStatement();
            ResultSet resultSet = statement.executeQuery(query);
            while (resultSet.next()) {
                String nom = resultSet.getString(1);
                String prenom = resultSet.getString(2);
                String nombreDeCredits = resultSet.getString(3);
                System.out.println("Nom: " + nom + ", prénom: " + prenom + ", nombre de crédits validés: " + nombreDeCredits);
            }
        } catch (SQLException e) {
            System.out.println("Problème lors de la demande à la base de données");
            e.printStackTrace();
        }
    }

    public void visualiserTousLesEtudiants() {
        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT * FROM project_sql.visualiser_tous_les_etudiants");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("Nom: " + rs.getString(1) + ", Prénom: " + rs.getString(2) +
                            ", bloc: " + rs.getString(3) + ", nombre de crédits dans le pae: " + rs.getString(4));
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    public void visualiserEtudiantPAENonValide() {
        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT * FROM project_sql.visualiser_etudiant_pae_non_valide");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.print("Nom: " + rs.getString(1) + " ");
                    System.out.print("Prénom: " + rs.getString(2) + " ");
                    System.out.println("Nombre de crédits déjà validés: " + rs.getInt(3) + " ");
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    public void visualiserUEDUnBloc() {
        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT * FROM project_sql.visualier_ue_bloc WHERE \"bloc\" = ?");
            System.out.println("De quel bloc voulez vous voir les ues?");
            int bloc = SCANNER.nextInt();
            SCANNER.nextLine();
            ps.setInt(1, bloc);
            try (ResultSet rs = ps.executeQuery()) {
                boolean uePresentes = false;
                while (rs.next()) {
                    System.out.println("Code de l'ue: " + rs.getString(1) + ", nom de l'ue: " + rs.getString(2) +
                            ", nombre d'inscrits: " + rs.getString(3));
                    uePresentes = true;
                }
                if (!uePresentes)
                    System.out.println("Il n'y a aucune UE pour ce bloc.");
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    private Connection connexionDb() {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgeSQL manquant!");
            System.exit(1);
        }
        String url = "jdbc:postgresql://172.24.2.6:5432/dbantoinepirlot";
        Connection connection = null;
        try {
            connection = DriverManager.getConnection(url, "antoinepirlot", "at5BER69h");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
        return connection;
    }

    public void afficherFin(){
        dexonnexion();
        System.out.println("Fin du programme. Bonne journée.");
        System.out.println();
    }

    private void dexonnexion(){
        try{
            CONNEXION.close();
        } catch (SQLException e) {
            System.out.println("Erreur lors de la fermeture de la connection a la DB.");
            System.out.println(e.getMessage());
        }
    }
}
