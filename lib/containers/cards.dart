
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:linka/globals.dart' as globals;

import 'package:linka/containers/card.dart';
import 'package:linka/containers/camera.dart';

import 'package:linka/domain/models/linka_item.dart';

class ItemsListScreen extends StatelessWidget {
  
  final String name;
  ItemsListScreen(this.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ItemsList(firestore: Firestore.instance, name: name),
      floatingActionButton: name == "items"? null :FloatingActionButton(
        onPressed: () {

          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraScreen()),
            );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
class ItemsList extends StatelessWidget {
  ItemsList({this.firestore, this.name});

  final String name;
  final Firestore firestore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection(name).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');

        final int itemsCount = snapshot.data.documents.length;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: globals.gridSize.round()),
          itemCount: itemsCount,
          padding: const EdgeInsets.all(2.0),
          itemBuilder: (BuildContext context,int index){
            
            final DocumentSnapshot document = snapshot.data.documents[index];

            var downloadUrl = document['downloadURL'];
            var title = document['title'];
            var labels = document['labels'];

            final LinkaItem item = LinkaItem(
              title: title,
              downloadUrl: downloadUrl,
              labels:List.from(labels??[])
            );
            return GestureDetector(
                    child: LinkaCard(item),
                    onTap: () async {
                      var text = name == 'photos'? item.labels.first:item.title;
                      await globals.speak(text);
                    } 
            );
          },
        );
        // return ListView.builder(
        //   itemCount: itemsCount,
        //   itemBuilder: (_, int index) {
        //     final DocumentSnapshot document = snapshot.data.documents[index];
        //     final LinkaItem item = LinkaItem(
        //       document['downloadURL'],
        //       List.from(document['labels']));

        //     return SafeArea(
        //       top: false,
        //       bottom: false,
        //       child: LinkaCard(item),
        //     );
        //   },
        // );
      },
    );
  }
}
