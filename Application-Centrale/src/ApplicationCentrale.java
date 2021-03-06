/**
 * @Author Pirlot Antoine
 * @Author Dimitriadis Nicolas
 */

import java.util.Scanner;

public class ApplicationCentrale {

    private static final Scanner SCANNER = new Scanner(System.in);
    private static final MainCentrale APP = new MainCentrale();

    public static void main(String[] args) {
        System.out.println("Bienvenue dans l'application centrale dédiée aux administrateurs.");

        int choix;
        do {
            APP.afficherMenu();
            choix = SCANNER.nextInt();
            SCANNER.nextLine();
            switch (choix) {
                case 1 -> APP.ajouterUe();
                case 2 -> APP.ajouterPrerequis();
                case 3 -> APP.ajouterEtudiant();
                case 4 -> APP.encoderUeValidee();
                case 5 -> APP.visualiserTousLesEtudiantDUnBloc();
                case 6 -> APP.visualiserTousLesEtudiants();
                case 7 -> APP.visualiserEtudiantPAENonValide();
                case 8 -> APP.visualiserUEDUnBloc();
                default -> APP.afficherFin();
            }
        } while (1 <= choix && choix <= 8);
    }
}
