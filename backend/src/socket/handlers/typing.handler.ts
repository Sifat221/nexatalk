import { Server, Socket } from 'socket.io';
import prisma from '../../prisma/client';

export const registerTypingHandlers = (io: Server, socket: Socket) => {
  const user = socket.data.user;

  socket.on('typing:start', async (data: { conversationId: string }) => {
    if (!data?.conversationId) return;

    // Verify membership
    const membership = await prisma.conversationMember.findUnique({
      where: {
        conversationId_userId: { conversationId: data.conversationId, userId: user.id },
      },
    });

    if (membership) {
      socket.to(`conversation:${data.conversationId}`).emit('typing:update', {
        conversationId: data.conversationId,
        userId: user.id,
        username: user.username,
        displayName: user.displayName,
        isTyping: true,
      });
    }
  });

  socket.on('typing:stop', async (data: { conversationId: string }) => {
    if (!data?.conversationId) return;

    socket.to(`conversation:${data.conversationId}`).emit('typing:update', {
      conversationId: data.conversationId,
      userId: user.id,
      username: user.username,
      displayName: user.displayName,
      isTyping: false,
    });
  });
};
