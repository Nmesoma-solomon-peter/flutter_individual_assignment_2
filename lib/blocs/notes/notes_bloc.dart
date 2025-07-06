import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/note_repository.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository _noteRepository;

  NotesBloc({required NoteRepository noteRepository})
      : _noteRepository = noteRepository,
        super(NotesInitial()) {
    on<FetchNotesEvent>(_onFetchNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
  }

  Future<void> _onFetchNotes(
      FetchNotesEvent event, Emitter<NotesState> emit) async {
    emit(NotesLoading());
    try {
      final notes = await _noteRepository.fetchNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NotesState> emit) async {
    try {
      await _noteRepository.addNote(event.text);
      emit(NoteOperationSuccess('Note added successfully!'));
      // Fetch updated notes
      final notes = await _noteRepository.fetchNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onUpdateNote(
      UpdateNoteEvent event, Emitter<NotesState> emit) async {
    try {
      await _noteRepository.updateNote(event.id, event.text);
      emit(NoteOperationSuccess('Note updated successfully!'));
      // Fetch updated notes
      final notes = await _noteRepository.fetchNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }

  Future<void> _onDeleteNote(
      DeleteNoteEvent event, Emitter<NotesState> emit) async {
    try {
      await _noteRepository.deleteNote(event.id);
      emit(NoteOperationSuccess('Note deleted successfully!'));
      // Fetch updated notes
      final notes = await _noteRepository.fetchNotes();
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError(e.toString()));
    }
  }
} 