import { Server, Socket } from 'socket.io';
import prisma from '../../prisma/client';
import { logger } from '../../utils/logger.util';

export const registerPresenceHandlers = async (io: Server, socket: Socket) => {
  const user = socket.data.user;

  // Mark user online
  await prisma.user.update({
    where: { id: user.id },
    data: {
      isOnline: true,
      lastSeenAt: new Date(),
    },
  });

  await prisma.userPresence.upsert({
    where: {
      userId_socketId: { userId: user.id, socketId: socket.id },
    },
    create: {
      userId: user.id,
      socketId: socket.id,
      status: 'ONLINE',
    },
    update: {
      status: 'ONLINE',
      updatedAt: new Date(),
    },
  });

  // Broadcast presence
  io.emit('presence:update', {
    userId: user.id,
    isOnline: true,
    status: 'ONLINE',
    lastSeenAt: new Date(),
  });

  socket.on('disconnect', async () => {
    try {
      await prisma.userPresence.deleteMany({
        where: { socketId: socket.id },
      });

      const remainingPresences = await prisma.userPresence.count({
        where: { userId: user.id },
      });

      if (remainingPresences === 0) {
        const lastSeen = new Date();
        await prisma.user.update({
          where: { id: user.id },
          data: {
            isOnline: false,
            lastSeenAt: lastSeen,
          },
        });

        io.emit('presence:update', {
          userId: user.id,
          isOnline: false,
          status: 'OFFLINE',
          lastSeenAt: lastSeen,
        });
      }
    } catch (err: any) {
      logger.error(`Presence disconnect error for ${user.id}: ${err.message}`);
    }
  });
};
