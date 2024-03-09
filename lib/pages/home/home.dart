import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_playground/firebase/constant.dart';
import 'package:flutterfire_playground/models/post.model.dart';

import '../profile/profile.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileView(isEditable: false),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => await FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: const _Body(),
      floatingActionButton: const _FloatingButton(),
    );
  }
}

class _FloatingButton extends StatefulWidget {
  const _FloatingButton();

  @override
  State<_FloatingButton> createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<_FloatingButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: () async {
        setState(() => isLoading = true);
        for (int i = 0; i < 500; i++) {
          final uid =
              (DateTime.now().microsecondsSinceEpoch + Random().nextInt(99999))
                  .toString();
          await FirebaseFirestore.instance.collection(posts).doc(uid).set(
                PostModel(
                  uid: uid,
                  title: 'Post $i',
                  description: 'This is post $i',
                  created: Timestamp.fromDate(DateTime.now().toUtc()),
                  creator:
                      FirebaseAuth.instance.currentUser?.uid ?? 'undefined!',
                ).toJson(),
              );
          debugPrint('Post $i created');
        }
        setState(() => isLoading = false);
      },
      child: Center(
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(10.0),
                child: CircularProgressIndicator(strokeWidth: 2.0),
              )
            : const Icon(Icons.add),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final controller = TextEditingController();
  String q = '';
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() => q = controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Flexible(
          child: FirestoreListView<PostModel>(
            pageSize: 20,
            loadingBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            errorBuilder: (_, e, __) => Center(child: Text(e.toString())),
            emptyBuilder: (_) => const Center(child: Text('No posts found')),
            query: FirebaseFirestore.instance
                .collection(posts)
                .where('title', isGreaterThanOrEqualTo: q)
                .withConverter<PostModel>(
                  fromFirestore: (ss, _) => PostModel.fromJson(ss.data()!),
                  toFirestore: (post, _) => post.toJson(),
                ),
            itemBuilder: (context, snapshot) {
              final post = snapshot.data();
              return ListTile(
                title: Text(post.title),
                subtitle: Text(post.description),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection(posts)
                        .doc(post.uid)
                        .delete();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
