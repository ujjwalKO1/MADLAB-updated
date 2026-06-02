import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';

class EventProvider extends ChangeNotifier {
  // Singleton pattern implementation
  static final EventProvider _instance = EventProvider._internal();

  factory EventProvider() {
    return _instance;
  }

  EventProvider._internal() {
    // Pre-populate with one registered event for high-fidelity presentation
    _registeredEventIds.add('1');
    fetchEvents();
  }

  final String _baseUrl = 'http://localhost:5000/api';
  final List<EventModel> _events = [];
  final Set<String> _registeredEventIds = {};

  String? _adminToken;
  String? _adminEmail;

  List<EventModel> get events => List.unmodifiable(_events);

  List<EventModel> get registeredEvents =>
      _events.where((e) => _registeredEventIds.contains(e.id)).toList();

  String? get adminToken => _adminToken;
  String? get adminEmail => _adminEmail;
  bool get isAdminLoggedIn => _adminToken != null;

  bool isRegistered(String eventId) => _registeredEventIds.contains(eventId);

  void registerForEvent(String eventId) {
    if (!_registeredEventIds.contains(eventId)) {
      _registeredEventIds.add(eventId);
      notifyListeners();
    }
  }

  void unregisterFromEvent(String eventId) {
    if (_registeredEventIds.contains(eventId)) {
      _registeredEventIds.remove(eventId);
      notifyListeners();
    }
  }

  Future<void> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/events'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _events.clear();
        _events.addAll(data.map((item) => EventModel(
          id: item['id'],
          name: item['name'],
          clubName: item['clubName'],
          applicationType: item['applicationType'],
          formLink: item['formLink'],
          imagePath: item['imagePath'],
        )));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching events: $e');
    }
  }

  Future<bool> loginAdmin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _adminToken = data['token'];
        _adminEmail = data['email'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  void logoutAdmin() {
    _adminToken = null;
    _adminEmail = null;
    notifyListeners();
  }

  Future<bool> addEvent(EventModel event) async {
    if (_adminToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_adminToken',
        },
        body: jsonEncode({
          'name': event.name,
          'clubName': event.clubName,
          'applicationType': event.applicationType,
          'formLink': event.formLink,
          'imagePath': event.imagePath,
        }),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newEvent = EventModel(
          id: data['id'],
          name: data['name'],
          clubName: data['clubName'],
          applicationType: data['applicationType'],
          formLink: data['formLink'],
          imagePath: data['imagePath'],
        );
        _events.insert(0, newEvent);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding event: $e');
      return false;
    }
  }

  List<EventModel> searchEvents(String query) {
    if (query.isEmpty) return events;
    final lowerQuery = query.toLowerCase();
    return _events
        .where((e) =>
            e.name.toLowerCase().contains(lowerQuery) ||
            e.clubName.toLowerCase().contains(lowerQuery))
        .toList();
  }

  List<EventModel> filterByType(String type) {
    if (type == 'All') return events;
    return _events.where((e) => e.applicationType == type).toList();
  }

  List<EventModel> filterByClub(String clubName) {
    return _events.where((e) => e.clubName == clubName).toList();
  }

  List<String> get clubNames =>
      _events.map((e) => e.clubName).toSet().toList()..sort();
}
