/**
 * @Author Pirlot Antoine
 * @Author Dimitriadis Nicolas
 */

import java.sql.*;
import java.util.Scanner;

public class ApplicationCentrale {

    private static final Scanner SCANNER = new Scanner(System.in);
    private static final MainCentrale APP = new MainCentrale();

    public static void main(String[] args) {
        System.out.println("Bienvenue dans l'application centrale dédiée aux administrateurs.");

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
                default -> {
                    System.out.println("Fin du programme. Bonne journée.");
                    System.out.println();
                }
            }
        } while (1 <= choix && choix <= 8);
    }
}
