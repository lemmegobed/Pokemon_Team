import 'package:flutter/material.dart';
import 'home.dart'; // เพื่อใช้ Product model
import 'package:http/http.dart' as http;
import 'dart:convert';

// ตั้งค่า POCKETBASE URL (ควรกำหนดในไฟล์ constants.dart เพื่อไม่ให้เกิดการซ้ำซ้อน)
const String POCKETBASE_URL = 'http://127.0.0.1:8090';

class ProductEditPage extends StatefulWidget {
  final Product product;
  const ProductEditPage({super.key, required this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _imageUrlController = TextEditingController(text: widget.product.imageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('$POCKETBASE_URL/api/collections/product/records/${widget.product.id}');
      final body = json.encode({
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'imageUrl': _imageUrlController.text,
      });

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product updated successfully!'), backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update: ${response.body}'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)], // สีม่วงไล่เฉด
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'แก้ไขสินค้า',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField(
                controller: _nameController,
                labelText: 'ชื่อสินค้า',
                icon: Icons.label_important_outline,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _priceController,
                labelText: 'ราคา',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || double.tryParse(value) == null) ? 'กรุณาป้อนราคาที่ถูกต้อง' : null,
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _imageUrlController,
                labelText: 'URL รูปภาพ',
                icon: Icons.image_outlined,
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _updateProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: const Color(0xFF6A1B9A), // สีปุ่ม
                    foregroundColor: Colors.white,
                    elevation: 5,
                  ),
                  child: const Text('บันทึกการเปลี่ยนแปลง', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: const Color(0xFF6A1B9A)),
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
        ),
      ),
    );
  }
}