import java.util.Scanner;

public class Main {

    private static final Scanner scanner = new Scanner(System.in);

    public static void main(String[] args) {
        System.out.println("Bienvenue dans l'application centrale dédiées aux administrateurs.");
        System.out.println();

        int choix;
        do{
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

    public static void ajouterUe(){
        //TODO
    }

    public static void ajouterPrerequis(){
        //TODO
    }

    public static void ajouterEtudiant(){
        //TODO
    }

    public static void encoderUeValidee(){
        //TODO
    }

    public static void visualiserTousLesEtudiantDUnBloc(){
        //TODO
    }

    public static void visualiserTout(){
        //TODO à voir si le nom doit changer ou pas (de la fonction)
    }

    public static void visualiserEtudiantPAENonValide(){
        //TODO
    }

    public static void visualiserUEDUnBloc(){
        //TODO
    }
}
