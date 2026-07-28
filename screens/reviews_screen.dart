import 'package:flutter/material.dart';


class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

//PANTALLA DE RESEÑAS//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reseñas"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text("Aún no hay reseñas", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
} 

// Este apartado aun esta en desarrollo, se planea que en un futuro se pueda mostrar las reseñas de los productos y servicios de todos los usuarios activos en la plataforma.