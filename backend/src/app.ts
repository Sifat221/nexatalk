import express, { Express } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import path from 'path';
import swaggerUi from 'swagger-ui-express';
import { config } from './config/config';
import { swaggerSpec } from './docs/swagger';
import { errorHandler, notFoundHandler } from './middlewares/error.middleware';

// Import module routers
import authRoutes from './modules/auth/auth.routes';
import userRoutes from './modules/users/user.routes';
import conversationRoutes from './modules/conversations/conversation.routes';
import messageRoutes from './modules/messages/message.routes';
import mediaRoutes from './modules/media/media.routes';
import notificationRoutes from './modules/notifications/notification.routes';
import callRoutes from './modules/calls/call.routes';
import reportRoutes from './modules/reports/report.routes';

export const createApp = (): Express => {
  const app = express();

  // Security headers & CORS
  app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
  app.use(cors({ origin: config.corsOrigin, credentials: true }));

  // Request logger
  if (config.isDev) {
    app.use(morgan('dev'));
  } else {
    app.use(morgan('combined'));
  }

  // Body parsers
  app.use(express.json({ limit: '10mb' }));
  app.use(express.urlencoded({ extended: true, limit: '10mb' }));

  // Static uploads directory
  const uploadsDir = path.resolve(__dirname, '../uploads');
  app.use('/uploads', express.static(uploadsDir));

  // Swagger Documentation
  app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

  // Health check endpoint
  app.get('/health', (req, res) => {
    res.status(200).json({
      status: 'healthy',
      app: 'NexaTalk Backend',
      version: '1.0.0',
      timestamp: new Date().toISOString(),
    });
  });

  // API Routes
  app.use('/auth', authRoutes);
  app.use('/users', userRoutes);
  app.use('/conversations', conversationRoutes);
  app.use('/', messageRoutes); // handles /conversations/:id/messages and /messages/:id
  app.use('/media', mediaRoutes);
  app.use('/', notificationRoutes); // handles /devices and /notifications
  app.use('/calls', callRoutes);
  app.use('/reports', reportRoutes);

  // 404 & Error Handlers
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
};
