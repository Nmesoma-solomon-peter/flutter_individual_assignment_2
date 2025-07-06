import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note.dart';

class NoteRepository {
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  FirebaseFirestore get _firebaseFirestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  FirebaseAuth get _firebaseAuth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  // Get current user ID
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  // Fetch all notes for the current user
  Future<List<Note>> fetchNotes() async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final querySnapshot = await _firebaseFirestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Note.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  // Add a new note
  Future<void> addNote(String text) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final note = Note(
        id: '',
        text: text,
        createdAt: now,
        updatedAt: now,
        userId: userId,
      );

      await _firebaseFirestore.collection('notes').add(note.toMap());
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  // Update an existing note
  Future<void> updateNote(String id, String text) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firebaseFirestore.collection('notes').doc(id).update({
        'text': text,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firebaseFirestore.collection('notes').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
} 