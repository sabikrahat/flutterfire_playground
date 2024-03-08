import 'package:flutter/material.dart';

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
        ],
      ),
      body: const Center(
        child: Text('Welcome to FlutterFire!'),
      ),
    );
  }
}
