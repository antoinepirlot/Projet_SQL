import java.util.Scanner;

public class ApplicationEtudiant {
    static Scanner scanner = new Scanner(System.in);
    static MainEtudiant app = new MainEtudiant();

    public static void main(String[] args){
        boolean boucle =  true ;
        app.connexionEtudiant();
        while(boucle) {
            System.out.println(app.menu());
            int choix = scanner.nextInt();
            switch(choix){
                case 1 :
                    app.ajouterUePae();
                    break;
                case 2 :
                    app.enleverUePae();
                    break;
                case 3 :
                    app.validerPae();
                    break;
                case 4 :
                    app.afficherUesAutorisees();
                    break;
                case 5 :
                    app.visualiserPae();
                    break;
                case 6 :
                    app.reinitialiserPae();
                    break;
                case 0 :
                    boucle = false;
                    app.exit();
                    break;
                default :
                    System.out.println(app.menu());
                    break;
            }

        }
    }
}
