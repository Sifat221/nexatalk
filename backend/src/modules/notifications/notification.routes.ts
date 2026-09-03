import { Router } from 'express';
import notificationController from './notification.controller';
import { authenticateJwt } from '../../middlewares/auth.middleware';

const router = Router();

router.use(authenticateJwt);

router.post('/devices/register', notificationController.registerDevice);
router.delete('/devices/:token', notificationController.removeDevice);

router.get('/notifications', notificationController.list);
router.patch('/notifications/:id/read', notificationController.markRead);

export default router;
