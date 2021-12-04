/**
 * @Author Pirlot Antoine
 * @Author Dimitriadis Nicolas
 */

import java.sql.*;
import java.util.Scanner;

public class MainCentrale {
    private final Connection CONNECTION = connexionDb();
    private final Scanner SCANNER = new Scanner(System.in);

    public void ajouterUe() {
        System.out.println("Quel est le code de l'ue?");
        String codeUe = SCANNER.nextLine();

        System.out.println("Quel est le nom de l'ue?");
        String nomUe = SCANNER.nextLine();

        System.out.println("Quel est le nombre de cr�dits pour cette ue?");
        int nombreDeCredits = SCANNER.nextInt();
        SCANNER.nextLine();

        try {
            PreparedStatement ps = CONNECTION.prepareStatement("SELECT project_sql.ajouter_ue(?, ?, ?);");
            ps.setString(1, codeUe);
            ps.setString(2, nomUe);
            ps.setInt(3, nombreDeCredits);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("L'ue a bien �t� ajout�e.");
                }
            }

        } catch (SQLException e) {
            System.out.println("Erreur lors de l'insertion!");
            System.out.println(e.getMessage());
        }
    }

    public void ajouterPrerequis() {
        System.out.println("Quel est le code de l'ue?");
        String code_ue = SCANNER.next();

        System.out.println("Quel est le code de l'ue pr�requise?");
        String code_ue_prerequise = SCANNER.next();

        try {
            PreparedStatement ps = CONNECTION.prepareStatement("SELECT project_sql.ajouter_prerequis_ue(?, ?);");
            ps.setString(1, code_ue);
            ps.setString(2, code_ue_prerequise);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("Ajout r�ussi!");
                }
            }
        } catch (SQLException e) {
            System.out.println("Probl�me lors de l'insertion.");
            System.out.println(e.getMessage());
        }
    }

    public void ajouterEtudiant() {
        System.out.println("Quel est le nom de l'�tudiant?");
        String nomEtudiant = SCANNER.next();

        System.out.println("Quel est le pr�nom de l'�tudiant?");
        String prenomEtudiant = SCANNER.next();

        System.out.println("Quel est l'email de l'�tudiant?");
        String emailEtudiant = SCANNER.next();

        System.out.println("Quel est le mot de passe de l'�tudiant?");
        String sel = BCrypt.gensalt();
        String motDePassse = BCrypt.hashpw(SCANNER.next(), sel);

        try {
            PreparedStatement ps = CONNECTION.prepareStatement("SELECT project_sql.ajouter_etudiant(?, ?, ?, ?)");
            ps.setString(1, nomEtudiant);
            ps.setString(2, prenomEtudiant);
            ps.setString(3, emailEtudiant);
            ps.setString(4, motDePassse);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("Ajout r�ussi!");
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    public void encoderUeValidee() {
        System.out.println("Quel est l'email de l'�tudiant?");
        String emailEtudiant = SCANNER.next();

        System.out.println("Quel est le code de l'ue a valider?");
        String codeUe = SCANNER.next();

        try {
            PreparedStatement ps = CONNECTION.prepareStatement("SELECT project_sql.encoder_ue_validee(?, ?);");
            ps.setString(1, emailEtudiant);
            ps.setString(2, codeUe);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("Validation r�ussie");
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    public void visualiserTousLesEtudiantDUnBloc() {
        int bloc = -1;
        while (bloc < 0 || bloc > 3) {
            System.out.println("De quel bloc voulez vous voir les �tudiant?");
            System.out.println("0 -> Bloc ind�termin�");
            System.out.println("1 -> Bloc 1");
            System.out.println("2 -> Bloc 2");
            System.out.println("3 -> Bloc 3");
            bloc = SCANNER.nextInt();
        }
        String query;
        try {
            if (bloc == 0)
                query = """
                        SELECT nom, prenom, nombre_de_credits_valides FROM project_sql.etudiants WHERE "bloc" IS NULL
                        """;
            else
                query = "SELECT nom, prenom, nombre_de_credits_valides FROM project_sql.etudiants WHERE \"bloc\" =" + bloc + "";
            Statement statement = CONNECTION.createStatement();
            ResultSet resultSet = statement.executeQuery(query);
            while (resultSet.next()) {
                String nom = resultSet.getString(1);
                String prenom = resultSet.getString(2);
                String nombreDeCredits = resultSet.getString(3);
                System.out.println("Nom: " + nom + ", pr�nom: " + prenom + ", nombre de cr�dits valid�s: " + nombreDeCredits);
            }
        } catch (SQLException e) {
            System.out.println("Probl�me lors de la demande � la base de donn�es");
            e.printStackTrace();
        }
    }

    public void visualiserTousLesEtudiants() {
        try {
            PreparedStatement ps = CONNECTION.prepareStatement("SELECT * FROM project_sql.visualiser_tous_les_etudiants");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.println("Nom: " + rs.getString(1) + ", Pr�nom: " + rs.getString(2) +
                            ", bloc: " + rs.getString(3) + ", nombre de cr�dits dans le pae: " + rs.getString(4));
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    public void visualiserEtudiantPAENonValide() {
        try {
            PreparedStatement ps = CONNECTION.prepareStatement("SELECT * FROM project_sql.visualiser_etudiant_pae_non_valide");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    System.out.print("Nom: " + rs.getString(1) + " ");
                    System.out.print("Pr�nom: " + rs.getString(2) + " ");
                    System.out.println("Nombre de cr�dits d�j� valid�s: " + rs.getInt(3) + " ");
                }
            }
        } catch (SQLException e) {
            System.out.println(e.getMessage());
        }
    }

    public void visualiserUEDUnBloc() {
        try {
            PreparedStatement ps = CONNECTION.prepareStatement("SELECT * FROM project_sql.visualier_ue_bloc WHERE \"bloc\" = ?");
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

    public Connection connexionDb() {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgeSQL manquant!");
            System.exit(1);
        }

        //TODO
        //String url = "jdbc:postgresql://172.24.2.6:5432/dbantoinepirlot";
        String url = "jdbc:postgresql://localhost:5432/dbantoinepirlot";
        Connection connection = null;
        try {
            connection = DriverManager.getConnection(url, "antoinepirlot", "at5BER69h");
        } catch (SQLException e) {
            System.out.println("Impossible de joindre le server !");
            System.exit(1);
        }
        return connection;
    }
}
