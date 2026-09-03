import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/contacts_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../models/conversation_model.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/chat_list_tile.dart';
import '../../widgets/custom_avatar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/search_field.dart';
import '../chat/chat_screen.dart';
import '../new_chat/new_conversation_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

/// Screen 7 — Home Screen containing the Chats List, Online Tray, and Bottom Navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTabIndex = 0;
  bool _isSearchExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    // In desktop mode, display dual-pane layout
    if (isDesktop) {
      return _buildDesktopLayout();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildChatsTab(),
          const _ContactsTab(),
          const ProfileScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NewConversationScreen()),
                );
              },
              backgroundColor: AppColors.primaryCyan,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 6,
              icon: const Icon(Icons.add_comment_rounded, size: 20),
              label: const Text(
                AppStrings.newChat,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }

  Widget _buildChatsTab() {
    final chatCtrl = context.watch<ChatController>();
    final authCtrl = context.watch<AuthController>();
    final contactsCtrl = context.watch<ContactsController>();
    final conversations = chatCtrl.conversations;
    final onlineContacts = contactsCtrl.onlineContacts;

    return SafeArea(
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const AppLogo(
                      size: 38,
                      showText: false,
                      showTagline: false,
                      isAnimated: false,
                    ),
                    const SizedBox(width: 12),
                    ShaderMask(
                      shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                      child: const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isSearchExpanded ? Icons.close_rounded : Icons.search_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearchExpanded = !_isSearchExpanded;
                          if (!_isSearchExpanded) {
                            chatCtrl.clearSearch();
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    CustomAvatar(
                      name: authCtrl.currentUser?.name ?? 'Alex Morgan',
                      radius: 18,
                      isOnline: true,
                      showOnlineIndicator: true,
                      onTap: () => setState(() => _selectedTabIndex = 2),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Field
          if (_isSearchExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: SearchField(
                hintText: AppStrings.searchConversations,
                onChanged: (q) => chatCtrl.setSearchQuery(q),
                onClear: () => chatCtrl.clearSearch(),
              ),
            ),

          // Online Contacts Tray (Horizontal Row)
          if (onlineContacts.isNotEmpty && !_isSearchExpanded) ...[
            SizedBox(
              height: 94,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: onlineContacts.length,
                itemBuilder: (context, index) {
                  final contact = onlineContacts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTap: () async {
                        final conv = await chatCtrl.startChatWithContact(contact);
                        if (!context.mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(conversation: conv),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.primaryGradient,
                            ),
                            child: CustomAvatar(
                              name: contact.name,
                              radius: 24,
                              isOnline: true,
                              showOnlineIndicator: true,
                              gradientIndex: contact.avatarGradientIndex,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 60,
                            child: Text(
                              contact.name.split(' ').first,
                              textAlign: TextAlign.center,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
          ],

          // Chat List View
          Expanded(
            child: conversations.isEmpty
                ? EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: AppStrings.noConversationsTitle,
                    description: AppStrings.noConversationsDesc,
                    actionText: AppStrings.startChat,
                    onAction: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NewConversationScreen()),
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conv = conversations[index];
                      return ChatListTile(
                        conversation: conv,
                        onTap: () {
                          chatCtrl.selectConversation(conv);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(conversation: conv),
                            ),
                          );
                        },
                        onLongPress: () => _showChatOptionsModal(context, conv),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showChatOptionsModal(BuildContext context, ConversationModel conv) {
    final chatCtrl = context.read<ChatController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    conv.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                    color: AppColors.primaryCyan,
                  ),
                  title: Text(conv.isPinned ? 'Unpin conversation' : 'Pin to top'),
                  onTap: () {
                    Navigator.pop(ctx);
                    chatCtrl.togglePin(conv.id);
                  },
                ),
                ListTile(
                  leading: Icon(
                    conv.isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    color: AppColors.textSecondary,
                  ),
                  title: Text(conv.isMuted ? 'Unmute notifications' : 'Mute notifications'),
                  onTap: () {
                    Navigator.pop(ctx);
                    chatCtrl.toggleMute(conv.id);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  title: const Text('Delete chat', style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(ctx);
                    chatCtrl.deleteConversation(conv.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    final chatCtrl = context.watch<ChatController>();
    final unread = chatCtrl.totalUnreadCount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder.withValues(alpha: 0.5), width: 1),
        ),
      ),
      child: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) => setState(() => _selectedTabIndex = index),
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.primaryCyan.withValues(alpha: 0.18),
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              backgroundColor: AppColors.primaryCyan,
              textColor: AppColors.textOnPrimary,
              child: const Icon(Icons.chat_bubble_outline_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              backgroundColor: AppColors.primaryCyan,
              textColor: AppColors.textOnPrimary,
              child: const Icon(Icons.chat_bubble_rounded, color: AppColors.primaryCyan),
            ),
            label: AppStrings.chatsTab,
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded, color: AppColors.primaryCyan),
            label: AppStrings.contactsTab,
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryCyan),
            label: AppStrings.profileTab,
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: AppColors.primaryCyan),
            label: AppStrings.settingsTab,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    final chatCtrl = context.watch<ChatController>();
    final selectedConv = chatCtrl.selectedConversation;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: Row(
        children: [
          // Left Pane (Chats List & Tabs)
          SizedBox(
            width: 380,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  right: BorderSide(color: AppColors.surfaceBorder.withValues(alpha: 0.6), width: 1),
                ),
              ),
              child: _buildChatsTab(),
            ),
          ),
          // Right Pane (Active Conversation or Empty Desktop View)
          Expanded(
            child: selectedConv != null
                ? ChatScreen(conversation: selectedConv, isEmbedded: true)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppLogo(size: 64, showText: true, showTagline: true),
                        const SizedBox(height: 24),
                        Text(
                          'Select a conversation to start chatting',
                          style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Contacts Tab embedded inside Bottom Navigation.
class _ContactsTab extends StatelessWidget {
  const _ContactsTab();

  @override
  Widget build(BuildContext context) {
    final contactsCtrl = context.watch<ContactsController>();
    final chatCtrl = context.read<ChatController>();
    final contacts = contactsCtrl.contacts;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              AppStrings.contactsTab,
              style: AppTypography.displayMedium.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return ListTile(
                        onTap: () async {
                          final conv = await chatCtrl.startChatWithContact(contact);
                          if (!context.mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)),
                          );
                        },
                        leading: CustomAvatar(
                          name: contact.name,
                          radius: 22,
                          isOnline: contact.isOnline,
                          showOnlineIndicator: true,
                          gradientIndex: contact.avatarGradientIndex,
                        ),
                        title: Text(
                          contact.name,
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          contact.status,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHighlight,
                            borderRadius: AppRadius.roundedFull,
                          ),
                          child: Text(
                            contact.roleOrTag,
                            style: const TextStyle(fontSize: 10, color: AppColors.primaryLight),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
