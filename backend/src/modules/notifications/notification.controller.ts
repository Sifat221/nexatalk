import { Response, NextFunction } from 'express';
import notificationService from './notification.service';
import { sendSuccess, sendError } from '../../utils/response.util';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';

export class NotificationController {
  async registerDevice(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const { token, platform } = req.body;
      if (!token) {
        sendError(res, 'TOKEN_REQUIRED', 'Device token is required.', 400);
        return;
      }
      const record = await notificationService.registerDeviceToken(req.user!.id, token, platform);
      sendSuccess(res, record, 201);
    } catch (error) {
      next(error);
    }
  }

  async removeDevice(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const token = req.params.token as string;
      const result = await notificationService.removeDeviceToken(token);
      sendSuccess(res, result);
    } catch (error) {
      next(error);
    }
  }

  async list(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const notifications = await notificationService.getNotifications(req.user!.id);
      sendSuccess(res, notifications);
    } catch (error) {
      next(error);
    }
  }

  async markRead(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const result = await notificationService.markNotificationRead(req.user!.id, id);
      sendSuccess(res, result);
    } catch (error) {
      next(error);
    }
  }
}

export default new NotificationController();
