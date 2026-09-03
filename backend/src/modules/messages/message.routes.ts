import { Router } from 'express';
import messageController from './message.controller';
import { authenticateJwt } from '../../middlewares/auth.middleware';
import { validateBody, validateQuery } from '../../middlewares/validate.middleware';
import {
  sendMessageSchema,
  editMessageSchema,
  addReactionSchema,
  getMessagesQuerySchema,
} from './message.schema';

const router = Router();

router.use(authenticateJwt);

// Conversation messages routes
router.get('/conversations/:conversationId/messages', validateQuery(getMessagesQuerySchema), messageController.list);
router.post('/conversations/:conversationId/messages', validateBody(sendMessageSchema), messageController.send);

// Specific message routes
router.patch('/messages/:id', validateBody(editMessageSchema), messageController.edit);
router.delete('/messages/:id', messageController.delete);
router.post('/messages/:id/read', messageController.markRead);

// Reaction routes
router.post('/messages/:id/reactions', validateBody(addReactionSchema), messageController.addReaction);
router.delete('/messages/:id/reactions/:emoji', messageController.removeReaction);

export default router;
