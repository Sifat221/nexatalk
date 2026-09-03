import prisma from '../../prisma/client';
import { getSocketServer } from '../../socket/socket.server';

export class MessageService {
  async getMessages(userId: string, conversationId: string, limit = 30, cursor?: string) {
    // Verify user is a member
    const membership = await prisma.conversationMember.findUnique({
      where: {
        conversationId_userId: { conversationId, userId },
      },
    });

    if (!membership) {
      throw { code: 'UNAUTHORIZED', message: 'You are not a member of this conversation.', status: 403 };
    }

    const messages = await prisma.message.findMany({
      where: {
        conversationId,
        isDeleted: false,
      },
      take: limit,
      ...(cursor ? { skip: 1, cursor: { id: cursor } } : {}),
      orderBy: { createdAt: 'desc' },
      include: {
        sender: {
          select: {
            id: true,
            username: true,
            displayName: true,
            avatarUrl: true,
          },
        },
        reactions: {
          select: {
            id: true,
            emoji: true,
            userId: true,
          },
        },
        readReceipts: {
          select: {
            userId: true,
            readAt: true,
          },
        },
      },
    });

    const nextCursor = messages.length === limit ? messages[messages.length - 1].id : null;

    return {
      messages: messages.reverse(), // Chronological order
      nextCursor,
    };
  }

  async sendMessage(userId: string, conversationId: string, data: {
    text: string;
    type?: 'TEXT' | 'IMAGE' | 'DOCUMENT' | 'VOICE_NOTE' | 'SYSTEM';
    attachmentUrl?: string | null;
    attachmentData?: string | null;
  }) {
    // Verify membership and check if caller is blocked
    const membership = await prisma.conversationMember.findUnique({
      where: {
        conversationId_userId: { conversationId, userId },
      },
      include: {
        conversation: {
          include: { members: true },
        },
      },
    });

    if (!membership) {
      throw { code: 'UNAUTHORIZED', message: 'You are not a member of this conversation.', status: 403 };
    }

    // Check if recipient in direct chat blocked sender
    if (membership.conversation.type === 'DIRECT') {
      const recipient = membership.conversation.members.find((m) => m.userId !== userId);
      if (recipient) {
        const isBlocked = await prisma.blockedUser.findFirst({
          where: {
            OR: [
              { blockerId: recipient.userId, blockedId: userId },
              { blockerId: userId, blockedId: recipient.userId },
            ],
          },
        });

        if (isBlocked) {
          throw { code: 'USER_BLOCKED', message: 'Cannot send message to this user.', status: 403 };
        }
      }
    }

    const message = await prisma.message.create({
      data: {
        conversationId,
        senderId: userId,
        text: data.text.trim(),
        type: data.type || 'TEXT',
        attachmentUrl: data.attachmentUrl || null,
        attachmentData: data.attachmentData || null,
      },
      include: {
        sender: {
          select: {
            id: true,
            username: true,
            displayName: true,
            avatarUrl: true,
          },
        },
        reactions: true,
        readReceipts: true,
      },
    });

    // Update conversation updatedAt
    await prisma.conversation.update({
      where: { id: conversationId },
      data: { updatedAt: new Date() },
    });

    // Realtime broadcast via Socket.IO
    const io = getSocketServer();
    if (io) {
      io.to(`conversation:${conversationId}`).emit('message:new', {
        conversationId,
        message,
      });

      // Also notify members' personal rooms for conversation list updates
      for (const member of membership.conversation.members) {
        io.to(`user:${member.userId}`).emit('conversation:updated', {
          conversationId,
          lastMessage: message,
        });
      }
    }

    return message;
  }

