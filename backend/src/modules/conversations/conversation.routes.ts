import { Router } from 'express';
import conversationController from './conversation.controller';
import { authenticateJwt } from '../../middlewares/auth.middleware';
import { validateBody } from '../../middlewares/validate.middleware';
import { createConversationSchema, updateMemberSettingsSchema } from './conversation.schema';

const router = Router();

router.use(authenticateJwt);

router.get('/', conversationController.list);
router.post('/', validateBody(createConversationSchema), conversationController.create);
router.get('/:id', conversationController.getById);
router.patch('/:id/settings', validateBody(updateMemberSettingsSchema), conversationController.updateMemberSettings);
router.delete('/:id', conversationController.delete);

export default router;
