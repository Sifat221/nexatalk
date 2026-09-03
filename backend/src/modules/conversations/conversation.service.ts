import prisma from '../../prisma/client';

export class ConversationService {
  async listConversations(userId: string) {
    const memberships = await prisma.conversationMember.findMany({
      where: { userId },
      include: {
        conversation: {
          include: {
            members: {
              include: {
                user: {
                  select: {
                    id: true,
                    username: true,
                    displayName: true,
                    avatarUrl: true,
                    status: true,
                    isOnline: true,
                    lastSeenAt: true,
                  },
                },
              },
            },
            messages: {
              take: 1,
              orderBy: { createdAt: 'desc' },
              include: {
                reactions: true,
              },
            },
          },
        },
      },
      orderBy: [
        { isPinned: 'desc' },
        { conversation: { updatedAt: 'desc' } },
      ],
    });

    const result = await Promise.all(
      memberships.map(async (m) => {
        const conv = m.conversation;
        const lastMessage = conv.messages[0] || null;

        // Calculate unread count
        let unreadCount = 0;
        if (m.lastReadMessageId) {
          const lastReadMsg = await prisma.message.findUnique({
            where: { id: m.lastReadMessageId },
            select: { createdAt: true },
          });

          if (lastReadMsg) {
            unreadCount = await prisma.message.count({
              where: {
                conversationId: conv.id,
                senderId: { not: userId },
                createdAt: { gt: lastReadMsg.createdAt },
              },
            });
          }
        } else {
          unreadCount = await prisma.message.count({
            where: {
              conversationId: conv.id,
              senderId: { not: userId },
            },
          });
        }

        // For direct chats, extract the other participant
        let otherMember = null;
        if (conv.type === 'DIRECT') {
          const other = conv.members.find((mem) => mem.userId !== userId);
          otherMember = other?.user || null;
        }

        return {
          id: conv.id,
          type: conv.type,
          title: conv.type === 'DIRECT' ? otherMember?.displayName : conv.title,
          avatarUrl: conv.type === 'DIRECT' ? otherMember?.avatarUrl : conv.avatarUrl,
          isPinned: m.isPinned,
          isMuted: m.isMuted,
          role: m.role,
          unreadCount,
          lastMessage: lastMessage
            ? {
                id: lastMessage.id,
                senderId: lastMessage.senderId,
                text: lastMessage.text,
                type: lastMessage.type,
                attachmentUrl: lastMessage.attachmentUrl,
                createdAt: lastMessage.createdAt,
              }
            : null,
          participant: otherMember,
          membersCount: conv.members.length,
          updatedAt: conv.updatedAt,
        };
      })
    );

    return result;
  }

  async createDirectOrGet(userId: string, recipientId: string) {
    if (userId === recipientId) {
      throw { code: 'INVALID_RECIPIENT', message: 'You cannot create a conversation with yourself.', status: 400 };
    }

    // Check blocked status
    const isBlocked = await prisma.blockedUser.findFirst({
      where: {
        OR: [
          { blockerId: userId, blockedId: recipientId },
          { blockerId: recipientId, blockedId: userId },
        ],
      },
    });

    if (isBlocked) {
      throw { code: 'USER_BLOCKED', message: 'Cannot start conversation with a blocked user.', status: 403 };
    }

    // Check if direct conversation already exists between these 2 users
    const existing = await prisma.conversation.findFirst({
      where: {
        type: 'DIRECT',
        AND: [
          { members: { some: { userId } } },
          { members: { some: { userId: recipientId } } },
        ],
      },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                username: true,
                displayName: true,
                avatarUrl: true,
                isOnline: true,
                lastSeenAt: true,
              },
            },
          },
        },
      },
    });

    if (existing) {
      return existing;
    }

    // Verify recipient exists
    const recipient = await prisma.user.findUnique({
      where: { id: recipientId },
    });

    if (!recipient) {
      throw { code: 'RECIPIENT_NOT_FOUND', message: 'Target user does not exist.', status: 404 };
    }

    // Create new direct conversation
    const newConv = await prisma.conversation.create({
      data: {
        type: 'DIRECT',
        members: {
          create: [
            { userId, role: 'ADMIN' },
            { userId: recipientId, role: 'MEMBER' },
          ],
        },
      },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                username: true,
                displayName: true,
                avatarUrl: true,
                isOnline: true,
                lastSeenAt: true,
              },
            },
          },
        },
      },
    });

    return newConv;
  }

  async createGroup(userId: string, title: string, memberIds: string[]) {
    const allMembers = Array.from(new Set([userId, ...memberIds]));

    const newGroup = await prisma.conversation.create({
      data: {
        type: 'GROUP',
        title: title.trim(),
        members: {
          create: allMembers.map((id) => ({
            userId: id,
            role: id === userId ? 'ADMIN' : 'MEMBER',
          })),
        },
      },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                username: true,
                displayName: true,
                avatarUrl: true,
              },
            },
          },
        },
      },
    });

    return newGroup;
  }

  async getConversationById(userId: string, conversationId: string) {
    const conv = await prisma.conversation.findUnique({
      where: { id: conversationId },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                username: true,
                displayName: true,
                avatarUrl: true,
                bio: true,
                status: true,
                isOnline: true,
                lastSeenAt: true,
              },
            },
          },
        },
      },
    });

    if (!conv) {
      throw { code: 'CONVERSATION_NOT_FOUND', message: 'Conversation not found.', status: 404 };
    }

    const membership = conv.members.find((m) => m.userId === userId);
    if (!membership) {
      throw { code: 'UNAUTHORIZED', message: 'You are not a member of this conversation.', status: 403 };
    }

    let otherMember = null;
    if (conv.type === 'DIRECT') {
      const other = conv.members.find((mem) => mem.userId !== userId);
      otherMember = other?.user || null;
    }

    return {
      ...conv,
      isPinned: membership.isPinned,
      isMuted: membership.isMuted,
      participant: otherMember,
    };
  }

  async updateMemberSettings(userId: string, conversationId: string, data: { isPinned?: boolean; isMuted?: boolean }) {
    const membership = await prisma.conversationMember.findUnique({
      where: {
        conversationId_userId: { conversationId, userId },
      },
    });

    if (!membership) {
      throw { code: 'CONVERSATION_NOT_FOUND', message: 'Conversation membership not found.', status: 404 };
    }

    const updated = await prisma.conversationMember.update({
      where: {
        conversationId_userId: { conversationId, userId },
      },
      data: {
        ...(data.isPinned !== undefined ? { isPinned: data.isPinned } : {}),
        ...(data.isMuted !== undefined ? { isMuted: data.isMuted } : {}),
      },
    });

    return updated;
  }

  async deleteOrLeave(userId: string, conversationId: string) {
    const membership = await prisma.conversationMember.findUnique({
      where: {
        conversationId_userId: { conversationId, userId },
      },
      include: { conversation: { include: { members: true } } },
    });

    if (!membership) {
      throw { code: 'CONVERSATION_NOT_FOUND', message: 'Conversation not found.', status: 404 };
    }

    if (membership.conversation.type === 'DIRECT') {
      // In direct conversation, delete conversation entirely
      await prisma.conversation.delete({
        where: { id: conversationId },
      });
    } else {
      // In group, remove membership
      await prisma.conversationMember.delete({
        where: {
          conversationId_userId: { conversationId, userId },
        },
      });

      // If no members left, delete conversation
      if (membership.conversation.members.length <= 1) {
        await prisma.conversation.delete({
          where: { id: conversationId },
        });
      }
    }

    return { success: true, message: 'Conversation removed.' };
  }
}

export default new ConversationService();
