import com.berry.BCrypt;

import java.io.FileInputStream;
import java.sql.*;
import java.util.Properties;
import java.util.Scanner;


public class Main {

    private static final Scanner scanner = new Scanner(System.in);

    public static void main(String[] args) throws Exception {

        //Chargement des variables du fichier conf.properties
        Properties props = new Properties();
        try (FileInputStream fis = new FileInputStream("C:\\Users\\dimit\\IdeaProjects\\Projet_SQL\\Application-Etudiant\\model\\conf.properties")){
            props.load(fis);
        }
        String classe = props.getProperty("jdbc.driver.class");
        String url = props.getProperty("jdbc.url");
        String login = props.getProperty("jdbc.login");
        String password = props.getProperty("jdbc.password");

        //Forcer le chargement du Driver � l'ex�cution
        try {
            Class.forName(classe);
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant");
            System.exit(1);
        }

        //Obtenir une connexion
        Connection conn = null;

        try {
            conn= DriverManager.getConnection(url, login, password);
        } catch ( SQLException e) {
            System.out.println("Impossible de joindre le server");
            System.exit(1);
        }


        System.out.println("Bienvenue dans l'application d�di�es aux �tudiants.");
        System.out.println();

        int choix;

        //Connexion de l'�tudiant
        System.out.println("Veuillez introduire votre adresse email : ");
        String emailEtudiant = scanner.next();
        System.out.println("Veuillez introduire votre mot de passe : ");
        String passwordEtudiant = scanner.next();

       boolean connexion_etudiant = connexion_etudiant(conn, emailEtudiant, passwordEtudiant);
       while (connexion_etudiant == false){
           System.out.println("Veuillez introduire votre adresse email : ");
           emailEtudiant = scanner.next();
           System.out.println("Veuillez introduire votre mot de passe : ");
           passwordEtudiant = scanner.next();
           connexion_etudiant = connexion_etudiant(conn, emailEtudiant, passwordEtudiant);
       }

        /*
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM project_sql.connexion_etudiant(?)");
            ps.setString(1, emailEtudiant);
            //ps.setString(2, passwordEtudiant);
            //ps.executeUpdate();
            try (ResultSet rs = ps.executeQuery()){
                while (rs.next()){
                    String passwordHash = rs.getString(1);
                    if (!com.berry.BCrypt.checkpw(passwordEtudiant, passwordHash)){
                        // TODO
                        System.out.println("Le mot de passe ou l'email est faux");

                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        */

        do{
            System.out.println("Que voulez vous faire?");
            System.out.println();

            System.out.println("1 -> Ajouter une UE au PAE");
            System.out.println("2 -> Enlever une UE du PAE");
            System.out.println("3 -> Valider le PAE");
            System.out.println("4 -> Afficher les UE autoris�es � l'ajout");
            System.out.println("5 -> Visualiser le PAE");
            System.out.println("6 -> R�initialiser le PAE");

            choix = scanner.nextInt();
            switch (choix) {
                case 1:
                    ajouterUePae(conn, emailEtudiant);
                    break;
                case 2:
                    enleverUePae(conn, emailEtudiant);
                    break;
                case 3:
                    validerPae(conn, emailEtudiant);
                    break;
                case 4:
                    afficherUesAutorisees(conn, emailEtudiant);
                    break;
                case 5:
                    visualiserPae(conn, emailEtudiant);
                    break;
                case 6:
                    reinitialiserPae(conn, emailEtudiant);
                    break;
                default:
                    System.out.println("Fin du programme. Bonne journ�e.");
                    System.out.println();
                    break;
            }
        } while (1 <= choix && choix <= 6);
    }


    public static boolean connexion_etudiant(Connection conn, String emailEtudiant, String passwordEtudiant){
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM project_sql.connexion_etudiant(?)");
            ps.setString(1, emailEtudiant);
            //ps.setString(2, passwordEtudiant);
            //ps.executeUpdate();
            try (ResultSet rs = ps.executeQuery()){
                while (rs.next()){
                    String passwordHash = rs.getString(1);
                    if (!BCrypt.checkpw(passwordEtudiant, passwordHash)){
                        // TODO
                        System.out.println("Le mot de passe ou l'email est faux");
                        return false;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        System.out.println("Vous �tes connect� � l'email : " + emailEtudiant);
        //System.out.println(passwordHash);
        return true;

    }


    public static void ajouterUePae(Connection conn, String emailEtudiant){
        //TODO
        System.out.println("Veuillez entrez le code de l'UE que vous souhaiter ajouter � votre PAE");
        String code_ue = scanner.next();
        try {

            PreparedStatement ps = conn.prepareStatement("SELECT * FROM project_sql.ajouter_ue_pae(?,?)");
            ps.setString(1, emailEtudiant);
            ps.setString(2,code_ue);

            try (ResultSet rs = ps.executeQuery()){
                while (rs.next()){
                    System.out.println("L'UE "+ code_ue + " a correctement �t� ajout�e � votre PAE");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void enleverUePae(Connection conn, String emailEtudiant){
        //TODO
        System.out.println("Veuillez entrez le code de l'UE que vous souhaiter enlever � votre PAE");
        String code_ue = scanner.next();
        try {

            PreparedStatement ps = conn.prepareStatement("SELECT * FROM project_sql.enlever_ue_pae(?,?)");
            ps.setString(1, emailEtudiant);
            ps.setString(2, code_ue);
            try (ResultSet rs = ps.executeQuery()){
                while (rs.next()) {
                    System.out.println("L'UE " + code_ue + " a correctement �t� enlev�e de votre PAE");

                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    public static void validerPae(Connection conn, String emailEtudiant){
        //TODO
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM project_sql.valider_pae(?)");
            ps.setString(1, emailEtudiant);

            try (ResultSet rs = ps.executeQuery()){
                while (rs.next()){
                    System.out.println("Votre PAE a bien �t� valid�");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void afficherUesAutorisees(Connection conn , String emailEtudiant){

    }

    public static void visualiserPae(Connection conn, String emailEtudiant){
        //TODO
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM project_sql.visualiser_pae WHERE email = ?");
            ps.setString(1, emailEtudiant);

            try (ResultSet rs = ps.executeQuery()){
                System.out.println("--------------------------------------------");
                while (rs.next()){
                    System.out.println("Code UE : " + rs.getString(1)+ " | "+"Nom UE : "+ rs.getString(2) + " | " +"Nombre de credits : " +rs.getInt(3) + " | " +"Bloc UE : "+rs.getInt(4));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();

        }

    }

    public static void reinitialiserPae(Connection conn, String emailEtudiant){
        //TODO � voir si le nom doit changer ou pas (de la fonction)
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM project_sql.reinitialiser_pae(?)");
            ps.setString(1, emailEtudiant);

            try (ResultSet rs = ps.executeQuery()){
                while (rs.next()){
                    System.out.println("Le PAE a �t� correctement r�initialis�");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }


    }
}
