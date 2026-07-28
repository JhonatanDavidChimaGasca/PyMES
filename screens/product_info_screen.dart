import 'package:flutter/material.dart';

import '../core/app_locator.dart';
import '../domain/entities/product.dart';
import '../domain/entities/promo_code.dart';


class ProductInfoScreen extends StatefulWidget {
  final Product product;
  
  const ProductInfoScreen({super.key, required this.product});

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  final TextEditingController promoController = TextEditingController();
  double? discountApplied;
  String? appliedPromoCode;

  @override
  Widget build(BuildContext context) {
    final discountPct = (discountApplied ?? 0);
    final finalPrice = widget.product.price * (1 - (discountPct / 100));

    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Información", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Producto: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.product.name),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  const Text("PROMOCIONES: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: promoController,
                            decoration: const InputDecoration(
                              hintText: "Ingresa codigo promocional",
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _applyPromoCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text("Aplicar", style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (appliedPromoCode != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text("Código '$appliedPromoCode' aplicado: -\$${discountApplied!.toStringAsFixed(2)}", 
                           style: const TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  const Text("Tipo de producto: ", style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: DropdownButton<String>(
                      value: widget.product.category,
                      isExpanded: true,
                      items: [
                        "Accesorio dispositivos moviles",
                        "Herramienta de cocina",
                        "Herramienta de obra", 
                        "Pintura",
                        "Perfume",
                        "Electrodoméstico"
                      ].map((String value) => DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: null, // Solo lectura en vista
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              const Text("ARTÍCULO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.product.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              const Text("Marca", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.product.brand.isEmpty ? "Sin información" : widget.product.brand, 
                   style: const TextStyle(color: Colors.grey)),
              
              const SizedBox(height: 16),
              const Text("DESCRIPCIÓN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(widget.product.description, style: const TextStyle(fontSize: 14, height: 1.5)),
              
              const SizedBox(height: 20),
              Text("Cantidad: ${widget.product.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("PRECIO: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (discountApplied != null) ...[
                    Text(
                      "\$${widget.product.price.toStringAsFixed(2)}", 
                      style: const TextStyle(fontSize: 14, decoration: TextDecoration.lineThrough, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text("\$${finalPrice.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                  ] else
                    Text("\$${widget.product.price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyPromoCode() async {
    if (promoController.text.trim().isEmpty) return;
    
    try {
      PromoCode? promoCode = await AppLocator.promoCodes.validatePromoCode(promoController.text.trim());
      
      if (promoCode != null) {
        setState(() {
          discountApplied = promoCode.discount;
          appliedPromoCode = promoCode.code;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Codigo promocional aplicado: ${promoCode.discount}% de descuento"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Codigo promocional invalido o expirado"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al validar codigo promocional"), backgroundColor: Colors.red),
      );
    }
  }
}

