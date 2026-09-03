import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/contacts_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/responsive_shell.dart';
import '../../widgets/search_field.dart';
import '../../models/contact_model.dart';
import '../chat/chat_screen.dart';

/// Screen 8 — New Conversation / Contact Picker.
class NewConversationScreen extends StatelessWidget {
  const NewConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contactsCtrl = context.watch<ContactsController>();
    final chatCtrl = context.read<ChatController>();
    final contacts = contactsCtrl.contacts;

    return ResponsiveShell(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            AppStrings.newConversation,
            style: AppTypography.titleLarge,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          color: AppColors.divider.withValues(alpha: 0.06),
                          indent: 72,
                        ),
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          return ListTile(
                            onTap: () async {
                              final conv = await chatCtrl.startChatWithContact(contact);
                              if (!context.mounted) return;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(conversation: conv),
                                ),
                              );
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHighlight.withValues(alpha: 0.6),
                                borderRadius: AppRadius.roundedFull,
                                border: Border.all(
                                  color: AppColors.surfaceBorder.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                contact.roleOrTag,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
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
                      Navigator.of(context).pushReplacement(
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
