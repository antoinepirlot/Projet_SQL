/**
 * @Author Pirlot Antoine
 * @Author Dimitriadis Nicolas
 */

import java.util.Scanner;

public class ApplicationEtudiant {
    public static final Scanner SCANNER = new Scanner(System.in);
    public static final MainEtudiant APP = new MainEtudiant();

    public static void main(String[] args){
        int choix;
        do {
            APP.afficherMenu();
            choix = SCANNER.nextInt();
            SCANNER.nextLine();

            switch (choix) {
                case 1 -> APP.ajouterUePae();
                case 2 -> APP.enleverUePae();
                case 3 -> APP.validerPae();
                case 4 -> APP.afficherUesAutorisees();
                case 5 -> APP.visualiserPae();
                case 6 -> APP.reinitialiserPae();
                case 7 -> APP.changerDeCompte();
                default -> APP.afficherFin();
            }
        } while (choix >= 1 && choix <= 7);
    }
}
