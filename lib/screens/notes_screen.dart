import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/notes/notes_bloc.dart';
import '../blocs/notes/notes_event.dart';
import '../blocs/notes/notes_state.dart';
import '../constants/colors.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import '../widgets/add_note_dialog.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notes when screen loads
    context.read<NotesBloc>().add(FetchNotesEvent());
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddNoteDialog(),
    );
  }

  void _showEditNoteDialog(Note note) {
    showDialog(
      context: context,
      builder: (context) => AddNoteDialog(note: note),
    );
  }

  void _showDeleteConfirmation(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Note',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this note?',
          style: GoogleFonts.poppins(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotesBloc>().add(DeleteNoteEvent(note.id));
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'My Notes',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutEvent());
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: BlocListener<NotesBloc, NotesState>(
        listener: (context, state) {
          if (state is NoteOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is NotesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: BlocBuilder<NotesBloc, NotesState>(
          builder: (context, state) {
            if (state is NotesLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
                ),
              );
            } else if (state is NotesLoaded) {
              if (state.notes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add,
                        size: 80,
                        color: AppColors.purple.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nothing here yet—tap ➕ to add a note.',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NoteCard(
                      note: note,
                      onEdit: () => _showEditNoteDialog(note),
                      onDelete: () => _showDeleteConfirmation(note),
                    ),
                  );
                },
              );
            } else if (state is NotesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading notes',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: GoogleFonts.poppins(
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NotesBloc>().add(FetchNotesEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        foregroundColor: AppColors.white,
                      ),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.white,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
} 