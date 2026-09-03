import { Socket } from 'socket.io';
import { verifyAccessToken } from '../utils/jwt.util';
import prisma from '../prisma/client';
import { logger } from '../utils/logger.util';

export const socketAuthMiddleware = async (socket: Socket, next: (err?: Error) => void) => {
  try {
    const token =
      socket.handshake.auth?.token ||
      socket.handshake.headers?.authorization?.replace('Bearer ', '');

    if (!token) {
      return next(new Error('Authentication token is required for realtime connection.'));
    }

    let payload;
    try {
      payload = verifyAccessToken(token);
    } catch (err: any) {
      return next(new Error('Invalid or expired socket authentication token.'));
    }

    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: {
        id: true,
        email: true,
        username: true,
        displayName: true,
        avatarUrl: true,
      },
    });

    if (!user) {
      return next(new Error('Authenticated user no longer exists.'));
    }

    socket.data.user = user;
    next();
  } catch (error: any) {
    logger.error(`Socket auth error: ${error.message}`);
    next(new Error('Socket authentication failed.'));
  }
};
