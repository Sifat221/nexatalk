import http from 'http';
import { createApp } from './app';
import { initSocketServer } from './socket/socket.server';
import { config } from './config/config';
import { logger } from './utils/logger.util';
import prisma from './prisma/client';

async function bootstrap() {
  try {
    const app = createApp();
    const server = http.createServer(app);

    // Initialize Realtime Socket.IO
    initSocketServer(server);

    // Test database connection
    try {
      await prisma.$connect();
      logger.info(' Connected to PostgreSQL database via Prisma ORM.');
    } catch (dbErr: any) {
      logger.warn(`⚠️ Database connection warning: ${dbErr.message}`);
      logger.warn('Please ensure PostgreSQL is running (e.g. `docker compose up -d postgres`) or update DATABASE_URL in .env');
    }

    server.listen(config.port, () => {
      logger.info(`🚀 NexaTalk Backend Server is running on port ${config.port}`);
      logger.info(`📖 Swagger API Documentation: ${config.apiBaseUrl}/docs`);
      logger.info(`🩺 Health Check: ${config.apiBaseUrl}/health`);
      logger.info(`⚡ Socket.IO Realtime Gateway active on port ${config.port}`);
    });
  } catch (error: any) {
    logger.error(`Failed to start server: ${error.message}`);
    process.exit(1);
  }
}

bootstrap();
