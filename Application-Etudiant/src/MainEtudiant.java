import com.berry.BCrypt;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.*;
import java.util.Properties;
import java.util.Scanner;

public class MainEtudiant {
    private String emailEtudiant;
    private Connection conn = null;
    private boolean connecte = false;
    private static final Scanner scanner = new Scanner(System.in);

    public MainEtudiant(){
        //Chargement des variables du fichier conf.properties
        Properties props = new Properties();
        try (FileInputStream fis = new FileInputStream("C:\\Users\\dimit\\IdeaProjects\\Projet_SQL\\Application-Etudiant\\model\\conf.properties")){
            props.load(fis);
        } catch (FileNotFoundException e ) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }


        String classe = props.getProperty("jdbc.driver.class");
        String url = props.getProperty("jdbc.url");
        String login = props.getProperty("jdbc.login");
        String password = props.getProperty("jdbc.password");

        //Forcer le chargement du Driver à l'exécution
        try {
            Class.forName(classe);
        } catch (ClassNotFoundException e) {
            System.out.println("Driver PostgreSQL manquant");
            System.exit(1);
        }

        try {
            conn= DriverManager.getConnection(url, login, password);
        } catch ( SQLException e) {
            System.out.println("Impossible de joindre le server");
            System.exit(1);
        }
    }

    public String menu() {
        return "1 -> Ajouter une UE au PAE.\n"
                + "2 -> Enlever une UE du PAE.\n"
                + "3 -> Valider le PAE.\n"
                + "4 -> Afficher les UE autorisées à l'ajout.\n"
                + "5 -> Visualiser le PAE.\n"
                + "6 -> Réinitialiser le PAE.\n"
                + "0 -> Quitter l'application.";
    }

    public void exit() {
        try{
            conn.close();
            System.out.println("Merci d'avoir utilisée notre application de gestion d'un PAE!");
        } catch (SQLException e) {
            System.out.println("Erreur lors de la fermeture de la connection à la DB.");
            System.out.println(e.getMessage());        }
    }


    public void connexion() {
        String mdpDB ="";
        try {
            System.out.println("Indique ton adresse email :");
            emailEtudiant =scanner.next();
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM project_sql.connexion_etudiant(?)");
            ps.setString(1, emailEtudiant);

            try(ResultSet rs = ps.executeQuery()){
                while(rs.next()) {
                    mdpDB = rs.getString(1);
                }
            }
            System.out.println("Indique ton mot de passe :");
            String mdp = scanner.next();
            if(BCrypt.checkpw(mdp, mdpDB)) {
                connecte = true;
                System.out.println("L'etudiant est connecte");
            }else {
                System.out.println("Le mot de passe est faux");

            }
        }catch(SQLException e) {
            System.out.println("Erreur");
            System.out.println(e.getMessage());
        }
    }

    public void ajouterUePae(){
        //TODO
        if(connecte){
            System.out.println("Veuillez entrez le code de l'UE que vous souhaiter ajouter à votre PAE");
            String code_ue = scanner.next();
            try {
                PreparedStatement ps = conn.prepareStatement("SELECT * FROM project_sql.ajouter_ue_pae(?,?)");
                ps.setString(1, emailEtudiant);
                ps.setString(2,code_ue);

                try (ResultSet rs = ps.executeQuery()){
                    while (rs.next()){
                        System.out.println("L'UE "+ code_ue + " a correctement été ajoutée à votre PAE");
                    }
                }
            } catch (SQLException e) {
                //e.printStackTrace();
                System.out.println(e.getMessage());
            }
        }
        else{
            System.out.println("L'etudiant n'est pas connecte");
            connexion();
        }

    }

    public void enleverUePae(){
        //TODO
        if(connecte){
            System.out.println("Veuillez entrez le code de l'UE que vous souhaiter enlever à votre PAE");
            String code_ue = scanner.next();
            try {

                PreparedStatement ps = conn.prepareStatement("SELECT * FROM project_sql.enlever_ue_pae(?,?)");
                ps.setString(1, emailEtudiant);
                ps.setString(2, code_ue);
                try (ResultSet rs = ps.executeQuery()){
                    while (rs.next()) {
                        System.out.println("L'UE " + code_ue + " a correctement été enlevée de votre PAE");

                    }
                }
            } catch (SQLException e) {
                //e.printStackTrace();
                System.out.println(e.getMessage());
            }
        }
        else{
            System.out.println("L'etudiant n'est pas connecte");
            connexion();
        }

    }


    public void validerPae(){
        //TODO
        if(connecte){
            try {
                PreparedStatement ps = conn.prepareStatement("SELECT * FROM project_sql.valider_pae(?)");
                ps.setString(1, emailEtudiant);

                try (ResultSet rs = ps.executeQuery()){
                    while (rs.next()){
                        System.out.println("Votre PAE a bien été validé");
                    }
                }
            } catch (SQLException e) {
                //e.printStackTrace();
                System.out.println(e.getMessage());
            }
        }
        else{
            System.out.println("L'etudiant n'est pas connecte");
            connexion();
        }

    }

    public void afficherUesAutorisees(){
        if (connecte){

        }
        else {
            System.out.println("L'etudiant n'est pas connecte");
            connexion();
        }
    }

    public void visualiserPae(){
        //TODO
        if(connecte){
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
                //e.printStackTrace();
                System.out.println(e.getMessage());

            }
        }
        else {
            System.out.println("L'etudiant n'est pas connecte");
            connexion();
        }


    }

    public void reinitialiserPae(){
        //TODO à voir si le nom doit changer ou pas (de la fonction)
        if(connecte){
            try {
                PreparedStatement ps = conn.prepareStatement("SELECT * FROM project_sql.reinitialiser_pae(?)");
                ps.setString(1, emailEtudiant);

                try (ResultSet rs = ps.executeQuery()){
                    while (rs.next()){
                        System.out.println("Le PAE a été correctement réinitialisé");
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
                System.out.println(e.getMessage());
            }
        }
        else {
            System.out.println("L'etudiant n'est pas connecte");
            connexion();
        }

    }




}
