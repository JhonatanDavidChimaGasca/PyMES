import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../core/app_locator.dart';
import '../domain/entities/product.dart';
import '../domain/entities/product_draft.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> with WidgetsBindingObserver {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController brandController = TextEditingController();

  String selectedCategory = "Accesorio dispositivos móviles";
  String selectedImageUrl = "";
  bool isLoading = false;

  // Control del borrador (autoguardado local con SharedPreferences).
  Timer? _autosaveTimer;
  bool _isDraftLoaded = false;

  final List<String> sampleImages = [
    // 'https://tu-cdn.com/imgs/ejemplo1.jpg',
    // 'https://tu-cdn.com/imgs/ejemplo2.jpg',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDraft();

    for (final controller in [nameController, descriptionController, priceController, quantityController, brandController]) {
      controller.addListener(_scheduleAutosave);
    }
  }

  // ── Borrador: cargar, guardar y limpiar ─────────────────────────────────

  Future<void> _loadDraft() async {
    try {
      final userId = AppLocator.auth.currentUserId;
      final draft = await AppLocator.productDraft.getDraft(userId);
      if (draft != null && mounted) {
        setState(() {
          nameController.text = draft.name;
          descriptionController.text = draft.description;
          brandController.text = draft.brand;
          priceController.text = draft.price;
          quantityController.text = draft.quantity;
          if (draft.category.isNotEmpty) selectedCategory = draft.category;
          selectedImageUrl = draft.imageUrl;
        });
      }
    } catch (_) {
      // Sin sesión activa todavía o fallo puntual de lectura: seguimos con el formulario vacío.
    } finally {
      _isDraftLoaded = true;
    }
  }

  void _scheduleAutosave() {
    if (!_isDraftLoaded) return; // evita pisar el borrador mientras aún se está restaurando
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(milliseconds: 600), _saveDraftNow);
  }

  Future<void> _saveDraftNow() async {
    try {
      final userId = AppLocator.auth.currentUserId;
      final draft = ProductDraft(
        name: nameController.text,
        description: descriptionController.text,
        brand: brandController.text,
        price: priceController.text,
        quantity: quantityController.text,
        category: selectedCategory,
        imageUrl: selectedImageUrl,
      );
      await AppLocator.productDraft.saveDraft(userId, draft);
    } catch (_) {
      // Sin sesión activa u otro error transitorio: no es crítico perder un autoguardado puntual.
    }
  }

  Future<void> _clearDraft() async {
    try {
      await AppLocator.productDraft.clearDraft(AppLocator.auth.currentUserId);
    } catch (_) {
      // No pasa nada si falla; el formulario ya se limpió visualmente.
    }
  }

  // Se dispara cuando el sistema manda la app a segundo plano, la cierra, o
  // el usuario la minimiza — así el borrador no depende solo de dispose().
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _saveDraftNow();
    }
  }

  @override
  void dispose() {
    // Se dispara al cambiar de pestaña (el BottomNavigationBar de MainScreen
    // reconstruye las pantallas en vez de solo ocultarlas), así que este es
    // el momento clave para no perder lo que el vendedor ya escribió.
    _autosaveTimer?.cancel();
    _saveDraftNow();

    WidgetsBinding.instance.removeObserver(this);
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    quantityController.dispose();
    brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Agregar Producto", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("INFORMACIÓN DEL PRODUCTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nombre del producto", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Text("Tipo de producto: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: [
                      "Accesorio dispositivos móviles",
                      "Herramienta de cocina",
                      "Herramienta de obra",
                      "Pintura",
                      "Perfume",
                      "Electrodoméstico"
                    ].map((String value) => DropdownMenuItem(value: value, child: Text(value, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                      _scheduleAutosave();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text("IMAGEN DEL PRODUCTO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _selectImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: selectedImageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(selectedImageUrl, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Toca para seleccionar imagen", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: brandController,
              decoration: const InputDecoration(labelText: "Marca", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Descripción", border: OutlineInputBorder(), alignLabelWithHint: true),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Cantidad", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: "Precio", prefixText: "\$ ", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Guardar Producto", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectImage() {
    if (sampleImages.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Seleccionar Imagen"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: sampleImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImageUrl = sampleImages[index];
                    });
                    _scheduleAutosave();
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(sampleImages[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ],
        ),
      );
    } else {
      _pickAndUploadFromDevice();
    }
  }

  Future<void> _pickAndUploadFromDevice() async {
    try {
      setState(() => isLoading = true);

      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (picked == null) return;

      final file = File(picked.path);
      final path = 'products/${AppLocator.auth.currentUserId}/${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final ref = FirebaseStorage.instance.ref().child(path);

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      setState(() => selectedImageUrl = url);
      _scheduleAutosave();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen subida correctamente'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo subir la imagen: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _saveProduct() async {
    if (nameController.text.isEmpty || descriptionController.text.isEmpty ||
        priceController.text.isEmpty || quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final product = Product(
        id: '',
        name: nameController.text,
        category: selectedCategory,
        description: descriptionController.text,
        brand: brandController.text,
        price: double.parse(priceController.text),
        quantity: int.parse(quantityController.text),
        imageUrl: selectedImageUrl,
        userId: AppLocator.auth.currentUserId,
        createdAt: DateTime.now(),
      );

      await AppLocator.products.addProduct(product);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Producto agregado exitosamente"), backgroundColor: Colors.green),
      );

      await _clearForm();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e"), backgroundColor: Colors.red),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _clearForm() async {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    quantityController.clear();
    brandController.clear();
    setState(() {
      selectedImageUrl = "";
    });
    // Producto ya guardado en Firestore: el borrador local ya no sirve de nada.
    await _clearDraft();
  }
}
