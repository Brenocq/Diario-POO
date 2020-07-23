import 'package:cloud_firestore/cloud_firestore.dart';

class Crud{

  static var _firestore = Firestore.instance;

  static void deletaPagina(String userId, String docId) async{
    try{
      _firestore.collection(userId).document(docId).delete();
    } catch (e){
      print('Erro ao deletar página de id ' + docId +':' + e);
    }
  }

  static Future<Stream<QuerySnapshot>> obterSnap(String userId) async{
    return await _firestore.collection(userId).snapshots();
  }

  static obterDados(String userId) async{
    return await _firestore.collection(userId)
        .orderBy('dataDeCriacao', descending: true)
        .getDocuments();
  }

  // TODO: implementar update
//  static void updatePage(String userId, String docId, ) async{
//    try{
//      _firestore.collection(userId).document(docId).updateData()
//    } catch (e){
//      print('Erro ao editar página de id ' + docId + ':' + e);
//    }
//  }
}