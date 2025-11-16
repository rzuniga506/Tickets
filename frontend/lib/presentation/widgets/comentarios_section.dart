import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/comentarios/comentario_cubit.dart';
import '../../logic/comentarios/comentario_state.dart';
import '../../data/models/user/user_model.dart';
import '../../config/theme.dart';
import 'comentario_card.dart';

/// Sección completa de comentarios con input y lista
class ComentariosSection extends StatefulWidget {
  final int ticketId;
  final int currentUserId;
  final List<UserModel> availableUsers; // Usuarios disponibles para mencionar

  const ComentariosSection({
    super.key,
    required this.ticketId,
    required this.currentUserId,
    this.availableUsers = const [],
  });

  @override
  State<ComentariosSection> createState() => _ComentariosSectionState();
}

class _ComentariosSectionState extends State<ComentariosSection> {
  final TextEditingController _comentarioController = TextEditingController();
  final FocusNode _comentarioFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  
  OverlayEntry? _overlayEntry;
  List<UserModel> _filteredUsers = [];
  int _selectedUserIndex = 0;
  String _currentMention = '';
  int _mentionStartPosition = 0;
  bool _isSelectingFromOverlay = false;

  @override
  void initState() {
    super.initState();
    _loadComentarios();
    _comentarioController.addListener(_onTextChanged);
    _comentarioFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _comentarioController.removeListener(_onTextChanged);
    _comentarioFocusNode.removeListener(_onFocusChanged);
    _comentarioController.dispose();
    _comentarioFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadComentarios() {
    context.read<ComentarioCubit>().getComentariosByTicketId(
          ticketId: widget.ticketId,
        );
  }

  void _onTextChanged() {
    final text = _comentarioController.text;
    final cursorPosition = _comentarioController.selection.baseOffset;

    // Buscar @ antes del cursor
    int atPosition = -1;
    for (int i = cursorPosition - 1; i >= 0; i--) {
      if (text[i] == '@') {
        atPosition = i;
        break;
      } else if (text[i] == ' ' || text[i] == '\n') {
        break;
      }
    }

    if (atPosition != -1) {
      // Hay un @ activo
      _mentionStartPosition = atPosition;
      _currentMention = text.substring(atPosition + 1, cursorPosition);
      _filterUsers(_currentMention);
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onFocusChanged() {
    if (!_comentarioFocusNode.hasFocus && !_isSelectingFromOverlay) {
      // Delay para permitir que el onTap se ejecute antes de remover el overlay
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_isSelectingFromOverlay) {
          _removeOverlay();
        }
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = widget.availableUsers.take(5).toList();
      } else {
        _filteredUsers = widget.availableUsers
            .where((user) =>
                user.nombreCompleto.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase()))
            .take(5)
            .toList();
      }
      _selectedUserIndex = 0;
    });
  }

  void _showOverlay() {
    if (_filteredUsers.isEmpty) {
      _removeOverlay();
      return;
    }

    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 160,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.greyLight),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                final isSelected = index == _selectedUserIndex;

                return ListTile(
                  dense: true,
                  selected: isSelected,
                  selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      user.nombreCompleto[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user.nombreCompleto,
                    style: const TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    user.email,
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () => _selectUser(user),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectUser(UserModel user) {
    _isSelectingFromOverlay = true;

    final text = _comentarioController.text;
    final beforeMention = text.substring(0, _mentionStartPosition);
    final afterMention = text.substring(_comentarioController.selection.baseOffset);

    final newText = '$beforeMention@${user.nombreCompleto.replaceAll(' ', '')} $afterMention';

    _comentarioController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: beforeMention.length + user.nombreCompleto.replaceAll(' ', '').length + 2,
      ),
    );

    _removeOverlay();

    // Devolver el foco al campo de texto
    _comentarioFocusNode.requestFocus();

    // Reset flag después de un delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _isSelectingFromOverlay = false;
    });
  }

  void _handleSubmit() {
    if (_comentarioController.text.trim().isEmpty) return;

    final contenido = _comentarioController.text.trim();
    
    // Extraer IDs de usuarios mencionados
    final usuariosIdMencionados = _extractMentionedUserIds(contenido);

    context.read<ComentarioCubit>().createComentario(
          ticketId: widget.ticketId,
          contenido: contenido,
          usuariosIdMencionados: usuariosIdMencionados,
        );

    _comentarioController.clear();
  }

  List<int> _extractMentionedUserIds(String contenido) {
    final mentionedIds = <int>[];
    final mentionPattern = RegExp(r'@(\S+)');
    final matches = mentionPattern.allMatches(contenido);

    for (final match in matches) {
      final mentionText = match.group(1);
      if (mentionText != null) {
        // Buscar usuario por nombre sin espacios
        final user = widget.availableUsers.firstWhere(
          (u) => u.nombreCompleto.replaceAll(' ', '').toLowerCase() == 
                 mentionText.toLowerCase(),
          orElse: () => widget.availableUsers.first, // fallback
        );
        
        if (!mentionedIds.contains(user.id)) {
          mentionedIds.add(user.id);
        }
      }
    }

    return mentionedIds;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.comment, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Comentarios',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _loadComentarios,
              tooltip: 'Recargar comentarios',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Input de comentario
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.greyLight),
          ),
          child: Column(
            children: [
              TextField(
                controller: _comentarioController,
                focusNode: _comentarioFocusNode,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Escribe un comentario... (usa @ para mencionar)',
                  hintStyle: TextStyle(color: AppTheme.greyDark, fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Presiona @ para mencionar usuarios',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.greyDark,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 12),
                  BlocBuilder<ComentarioCubit, ComentarioState>(
                    builder: (context, state) {
                      final isLoading = state is ComentarioActionLoading;
                      
                      return ElevatedButton.icon(
                        onPressed: isLoading ? null : _handleSubmit,
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.send, size: 16),
                        label: const Text('Enviar'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Lista de comentarios
        BlocConsumer<ComentarioCubit, ComentarioState>(
          listener: (context, state) {
            if (state is ComentarioError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            } else if (state is ComentarioCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comentario agregado'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ComentariosLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state is ComentariosLoaded) {
              final comentarios = state.comentarios.items;

              if (comentarios.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: AppTheme.greyLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay comentarios aún',
                          style: TextStyle(
                            color: AppTheme.greyDark,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sé el primero en comentar',
                          style: TextStyle(
                            color: AppTheme.greyDark,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comentarios.length,
                itemBuilder: (context, index) {
                  final comentario = comentarios[index];
                  return ComentarioCard(
                    comentario: comentario,
                    currentUserId: widget.currentUserId,
                    onEdit: () {
                      // TODO: Implementar edición
                    },
                    onDelete: () {
                      _showDeleteDialog(comentario.id);
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _showDeleteDialog(int comentarioId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text('¿Estás seguro de que deseas eliminar este comentario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ComentarioCubit>().deleteComentario(
                    id: comentarioId,
                    ticketId: widget.ticketId,
                  );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
