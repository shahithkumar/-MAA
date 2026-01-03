// lib/screens/category_selection.dart (NEW FILE)
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/affirmation.dart';
import 'affirmations_swipe.dart';

class CategorySelectionScreen extends StatefulWidget {
  @override
  _CategorySelectionScreenState createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<AffirmationCategory> categories = [];
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    try {
      final apiService = ApiService();
      final categoryData = await apiService.getAffirmationCategories();
      setState(() {
        categories = categoryData.map((json) => AffirmationCategory.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose Category')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Text(
                      category.icon,
                      style: TextStyle(fontSize: 30),
                    ),
                    title: Text(category.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(category.description ?? ''),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AffirmationsSwipeScreen(categoryId: category.id),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}