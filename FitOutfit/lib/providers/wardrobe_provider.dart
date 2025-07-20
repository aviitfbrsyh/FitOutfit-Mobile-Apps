import 'package:flutter/material.dart';
import '../models/wardrobe_item.dart';

class WardrobeProvider extends ChangeNotifier {
  final List<WardrobeItem> _items = [];

  List<WardrobeItem> get items => List.unmodifiable(_items);

  void add(WardrobeItem item) {
    _items.add(item);
    notifyListeners();
  }
}
