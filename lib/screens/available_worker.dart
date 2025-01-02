import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:work_today/components/worker_card.dart';
import 'package:work_today/model/app_user.dart';
import 'package:work_today/model/category.dart';
import 'package:work_today/services/firebase_user.dart';

final _firestore = FirebaseFirestore.instance;

class AvailableWorker extends StatelessWidget {
  final String category;
  final bool isdark;
  AvailableWorker({Key? key, required this.category, required this.isdark}) : super(key: key);

  List<String> availableUserID = [];

  Future<void> getUserList() async {
    DocumentReference ref = _firestore.collection('category').doc('cfdOhIiAzuSEHARrTAPK');
    DocumentSnapshot doc = await ref.get();
    var data = doc.data();
    Map<String, dynamic> categoryMap = data['category'];
    availableUserID = categoryMap[category.toLowerCase()] as List<String>;
  }

  List<Widget> getWorkerWidgetList(jobs) {
    List<Widget> workerWidgetList = [];
    for (var job in jobs) {
      var data = job.data();
      String docID = job.id;
      // if(!availableUserID.contains(docID))
      //   continue;
      List<dynamic> categories = data['categories'];
      if(!categories.contains(category))
        continue;
      String username = data['name'];
      print(username);
      String city = data['city'];
      workerWidgetList.add(
          WorkerCard(
            workerName: username,
            location: city,
            job: category,
            workerId: job.id,
            isdark: this.isdark,
          )
      );
    }
    return workerWidgetList;
  }

  @override
  Widget build(BuildContext context) {

    Widget header = Container(
      padding: const EdgeInsets.only(top: 25, bottom: 45),
      child: Text(
        "Available $category",
        style: TextStyle(
          fontFamily: 'Indie',
          fontSize: 50.0,
          fontWeight: FontWeight.w500,
          wordSpacing: 2.5,
          color: Colors.black,
        ),
      ),
    );

    Widget progressIndicator = Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.lightBlueAccent,
      ),
    );

    Widget availableWorkers = Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return progressIndicator;
          }
          final jobs = snapshot.data!.docs.reversed;
          return Container(
            alignment: Alignment.center,
            width: double.infinity,
            child: ListView(
              children: getWorkerWidgetList(jobs),
            ),
          );
        },
      ),
    );

    return Scaffold(
      backgroundColor: this.isdark?Colors.grey[850]:Color(0xFFF6F6F6),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(left: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              header,
              availableWorkers,
            ],
          ),
        ),
      ),
    );
  }
}
