import 'package:flutter/material.dart';
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
  }

  final List<EventModel> _events = [
    EventModel(
      id: '1',
      name: 'HackFusion 2026',
      clubName: 'Tech Club',
      applicationType: 'Registration',
      formLink: 'https://forms.google.com/hackfusion',
      imagePath: 'assets/images/event_hackathon.png',
    ),
    EventModel(
      id: '2',
      name: 'Rhythm & Beats Fest',
      clubName: 'Music Society',
      applicationType: 'Registration',
      formLink: 'https://forms.google.com/musicfest',
      imagePath: 'assets/images/event_music.png',
    ),
    EventModel(
      id: '3',
      name: 'Campus Marathon 5K',
      clubName: 'Sports Club',
      applicationType: 'Volunteering',
      formLink: 'https://forms.google.com/marathon',
      imagePath: 'assets/images/event_sports.png',
    ),
    EventModel(
      id: '4',
      name: 'Creative Canvas Workshop',
      clubName: 'Art Circle',
      applicationType: 'Volunteering',
      formLink: 'https://forms.google.com/artworkshop',
      imagePath: 'assets/images/event_art.png',
    ),
  ];

  final Set<String> _registeredEventIds = {};

  List<EventModel> get events => List.unmodifiable(_events);

  List<EventModel> get registeredEvents =>
      _events.where((e) => _registeredEventIds.contains(e.id)).toList();

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

  void addEvent(EventModel event) {
    _events.insert(0, event);
    notifyListeners();
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
