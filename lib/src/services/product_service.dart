import 'package:business_manager_web_ui/src/models/product_model.dart';
import 'package:business_manager_web_ui/src/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class ProductService {
  String users = 'users';
  String products = 'products';
  String receipe = 'receipe';
  String images = 'images';
  String raw = 'raw';
  String records = 'records';

  final FirebaseFirestore productCollection = FirebaseFirestore.instance;
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user_collection');

  //Product section
  //Allow adding editing, reading and deleting products
  //Add Product
  Future<void> addProduct(String userId, Product product) async {
    await userCollection
        .doc(userId)
        .collection(products)
        .doc(product.id)
        .set(product.toMap());
  }

  Future<void> updateProduct(String userId, Product product) async {
    await userCollection
        .doc(userId)
        .collection(products)
        .doc(product.id)
        .update(product.toMap());
  }

  //Update product with receipt id
  Future<void> updateProductReceipe(
      String userId, String productId, String receipeId, double? cost) async {
    await userCollection
        .doc(userId)
        .collection(products)
        .doc(productId)
        .update({'receipeId': receipeId, 'cost': cost});
  }

  //Update product Record
  Future<void> updateProductRecord(
      {String? userId,
      String? productId,
      OrderProducts? product,
      String? orderId}) async {
    try {
      await userCollection
          .doc(userId)
          .collection(products)
          .doc(productId)
          .collection(records)
          .doc(orderId)
          .set(product!.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Stream
  //Stream all products
  Stream<List<Product>> getProducts(String userId) {
    return userCollection
        .doc(userId)
        .collection(products)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Product>> getAllUserProducts(String userId, {String? category}) {
    Query query = userCollection.doc(userId).collection(products);
    // Only filter by category when one is actually selected — Firestore's
    // isEqualTo: null matches documents where the field is explicitly null,
    // not "any category", so applying it unconditionally would hide every
    // categorized product on the default (no filter) view.
    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                Product.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<Product> streamSingleProduct({String? userId, String? productId}) {
    return userCollection
        .doc(userId)
        .collection(products)
        .doc(productId)
        .snapshots()
        .map((doc) => Product.fromMap(doc.data()!, doc.id));
  }

  //Stream product records
  Stream<List<OrderProducts>> streamProductRecords({String? userId}) {
    // Ensure userId is provided
    if (userId == null) throw ArgumentError('userId must not be null');

    return FirebaseFirestore.instance
        .collectionGroup(records) // Query all 'records' subcollections
        .where('userId', isEqualTo: userId) // Filter by userId if needed
        .orderBy('quantity', descending: true) // Server-side sort
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderProducts.fromMap(
                  doc.data(),
                ))
            .toList());
  }

  // Future Single product record - Fixed version
  Future<List<OrderProducts>> futureSingleProductRecord(
      {String? userId, String? productId}) async {
    try {
      // Firestore's web SDK doesn't support ordering FieldPath.documentId
      // descending ("Firestore does not support descending key scans") even
      // though native SDKs do — order ascending and reverse client-side.
      final querySnapshot = await userCollection
          .doc(userId)
          .collection(products)
          .doc(productId)
          .collection(records)
          .orderBy(FieldPath.documentId)
          .get();

      return querySnapshot.docs.reversed.map((doc) {
        final record = OrderProducts.fromMap(doc.data());

        return record.copyWith(id: doc.id);
      }).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  //Check if product Exists
  Future<bool> checkIfProductRecordExist(
      String userId, String productId, String orderId) async {
    try {
      return await userCollection
          .doc(userId)
          .collection(products)
          .doc(productId)
          .collection(records)
          .doc(orderId)
          .get()
          .then((data) => data.exists);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteProductRecord(
      String userId, String productId, String orderId) async {
    try {
      await userCollection
          .doc(userId)
          .collection(products)
          .doc(productId)
          .collection(records)
          .doc(orderId)
          .delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  //Futures
  //Future single product
  Future<Product> futureSingleProduct(
      {String? userId, String? productId}) async {
    try {
      return await userCollection
          .doc(userId)
          .collection(products)
          .doc(productId)
          .get()
          .then((doc) => Product.fromMap(doc.data()!, doc.id));
    } catch (e) {
      throw Exception(e);
    }
  }

  //Get last product id
  Future<String> futureLastProductId(String? userId) async {
    try {
      // Get the last document ID that starts with 'PR'. Firestore's web SDK
      // doesn't support ordering FieldPath.documentId descending ("Firestore
      // does not support descending key scans") \u2014 order ascending instead
      // and take the last doc, which is equivalent to the old
      // descending+limit(1)+first.
      final querySnapshot = await userCollection
          .doc(userId)
          .collection(products)
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: 'PR')
          .where(FieldPath.documentId, isLessThan: 'PR\uf8ff')
          .orderBy(FieldPath.documentId)
          .get();
      // Regex pattern for PR followed by exactly 5 digits
      final pattern = RegExp(r'^PR\d{5}$');
      if (querySnapshot.docs.isNotEmpty) {
        final lastDoc = querySnapshot.docs.last;
        if (pattern.hasMatch(lastDoc.id)) {
          return lastDoc.id;
        }
      }

      return '';
    } catch (e) {
      throw Exception(e);
    }
  }

  //Get all the products Ids
  Future<List<String>> futureAllProductIds({String? userId}) async {
    try {
      final querySnapshot =
          await userCollection.doc(userId).collection(products).get();
      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Product>> futureAllProductInStore(
      {String? userId, String? storeName}) async {
    try {
      if (storeName == null || storeName.isEmpty) {
        // Return ALL products (no store filter)
        final querySnapshot =
            await userCollection.doc(userId).collection(products).get();

        return querySnapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList();
      } else {
        final querySnapshot = await userCollection
            .doc(userId)
            .collection(products)
            .where('inventory.$storeName', isGreaterThan: 0)
            .get();

        return querySnapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //Get all the products Categories
  Future<List<String>> futureAllProductCategories({String? userId}) async {
    try {
      final querySnapshot =
          await userCollection.doc(userId).collection(products).get();

      return querySnapshot.docs
          .map((doc) {
            var data = doc.data();
            return (data['category'] as String?) ?? ''; // Provide default value
          })
          .where((category) => category.isNotEmpty)
          .toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<String>> getProductImageUrls(
      String userId, String productId) async {
    try {
      final snapshot = await userCollection
          .doc(userId)
          .collection(products)
          .doc(productId)
          .get();
      var data = snapshot.data();
      if (data?['images'] != null && data?['images'].isNotEmpty) {
        return data?['url'].map((doc) => doc['url'] as String).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //Check if products Exists
  Future<bool> checkIfProductsExist(String userId) async {
    try {
      return await userCollection
          .doc(userId)
          .collection(products)
          .get()
          .then((data) => data.docs.isNotEmpty);
    } catch (e) {
      throw Exception(e);
    }
  }

  //Check if product Exists
  Future<bool> checkIfProductExist(String userId, String productId) async {
    try {
      return await userCollection
          .doc(userId)
          .collection(products)
          .doc(productId)
          .get()
          .then((data) => data.exists);
    } catch (e) {
      throw Exception(e);
    }
  }

  //Delete Product
  Future<void> deleteProduct(String userId, String productId) async {
    final productDocRef =
        userCollection.doc(userId).collection(products).doc(productId);

    try {
      // Check if product exists
      if (!(await productDocRef.get()).exists) {
        return;
      }

      // Check and delete records in batches if they exist
      final recordsRef = productDocRef.collection(records);
      final firstRecord = await recordsRef.limit(1).get();

      if (firstRecord.docs.isNotEmpty) {
        // Get all record IDs first
        final allRecords = await recordsRef.get();
        final recordIds = allRecords.docs.map((doc) => doc.id).toList();

        // Delete in batches of 500 (Firebase limit)
        const batchSize = 500;
        for (int i = 0; i < recordIds.length; i += batchSize) {
          final batch = FirebaseFirestore.instance.batch();
          final batchIds = recordIds.sublist(
              i,
              i + batchSize > recordIds.length
                  ? recordIds.length
                  : i + batchSize);

          for (final id in batchIds) {
            batch.delete(recordsRef.doc(id));
          }

          await batch.commit();
        }
      }

      // Finally delete the product
      await productDocRef.delete();
    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace, label: 'Error Deleting Product');
      return;
    }
  }

  //All product Images
  //Add New Image
  Future<void> addImage(String userId, GalleryImages image) async {
    await userCollection.doc(userId).collection(images).add({
      'url': image.imageUrl,
      'name': image.imageName,
      'createdAt': image.createdAt,
    });
  }

  //Edit Exisiting Image
  Future<void> editImage(
      String userId, String imageId, GalleryImages image) async {
    await userCollection.doc(userId).collection(images).doc(image.uid).update({
      'url': image.imageUrl,
      'name': image.imageName,
      'createdAt': image.createdAt,
    });
  }

  //Read Images
  //Stream All Images
  Stream<List<GalleryImages>> streamGalleryImages(String userId) {
    return userCollection
        .doc(userId)
        .collection('images') // Ensure 'images' is a defined constant or string
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              // Create a new mutable map from doc.data() and add the 'uid'
              final data = Map<String, dynamic>.from(doc.data());
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return GalleryImages.fromMap(data);
            }).toList());
  }

  //Future Single Image
  Future<GalleryImages?> futureSingleImage({
    String? userId,
    String? imageId,
  }) async {
    try {
      final doc = await userCollection
          .doc(userId)
          .collection(images)
          .doc(imageId)
          .get();

      if (doc.exists && doc.data() != null) {
        var data = doc.data()!;
        data['uid'] = doc.id; // Add the document ID as 'uid'
        return GalleryImages.fromMap(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  //Delete Image
  Future<void> deleteImage(String userId, GalleryImages image) async {
    //Deletion process will happen on two steps
    //First delete from storage
    StorageService ss = StorageService();
    await ss.deleteItemFromStorage(url: image.imageUrl!).then((value) async {
      //Then delete from firestore

      if (value == true) {
        //Delete from firestore

        await userCollection
            .doc(userId)
            .collection(images)
            .doc(image.uid)
            .delete();
      }
    });
  }

  //Receipes section will be dedicated for manufacturing businesses
  //It will allow adding, editing, reading and deleting receipes
  //Add Receipe
  Future<void> addReceipe(String userId, Receipe theReceipe) async {
    await userCollection
        .doc(userId)
        .collection(receipe)
        .add(theReceipe.toMap());
  }

  //Edit Receipe
  Future<void> updateReceipe(String userId, Receipe theReceipe) async {
    await userCollection
        .doc(userId)
        .collection(receipe)
        .doc(theReceipe.uid)
        .update(theReceipe.toMap());
  }
  //Stream All Receipes

  Stream<List<Receipe>> streamAllReceipes(String userId) {
    return userCollection
        .doc(userId)
        .collection(receipe)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return Receipe.fromMap(data);
            }).toList());
  }

  //Check if receipe exists
  Future<bool> doesRecipeExist(
      {required String? userId, required String? recipeId}) async {
    // Handle null parameters
    if (userId == null || recipeId == null) {
      return false;
    }

    try {
      final docSnapshot = await userCollection
          .doc(userId)
          .collection(
              receipe) // Note: 'receipe' might be a typo, should it be 'recipes'?
          .doc(recipeId)
          .get();

      return docSnapshot.exists;
    } catch (e) {
      // Log the error if needed
      return false; // Return false on error to be safe
    }
  }

  //Future Single Receipe
  Future<Receipe> futureSingleReceipe(
      {String? userId, String? receipeId}) async {
    try {
      return await userCollection
          .doc(userId)
          .collection(receipe)
          .doc(receipeId)
          .get()
          .then((doc) {
        var data = doc.data();
        data!['uid'] = doc.id;
        return Receipe.fromMap(data);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  //Delete Receipe
  Future<void> deleteReceipe(String userId, String receipeId) async {
    await userCollection
        .doc(userId)
        .collection(receipe)
        .doc(receipeId)
        .delete();
  }

  //Raw item section
  //Allow adding editing, reading and deleting raw items
  //Add Raw Item
  Future<void> addRawItem(String userId, RawItem rawItem) async {
    try {
      // Ensure conversion map exists if needed
      final itemToAdd = rawItem.conversion == null
          ? rawItem.copyWith(conversion: {})
          : rawItem;
      await userCollection.doc(userId).collection(raw).add(itemToAdd.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Edit Raw Item
  Future<void> editRawItem(String userId, RawItem rawItem) async {
    try {
      // Ensure conversion map exists if needed
      final itemToAdd = rawItem.conversion == null
          ? rawItem.copyWith(conversion: {})
          : rawItem;
      await userCollection
          .doc(userId)
          .collection(raw)
          .doc(rawItem.uid)
          .update(itemToAdd.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  //Stream All Raw Items
  Stream<List<RawItem>> streamAllRawItems(String userId) {
    return userCollection
        .doc(userId)
        .collection(raw)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              data['uid'] = doc.id; // Add the document ID as 'uid'
              return RawItem.fromMap(data, doc.id);
            }).toList());
  }

  //Check if Raw material still exists
  Future<bool> doesRawItemExist(
      {required String? userId, required String? rawItemId}) async {
    // Handle null parameters
    if (userId == null || rawItemId == null) {
      return false;
    }

    try {
      final docSnapshot =
          await userCollection.doc(userId).collection(raw).doc(rawItemId).get();

      return docSnapshot.exists;
    } catch (e) {
      return false; // Return false on error to be safe
    }
  }

  //Future Single Raw Item
  Future<RawItem> futureSingleRawItem(
      {String? userId, String? rawItemId}) async {
    try {
      return await userCollection
          .doc(userId)
          .collection(raw)
          .doc(rawItemId)
          .get()
          .then((doc) {
        var data = doc.data();
        if (data == null) {
          throw Exception('Raw item not found');
        }
        data['uid'] = doc.id; // Add the document ID as 'uid'
        return RawItem.fromMap(data, doc.id);
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<RawItem>> futureAllRawItems(
      {String? userId, String? storeName}) async {
    try {
      if (storeName == null || storeName.isEmpty) {
        // Return ALL products (no store filter)
        final querySnapshot =
            await userCollection.doc(userId).collection(raw).get();

        return querySnapshot.docs
            .map((doc) => RawItem.fromMap(doc.data(), doc.id))
            .toList();
      } else {
        final querySnapshot = await userCollection
            .doc(userId)
            .collection(raw)
            .where('inventory.$storeName', isGreaterThan: 0)
            .get();

        return querySnapshot.docs
            .map((doc) => RawItem.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //Delete Raw Item
  Future<void> deleteRawItem(String userId, String rawItemId) async {
    await userCollection.doc(userId).collection(raw).doc(rawItemId).delete();
  }
}
