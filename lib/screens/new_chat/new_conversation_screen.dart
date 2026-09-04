import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/contacts_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../models/contact_model.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/responsive_shell.dart';
import '../../widgets/search_field.dart';
import '../chat/chat_screen.dart';

/// Screen 8 — New Conversation / Contact Picker matching reference layout.
class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({super.key});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  String? _selectedContactId;

  Future<void> _startChatWith(ContactModel contact) async {
    final chatCtrl = context.read<ChatController>();
    final conv = await chatCtrl.startChatWithContact(contact);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsCtrl = context.watch<ContactsController>();
    final contacts = contactsCtrl.contacts;

    // Auto-select first contact if none selected
    if (_selectedContactId == null && contacts.isNotEmpty) {
      _selectedContactId = contacts.first.id;
    }

    final selectedContact = contacts.cast<ContactModel?>().firstWhere(
      (c) => c?.id == _selectedContactId,
      orElse: () => contacts.isNotEmpty ? contacts.first : null,
    );

    return ResponsiveShell(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            AppStrings.newConversation,
            style: AppTypography.titleLarge,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.group_add_rounded, color: AppColors.primaryCyan),
              tooltip: 'New Group',
              onPressed: () => _showCreateGroupDialog(context, contacts),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: SearchField(
                  hintText: AppStrings.searchContacts,
                  onChanged: (q) => contactsCtrl.setSearchQuery(q),
                  onClear: () => contactsCtrl.clearSearch(),
                ),
              ),
              Expanded(
                child: contacts.isEmpty
                    ? const EmptyState(
                        icon: Icons.person_search_rounded,
                        title: AppStrings.noContactsFound,
                        description: AppStrings.noContactsFoundDesc,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: contacts.length,
                        separatorBuilder: (_, _) => Divider(
                          color: AppColors.surfaceBorder.withValues(alpha: 0.3),
                          indent: 72,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          final isSelected = _selectedContactId == contact.id;

                          return ListTile(
                            onTap: () {
                              setState(() => _selectedContactId = contact.id);
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            leading: CustomAvatar(
                              name: contact.name,
                              radius: 24,
                              isOnline: contact.isOnline,
                              showOnlineIndicator: true,
                              gradientIndex: contact.avatarGradientIndex,
                            ),
                            title: Text(
                              contact.name,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              contact.status,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isSelected ? AppColors.primaryGradient : null,
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: const Color(0xFF1E3A4C),
                                        width: 1.5,
                                      ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),

              // Bottom "Start Chat" Action Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.surfaceBorder.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: PrimaryButton(
                    text: AppStrings.startChat,
                    height: 52,
                    onPressed: selectedContact != null
                        ? () => _startChatWith(selectedContact)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, List<ContactModel> contacts) {
    final titleController = TextEditingController();
    final selectedContacts = <ContactModel>[];
    final chatCtrl = context.read<ChatController>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedL),
              title: const Text('Create New Group', style: AppTypography.titleLarge),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Group Name',
                        hintText: 'e.g. Design Team',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Members:', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: contacts.length,
                        itemBuilder: (_, idx) {
                          final c = contacts[idx];
                          final isSelected = selectedContacts.contains(c);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(c.name, style: const TextStyle(color: AppColors.textPrimary)),
                            subtitle: Text(c.roleOrTag, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                            activeColor: AppColors.primaryCyan,
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedContacts.add(c);
                                } else {
                                  selectedContacts.remove(c);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please provide a group name')),
                      );
                      return;
                    }
                    if (selectedContacts.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one contact')),
                      );
                      return;
                    }
                    Navigator.pop(dialogCtx);
                    final groupConv = await chatCtrl.createGroupChat(
                      title: title,
                      participants: selectedContacts,
                    );
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(conversation: groupConv),
                        ),
                      );
                    }
                  },
                  child: const Text('Create', style: TextStyle(color: AppColors.primaryCyan, fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
