abstract class NotesEvent {}

class FetchNotesEvent extends NotesEvent {}

class AddNoteEvent extends NotesEvent {
  final String text;
  AddNoteEvent(this.text);
}

class UpdateNoteEvent extends NotesEvent {
  final String id;
  final String text;
  UpdateNoteEvent({required this.id, required this.text});
}

class DeleteNoteEvent extends NotesEvent {
  final String id;
  DeleteNoteEvent(this.id);
} 