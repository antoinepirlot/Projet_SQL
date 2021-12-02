import com.berry.BCrypt;

import javax.swing.plaf.nimbus.State;
import java.sql.*;
import java.util.Scanner;

public class Main {

    private static final Scanner scanner = new Scanner(System.in);
    private static final Connection connexion = connexionDb();

    public static void main(String[] args) {
        System.out.println("Bienvenue dans l'application centrale dédiée aux administrateurs.");

        /*String pseudo, mdp;
        System.out.println("Quel est ton mot de passe?");
        String sel = BCrypt.gensalt();
        mdp = BCrypt.hashpw(scanner.next(), sel);*/

        int choix;
        do {
            System.out.println();
            System.out.println("Que voulez vous faire?");
            System.out.println();

            System.out.println("1 -> Ajouter une ue");
            System.out.println("2 -> Ajouter un prerequis à une ue existante");
            System.out.println("3 -> Ajouter un étudiant");
            System.out.println("4 -> Encoder une ue validée pour un étudiant");
            System.out.println("5 -> Visualiser tous les étudiants d'un bloc particulier");
            System.out.println("6 -> Visualiser tous les étudiants");
            System.out.println("7 -> Visualiser tous les étudiants qui n'ont pas encore validé leur PAE");
            System.out.println("8 -> Visualiser les UEs d'un bloc en particulier");

            choix = scanner.nextInt();
            switch (choix) {
                case 1:
                    ajouterUe();
                    break;
                case 2:
                    ajouterPrerequis();
                    break;
                case 3:
                    ajouterEtudiant();
                    break;
                case 4:
                    encoderUeValidee();
                    break;
                case 5:
                    visualiserTousLesEtudiantDUnBloc();
                    break;
                case 6:
                    visualiserTout();
                    break;
                case 7:
                    visualiserEtudiantPAENonValide();
                    break;
                case 8:
                    visualiserUEDUnBloc();
                    break;
                default:
                    System.out.println("Fin du programme. Bonne journée.");
                    System.out.println();
                    break;
            }
        } while (1 <= choix && choix <= 8);
    }

    public static void ajouterUe() {
        System.out.println("Quel est le code de l'ue?");
        String codeUe = scanner.next();

        System.out.println("Quel est le nom de l'ue?");
        String nomUe = scanner.next();

        System.out.println("Quel est le bloc de l'ue?");
        int bloc = scanner.nextInt();

        System.out.println("Quel est le nombre de crédits pour cette ue?");
        int nombreDeCredits = scanner.nextInt();

        try {
            PreparedStatement ps = connexion.prepareStatement("SELECT project_sql.ajouter_ue(?, ?, ?);");
            ps.setString(1, codeUe);
            ps.setString(2, nomUe);
            ps.setInt(3, nombreDeCredits);
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

    public static void ajouterPrerequis() {
        System.out.println("Quel est le code de l'ue?");
        String code_ue = scanner.next();

        System.out.println("Quel est le code de l'ue prérequise?");
        String code_ue_prerequise = scanner.next();

        try {
            PreparedStatement ps = connexion.prepareStatement("SELECT project_sql.ajouter_prerequis_ue(?, ?);");
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

    public static void ajouterEtudiant() {
        System.out.println("Quel est le nom de l'étudiant?");
        String nomEtudiant = scanner.next();

        System.out.println("Quel est le prénom de l'étudiant?");
        String prenomEtudiant = scanner.next();

        System.out.println("Quel est l'email de l'étudiant?");
        String emailEtudiant = scanner.next();

        System.out.println("Quel est le mot de passe de l'étudiant?");
        String sel = BCrypt.gensalt();
        String motDePassse = BCrypt.hashpw(scanner.next(), sel);

        try {
            PreparedStatement ps = connexion.prepareStatement("SELECT project_sql.ajouter_etudiant(?, ?, ?, ?)");
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

    public static void encoderUeValidee() {
        System.out.println("Quel est l'email de l'étudiant?");
        String emailEtudiant = scanner.next();

        System.out.println("Quel est le code de l'ue a valider?");
        String codeUe = scanner.next();

        try {
            PreparedStatement ps = connexion.prepareStatement("SELECT project_sql.encoder_ue_validee(?, ?);");
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

    public static void visualiserTousLesEtudiantDUnBloc() {
        int bloc = -1;
        while (bloc < 0 || bloc > 3) {
            System.out.println("De quel bloc voulez vous voir les étudiant?");
            System.out.println("0 -> Bloc indéterminé");
            System.out.println("1 -> Bloc 1");
            System.out.println("2 -> Bloc 2");
            System.out.println("3 -> Bloc 3");
            bloc = scanner.nextInt();
        }
        String query;
        try {
            if (bloc == 0)
                query = """
                        SELECT nom, prenom, nombre_de_credits_valides FROM project_sql.etudiants WHERE "bloc" IS NULL
                        """;
            else
                query = "SELECT nom, prenom, nombre_de_credits_valides FROM project_sql.etudiants WHERE \"bloc\" =" + bloc + "";
            Statement statement = connexion.createStatement();
            ResultSet resultSet = statement.executeQuery(query);
            while (resultSet.next()) {
                String nom = resultSet.getString(1);
                String prenom = resultSet.getString(2);
                String nombreDeCredits = resultSet.getString(3);
                System.out.println(nom + ", " + prenom + ", " + nombreDeCredits);
            }
        } catch (SQLException e) {
            System.out.println("Problème lors de la demande à la base de données");
            e.printStackTrace();
        }
    }

    public static void visualiserTout() {
        //TODO � voir si le nom doit changer ou pas (de la fonction)
    }

    public static void visualiserEtudiantPAENonValide() {
        try {
            PreparedStatement ps = connexion.prepareStatement("SELECT * FROM project_sql.visualiser_etudiant_pae_non_valide");
            try (ResultSet rs = ps.executeQuery()){
                while (rs.next()){
                    System.out.print("Nom: " + rs.getString(1) + " ");
                    System.out.print("Prénom: " + rs.getString(2) + " ");
                    System.out.print("Nombre de crédits déjà validés: " + rs.getInt(3) + " ");
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    public static void visualiserUEDUnBloc() {
        try{
            PreparedStatement ps = connexion.prepareStatement("SELECT * FROM project_sql.visualier_ue_bloc WHERE \"bloc\" = ?");
            System.out.println("De quel bloc voulez vous voir les ues?");
            int bloc = scanner.nextInt();
            ps.setInt(1, bloc);
            try (ResultSet rs = ps.executeQuery()){
                if(!rs.next())
                    System.out.println("Il n'y a pas d'ue pour ce bloc.");
                while (rs.next()){
                    System.out.println("Code de l'ue: "+ rs.getString(1) + ", nom de l'ue: " + rs.getString(2) +
                            ", nombre d'inscrits: " + rs.getString(3));
                }
            }
        } catch (SQLException e){
            System.out.println(e.getMessage());
        }
    }

    private static Connection connexionDb() {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgeSQL manquant!");
            System.exit(1);
        }

        String url = "jdbc:postgresql://127.0.0.1:5432/postgres";
        Connection connection = null;
        try {
            connection = DriverManager.getConnection(url, "postgres", "06192000");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
        return connection;
    }
}
