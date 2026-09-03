import { Server as HttpServer } from 'http';
import { Server, Socket } from 'socket.io';
import { config } from '../config/config';
import { socketAuthMiddleware } from './socket.auth';
import { registerTypingHandlers } from './handlers/typing.handler';
import { registerPresenceHandlers } from './handlers/presence.handler';
import { registerCallHandlers } from './handlers/call.handler';
import { logger } from '../utils/logger.util';

let io: Server | null = null;

export const initSocketServer = (httpServer: HttpServer): Server => {
  io = new Server(httpServer, {
    cors: {
      origin: config.corsOrigin,
      methods: ['GET', 'POST', 'PATCH', 'DELETE'],
      credentials: true,
    },
    pingInterval: 10000,
    pingTimeout: 5000,
  });

  // JWT Auth Middleware
  io.use(socketAuthMiddleware);

  io.on('connection', async (socket: Socket) => {
    const user = socket.data.user;
    logger.info(`[Socket Connected] User ${user.username} (${user.id}) on socket ${socket.id}`);

    // Join personal user room for direct signals/notifications
    socket.join(`user:${user.id}`);

    // Join conversation room
    socket.on('conversation:join', (data: { conversationId: string }) => {
      if (data?.conversationId) {
        socket.join(`conversation:${data.conversationId}`);
        logger.debug(`Socket ${socket.id} joined conversation:${data.conversationId}`);
      }
    });

    // Leave conversation room
    socket.on('conversation:leave', (data: { conversationId: string }) => {
      if (data?.conversationId) {
        socket.leave(`conversation:${data.conversationId}`);
        logger.debug(`Socket ${socket.id} left conversation:${data.conversationId}`);
      }
    });

    // Register modular event handlers
    registerTypingHandlers(io!, socket);
    await registerPresenceHandlers(io!, socket);
    registerCallHandlers(io!, socket);
  });

  return io;
};

export const getSocketServer = (): Server | null => {
  return io;
};
