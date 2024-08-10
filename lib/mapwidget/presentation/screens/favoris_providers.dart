import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FavorisProvider with ChangeNotifier {
  List<QueryDocumentSnapshot> _favoris = [];
  String? _defaultFavoriteId;

  List<QueryDocumentSnapshot> get favoris => _favoris;
  String? get defaultFavoriteId => _defaultFavoriteId;

  Future<void> loadFavoris() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("favoris").get();
    _favoris = querySnapshot.docs;
    _defaultFavoriteId = _favoris
    .where((doc) => doc['isDefault'] == true)
    .map((doc) => doc.id)
    .isEmpty ? null : _favoris.firstWhere((doc) => doc['isDefault'] == true).id;

    notifyListeners();
  }

  Future<void> setDefaultFavorite(String docId) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in _favoris) {
      batch.update(doc.reference, {'isDefault': false});
    }
    batch.update(FirebaseFirestore.instance.collection("favoris").doc(docId), {'isDefault': true});
    await batch.commit();

    _defaultFavoriteId = docId;
    notifyListeners();
  }

  Future<void> deleteFavoris(String docId) async {
    await FirebaseFirestore.instance.collection("favoris").doc(docId).delete();
    _favoris.removeWhere((doc) => doc.id == docId);
    notifyListeners();
  }
}
