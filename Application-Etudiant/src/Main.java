import java.util.Scanner;

public class Main {

    private static final Scanner scanner = new Scanner(System.in);

    public static void main(String[] args) {
        System.out.println("Bienvenue dans l'application dédiées aux étudiants.");
        System.out.println();

        int choix;
        do{
            System.out.println("Que voulez vous faire?");
            System.out.println();

            System.out.println("1 -> Ajouter une UE au PAE");
            System.out.println("2 -> Enlever une UE du PAE");
            System.out.println("3 -> Valider le PAE");
            System.out.println("4 -> Afficher les UE autorisées à l'ajout");
            System.out.println("5 -> Visualiser le PAE");
            System.out.println("6 -> Réinitialiser le PAE");

            choix = scanner.nextInt();
            switch (choix) {
                case 1:
                    ajouterUePae();
                    break;
                case 2:
                    enleverUePae();
                    break;
                case 3:
                    validerPae();
                    break;
                case 4:
                    afficherUesAutorisees();
                    break;
                case 5:
                    visualiserPae();
                    break;
                case 6:
                    reinitialiserPae();
                    break;
                default:
                    System.out.println("Fin du programme. Bonne journée.");
                    System.out.println();
                    break;
            }
        } while (1 <= choix && choix <= 6);
    }

    public static void ajouterUePae(){
        //TODO
    }

    public static void enleverUePae(){
        //TODO
    }

    public static void validerPae(){
        //TODO
    }

    public static void afficherUesAutorisees(){
        //TODO
    }

    public static void visualiserPae(){
        //TODO
    }

    public static void reinitialiserPae(){
        //TODO à voir si le nom doit changer ou pas (de la fonction)
    }
}
