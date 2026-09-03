import 'package:flutter/foundation.dart';
import '../models/contact_model.dart';
import '../services/chat_service.dart';

/// State controller managing contacts directory, filtering, and selection.
class ContactsController extends ChangeNotifier {
  final ChatService _chatService;

  List<ContactModel> _allContacts = [];
  String _searchQuery = '';
  bool _isLoading = false;

  ContactsController(this._chatService) {
    loadContacts();
  }

  List<ContactModel> get contacts {
    if (_searchQuery.trim().isEmpty) {
      return _allContacts;
    }
    final query = _searchQuery.toLowerCase().trim();
    return _allContacts.where((c) {
      return c.name.toLowerCase().contains(query) ||
          c.status.toLowerCase().contains(query) ||
          c.roleOrTag.toLowerCase().contains(query);
    }).toList();
  }

  List<ContactModel> get onlineContacts => _allContacts.where((c) => c.isOnline).toList();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    if (query.trim().length >= 2) {
      _chatService.searchUsers(query).then((results) {
        if (_searchQuery == query && results.isNotEmpty) {
          _allContacts = results;
          notifyListeners();
        }
      });
    }
  }

  void clearSearch() {
    _searchQuery = '';
    loadContacts();
  }

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();
    _allContacts = await _chatService.getContacts();
    _isLoading = false;
    notifyListeners();
  }
}
