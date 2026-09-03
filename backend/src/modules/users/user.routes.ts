import { Router } from 'express';
import userController from './user.controller';
import { authenticateJwt } from '../../middlewares/auth.middleware';
import { validateBody, validateQuery } from '../../middlewares/validate.middleware';
import { updateProfileSchema, updateSettingsSchema, searchUsersQuerySchema } from './user.schema';

const router = Router();

// All user routes require authentication
router.use(authenticateJwt);

router.get('/me', userController.getMe);
router.patch('/me', validateBody(updateProfileSchema), userController.updateMe);
router.patch('/me/settings', validateBody(updateSettingsSchema), userController.updateSettings);

router.get('/search', validateQuery(searchUsersQuerySchema), userController.searchUsers);
router.get('/blocked', userController.getBlockedUsers);
router.get('/:id', userController.getUserById);

router.post('/:id/block', userController.blockUser);
router.delete('/:id/block', userController.unblockUser);

export default router;
