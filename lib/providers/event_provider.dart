import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventProvider extends ChangeNotifier {
  // Singleton pattern implementation
  static final EventProvider _instance = EventProvider._internal();

  factory EventProvider() {
    return _instance;
  }

  EventProvider._internal() {
    // Check if Firebase was successfully initialized
    if (Firebase.apps.isNotEmpty) {
      // Sync events in real-time from Cloud Firestore
      FirebaseFirestore.instance.collection('events')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isEmpty) {
          _seedDefaultEvents();
          return;
        }
        
        _events.clear();
        for (var doc in snapshot.docs) {
          final data = doc.data();
          _events.add(EventModel(
            id: doc.id,
            name: data['name'] ?? '',
            clubName: data['clubName'] ?? '',
            applicationType: data['applicationType'] ?? 'Registration',
            formLink: data['formLink'] ?? '',
            imagePath: data['imagePath'] ?? 'assets/images/event_hackathon.png',
            createdAt: data['createdAt'] != null
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
          ));
        }
        notifyListeners();
      }, onError: (error) {
        debugPrint("Firestore listener error: $error");
        _loadLocalMockEvents();
      });

      // Sync registrations/tickets in real-time from Firestore
      FirebaseFirestore.instance.collection('registrations')
          .snapshots()
          .listen((snapshot) {
        _registeredEventIds.clear();
        for (var doc in snapshot.docs) {
          _registeredEventIds.add(doc.id);
        }
        notifyListeners();
      }, onError: (error) {
        debugPrint("Firestore registrations listener error: $error");
      });
    } else {
      // Fallback: If Firebase failed to initialize (e.g. adblocker / offline), load locally
      _loadLocalMockEvents();
    }
  }

  final List<EventModel> _events = [];
  final Set<String> _registeredEventIds = {};

  List<EventModel> get events => List.unmodifiable(_events);

  List<EventModel> get registeredEvents =>
      _events.where((e) => _registeredEventIds.contains(e.id)).toList();

  bool isRegistered(String eventId) => _registeredEventIds.contains(eventId);

  void registerForEvent(String eventId) {
    if (!_registeredEventIds.contains(eventId)) {
      _registeredEventIds.add(eventId);
      notifyListeners();
      
      if (Firebase.apps.isNotEmpty) {
        FirebaseFirestore.instance.collection('registrations').doc(eventId).set({
          'registeredAt': FieldValue.serverTimestamp(),
        }).catchError((error) {
          debugPrint("Error writing registration to Firestore: $error");
        });
      }
    }
  }

  void unregisterFromEvent(String eventId) {
    if (_registeredEventIds.contains(eventId)) {
      _registeredEventIds.remove(eventId);
      notifyListeners();
      
      if (Firebase.apps.isNotEmpty) {
        FirebaseFirestore.instance.collection('registrations').doc(eventId).delete().catchError((error) {
          debugPrint("Error deleting registration from Firestore: $error");
        });
      }
    }
  }

  void addEvent(EventModel event) {
    _events.insert(0, event);
    notifyListeners();
    
    if (Firebase.apps.isNotEmpty) {
      FirebaseFirestore.instance.collection('events').doc(event.id).set({
        'name': event.name,
        'clubName': event.clubName,
        'applicationType': event.applicationType,
        'formLink': event.formLink,
        'imagePath': event.imagePath,
        'createdAt': FieldValue.serverTimestamp(),
      }).catchError((error) {
        debugPrint("Error adding event to Firestore: $error");
      });
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

  void _loadLocalMockEvents() {
    _events.clear();
    _events.addAll([
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
    ]);
    _registeredEventIds.add('1'); // pre-populate one registration
  }

  void _seedDefaultEvents() {
    final defaults = [
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
    
    for (var e in defaults) {
      FirebaseFirestore.instance.collection('events').doc(e.id).set({
        'name': e.name,
        'clubName': e.clubName,
        'applicationType': e.applicationType,
        'formLink': e.formLink,
        'imagePath': e.imagePath,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
