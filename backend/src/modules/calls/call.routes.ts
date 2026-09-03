import { Router } from 'express';
import callController from './call.controller';
import { authenticateJwt } from '../../middlewares/auth.middleware';
import { validateBody } from '../../middlewares/validate.middleware';
import { initiateCallSchema } from './call.schema';

const router = Router();

router.use(authenticateJwt);

router.post('/', validateBody(initiateCallSchema), callController.initiate);
router.post('/:id/accept', callController.accept);
router.post('/:id/reject', callController.reject);
router.post('/:id/end', callController.end);
router.get('/history', callController.history);

export default router;
