import 'package:flutter/material.dart';

import '../core/app_locator.dart';
import '../domain/entities/product.dart';

import 'promo_codes_screen.dart';
import 'profile_screen.dart';
import 'product_info_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.black),
          onSelected: (value) {
            if (value == 'promociones') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PromoCodesScreen()));
            } else if (value == 'perfil') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'promociones', child: Text('Promociones')),
            const PopupMenuItem(value: 'perfil', child: Text('Perfil')),
            const PopupMenuItem(value: 'configuracion', child: Text('Configuración')),
          ],
        ),
        title: const Text("PyMES", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage("https://via.placeholder.com/150/333/fff?text=U"),
                radius: 18,
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: AppLocator.products.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No tienes productos aún", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Text("Toca el botón + para agregar tu primer producto", style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            );
          }

          // Agrupar productos por categoría
          Map<String, List<Product>> groupedProducts = {};
          for (var product in products) {
            if (!groupedProducts.containsKey(product.category)) {
              groupedProducts[product.category] = [];
            }
            groupedProducts[product.category]!.add(product);
          }

          return ListView(
            children: groupedProducts.entries.map((entry) {
              final categoryName = entry.key;
              final categoryProducts = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(categoryName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryProducts.length,
                      itemBuilder: (context, index) {
                        final product = categoryProducts[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductInfoScreen(product: product))),
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                height: 140, 
                                width: double.infinity,
                                child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              clipBehavior: Clip.hardEdge, 
                                child: product.imageUrl.isNotEmpty
                                ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                                )
                                : _buildPlaceholderImage(),
                            ),
                              ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "\$${product.price.toStringAsFixed(2)}",
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color.fromARGB(255, 243, 243, 243),
      child: const Icon(Icons.image, size: 40, color: Colors.grey),
    );
  }
}