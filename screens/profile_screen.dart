import 'package:flutter/material.dart';

import '../core/app_locator.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AppLocator.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil de Usuario"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(user?.photoUrl ?? "https://via.placeholder.com/150/333/fff?text=Usuario"),
            ),
            const SizedBox(height: 20),
            Text(user?.displayName ?? "Usuario PyMES", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(user?.email ?? "", style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 30),
            const Text("Gestiona tu perfil y configuración", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              onPressed: () async {
                await AppLocator.auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Cerrar sesión", style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}