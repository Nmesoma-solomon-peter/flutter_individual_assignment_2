import '../../models/note.dart';

abstract class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  NotesLoaded(this.notes);
}

class NotesError extends NotesState {
  final String message;
  NotesError(this.message);
}

class NoteOperationSuccess extends NotesState {
  final String message;
  NoteOperationSuccess(this.message);
} 