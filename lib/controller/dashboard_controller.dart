import 'package:get/get.dart';

class DashboardController extends GetxController {
  var tabIndex = 0;

  void updateIndex(int index) {
    
    tabIndex = index;
    update();
  }
} 


/*class DashboardController extends GetxController {
  // Définir la longueur des onglets
  final int tabLength = 4;

  // Variable pour gérer l'index de l'onglet
  RxInt tabIndex = 0.obs;

  // Fonction pour mettre à jour l'index de l'onglet
  void updateTabIndex(int index) {
    tabIndex.value = index;
  }
} */

