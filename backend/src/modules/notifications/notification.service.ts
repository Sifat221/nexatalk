import prisma from '../../prisma/client';
import { config } from '../../config/config';
import { logger } from '../../utils/logger.util';

export class NotificationService {
  async registerDeviceToken(userId: string, token: string, platform: 'ANDROID' | 'IOS' | 'WEB' = 'ANDROID') {
    const record = await prisma.deviceToken.upsert({
      where: { token },
      create: { userId, token, platform },
      update: { userId, platform },
    });
    return record;
  }

  async removeDeviceToken(token: string) {
    await prisma.deviceToken.deleteMany({
      where: { token },
    });
    return { success: true };
  }

  async getNotifications(userId: string, limit = 50) {
    const list = await prisma.notification.findMany({
      where: { userId },
      take: limit,
      orderBy: { createdAt: 'desc' },
    });
    return list;
  }

  async markNotificationRead(userId: string, notificationId: string) {
    await prisma.notification.updateMany({
      where: { id: notificationId, userId },
      data: { isRead: true },
    });
    return { success: true };
  }

  async dispatchPushNotification(userId: string, title: string, body: string, data?: Record<string, string>) {
    // Record in-app notification
    await prisma.notification.create({
      data: {
        userId,
        title,
        body,
        data: data ? JSON.stringify(data) : null,
      },
    });

    if (config.fcm.isConfigured) {
      logger.info(`[FCM Push] Sending push notification to User ${userId}: ${title}`);
      // In production with Firebase Admin credentials, send FCM message
    }
  }
}

export default new NotificationService();