  async editMessage(userId: string, messageId: string, text: string) {
    const message = await prisma.message.findUnique({
      where: { id: messageId },
    });

    if (!message) {
      throw { code: 'MESSAGE_NOT_FOUND', message: 'Message not found.', status: 404 };
    }

    if (message.senderId !== userId) {
      throw { code: 'FORBIDDEN', message: 'You can only edit your own messages.', status: 403 };
    }

    const updated = await prisma.message.update({
      where: { id: messageId },
      data: {
        text: text.trim(),
        isEdited: true,
      },
      include: {
        sender: {
          select: {
            id: true,
            username: true,
            displayName: true,
            avatarUrl: true,
          },
        },
        reactions: true,
      },
    });

    const io = getSocketServer();
    if (io) {
      io.to(`conversation:${message.conversationId}`).emit('message:updated', {
        conversationId: message.conversationId,
        message: updated,
      });
    }

    return updated;
  }

  async deleteMessage(userId: string, messageId: string) {
    const message = await prisma.message.findUnique({
      where: { id: messageId },
    });

    if (!message) {
      throw { code: 'MESSAGE_NOT_FOUND', message: 'Message not found.', status: 404 };
    }

    if (message.senderId !== userId) {
      throw { code: 'FORBIDDEN', message: 'You can only delete your own messages.', status: 403 };
    }

    await prisma.message.update({
      where: { id: messageId },
      data: { isDeleted: true },
    });

    const io = getSocketServer();
    if (io) {
      io.to(`conversation:${message.conversationId}`).emit('message:deleted', {
        conversationId: message.conversationId,
        messageId,
      });
    }

    return { success: true, messageId };
  }

  async markRead(userId: string, conversationId: string, messageId?: string) {
    // Check user's read receipt setting
    const profile = await prisma.profile.findUnique({ where: { userId } });
    const allowsReceipts = profile ? profile.readReceiptsEnabled : true;

    // Update member's lastReadMessageId
    if (messageId) {
      await prisma.conversationMember.update({
        where: {
          conversationId_userId: { conversationId, userId },
        },
        data: { lastReadMessageId: messageId },
      });

      if (allowsReceipts) {
        await prisma.messageReadReceipt.upsert({
          where: {
            messageId_userId: { messageId, userId },
          },
          create: { messageId, userId },
          update: { readAt: new Date() },
        });
      }
    }

    const io = getSocketServer();
    if (io && allowsReceipts) {
      io.to(`conversation:${conversationId}`).emit('message:read', {
        conversationId,
        userId,
        messageId,
        readAt: new Date(),
      });
    }

    return { success: true };
  }

  async addReaction(userId: string, messageId: string, emoji: string) {
    const message = await prisma.message.findUnique({
      where: { id: messageId },
      include: { conversation: { include: { members: true } } },
    });

    if (!message) {
      throw { code: 'MESSAGE_NOT_FOUND', message: 'Message not found.', status: 404 };
    }

    const isMember = message.conversation.members.some((m) => m.userId === userId);
    if (!isMember) {
      throw { code: 'UNAUTHORIZED', message: 'You are not a member of this conversation.', status: 403 };
    }

    const reaction = await prisma.messageReaction.upsert({
      where: {
        messageId_userId_emoji: { messageId, userId, emoji },
      },
      create: { messageId, userId, emoji },
      update: {},
    });

    const allReactions = await prisma.messageReaction.findMany({
      where: { messageId },
      select: { id: true, emoji: true, userId: true },
    });

    const io = getSocketServer();
    if (io) {
      io.to(`conversation:${message.conversationId}`).emit('reaction:updated', {
        conversationId: message.conversationId,
        messageId,
        reactions: allReactions,
      });
    }

    return allReactions;
  }

  async removeReaction(userId: string, messageId: string, emoji: string) {
    const message = await prisma.message.findUnique({
      where: { id: messageId },
    });

    if (!message) {
      throw { code: 'MESSAGE_NOT_FOUND', message: 'Message not found.', status: 404 };
    }

    await prisma.messageReaction.deleteMany({
      where: { messageId, userId, emoji },
    });

    const allReactions = await prisma.messageReaction.findMany({
      where: { messageId },
      select: { id: true, emoji: true, userId: true },
    });

    const io = getSocketServer();
    if (io) {
      io.to(`conversation:${message.conversationId}`).emit('reaction:updated', {
        conversationId: message.conversationId,
        messageId,
        reactions: allReactions,
      });
    }

    return allReactions;
  }
}

export default new MessageService();
