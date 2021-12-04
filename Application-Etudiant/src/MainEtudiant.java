/**
 * @Author Pirlot Antoine
 * @Author Dimitriadis Nicolas
 */

import java.sql.*;
import java.util.Scanner;

public class MainEtudiant {
    private String emailEtudiant;
    private static final Scanner SCANNER = new Scanner(System.in);
    private static final Connection CONNEXION = connexionDb();

    public MainEtudiant() {
        connexionEtudiant();
    }

    public void afficherMenu() {
        System.out.println("1 -> Ajouter une UE au PAE.");
        System.out.println("2 -> Enlever une UE du PAE.");
        System.out.println("3 -> Valider le PAE.");
        System.out.println("4 -> Afficher les UE autorisees a l'ajout.");
        System.out.println("5 -> Visualiser le PAE.");
        System.out.println("6 -> Reinitialiser le PAE.");
        System.out.println("0 -> Quitter l'application.");
    }

    public void connexionEtudiant() {
        String mdpDB = "";
        System.out.println("Indique ton adresse email :");
        emailEtudiant = SCANNER.nextLine();

        System.out.println("Indique ton mot de passe :");
        String mdp = SCANNER.nextLine();
        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT * FROM project_sql.connexion_etudiant(?)");
            ps.setString(1, emailEtudiant);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    mdpDB = rs.getString(1);
                }
            }
        } catch (SQLException e) {
            System.out.println("Erreur");
            System.out.println(e.getMessage());
        }
        if (BCrypt.checkpw(mdp, mdpDB))
            System.out.println("L'etudiant est connecte");
        else {
            System.out.println("Le mot de passe est faux");
            connexionEtudiant();
        }
    }

    public void ajouterUePae() {
        System.out.println("Veuillez entrez le code de l'UE que vous souhaiter ajouter a votre PAE");
        String code_ue = SCANNER.nextLine();
        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT * FROM project_sql.ajouter_ue_pae(?,?)");
            ps.setString(1, emailEtudiant);
            ps.setString(2, code_ue);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("L'UE " + code_ue + " a correctement ete ajoutee a votre PAE");
                }
            }
        } catch (SQLException e) {
            //e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }

    public void enleverUePae() {
        System.out.println("Veuillez entrez le code de l'UE que vous souhaiter enlever a votre PAE");
        String code_ue = SCANNER.nextLine();
        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT * FROM project_sql.enlever_ue_pae(?,?)");
            ps.setString(1, emailEtudiant);
            ps.setString(2, code_ue);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    System.out.println("L'UE " + code_ue + " a correctement ete enlevee de votre PAE");
            }
        } catch (SQLException e) {
            //e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }


    public void validerPae() {
        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT * FROM project_sql.valider_pae(?)");
            ps.setString(1, emailEtudiant);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("Votre PAE a bien ete valide");
                }
            }
        } catch (SQLException e) {
            //e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }

    public void afficherUesAutorisees() {
        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT * FROM project_sql.visualiser_ue_disponible_pae WHERE email = ?");
            ps.setString(1, emailEtudiant);

            try (ResultSet rs = ps.executeQuery()) {
                System.out.println("-------------UES DISPONIBLES----------------");
                while (rs.next()) {
                    System.out.println("Code UE : " + rs.getString(1) + " | " + "Nom UE : " + rs.getString(2) + " | " + "Nombre de credits : " + rs.getInt(3) + " | " + "Bloc UE : " + rs.getInt(4));
                    System.out.println();
                }
                System.out.println("--------------------------------------------");
            }
        } catch (SQLException e) {
            //e.printStackTrace();
            System.out.println(e.getMessage());

        }
    }

    public void visualiserPae() {
        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT * FROM project_sql.visualiser_pae WHERE email = ?");
            ps.setString(1, emailEtudiant);

            try (ResultSet rs = ps.executeQuery()) {
                System.out.println("-------------------PAE----------------------");
                while (rs.next()) {
                    System.out.println("Code UE : " + rs.getString(1) + " | " + "Nom UE : " + rs.getString(2) + " | " + "Nombre de credits : " + rs.getInt(3) + " | " + "Bloc UE : " + rs.getInt(4));
                    System.out.println();
                }
                System.out.println("--------------------------------------------");
            }
        } catch (SQLException e) {
            //e.printStackTrace();
            System.out.println(e.getMessage());

        }
    }

    public void reinitialiserPae() {
        try {
            PreparedStatement ps = CONNEXION.prepareStatement("SELECT * FROM project_sql.reinitialiser_pae(?)");
            ps.setString(1, emailEtudiant);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("Le PAE a ete correctement reinitialise");
                }
            }
        } catch (SQLException e) {
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
        String url = "jdbc:postgresql://172.24.2.6:5432/dbantoinepirlot";
        Connection connection = null;
        try {
            connection = DriverManager.getConnection(url, "nicolasdimitriadis", "0JE9SRO2G");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
        return connection;
    }

    public void afficherFin() {
        deconnexion();
        System.out.println("Merci d'avoir utilisee notre application de gestion d'un PAE!");
    }

    private void deconnexion() {
        try {
            CONNEXION.close();
        } catch (SQLException e) {
            System.out.println("Erreur lors de la fermeture de la connection a la DB.");
            System.out.println(e.getMessage());
        }
    }
}
