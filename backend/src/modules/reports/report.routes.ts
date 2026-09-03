import { Router } from 'express';
import reportController from './report.controller';
import { authenticateJwt } from '../../middlewares/auth.middleware';
import { validateBody } from '../../middlewares/validate.middleware';
import { createReportSchema } from './report.schema';

const router = Router();

router.use(authenticateJwt);

router.post('/', validateBody(createReportSchema), reportController.create);

export default router;
