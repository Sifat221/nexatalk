import { Response, NextFunction } from 'express';
import reportService from './report.service';
import { sendSuccess } from '../../utils/response.util';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';

export class ReportController {
  async create(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const report = await reportService.createReport(req.user!.id, req.body);
      sendSuccess(res, report, 201);
    } catch (error) {
      next(error);
    }
  }
}

export default new ReportController();
