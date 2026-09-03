import { Response, NextFunction } from 'express';
import storageService from './storage.service';
import { sendSuccess, sendError } from '../../utils/response.util';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';

export class MediaController {
  async upload(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const file = req.file;
      if (!file) {
        sendError(res, 'FILE_REQUIRED', 'Please provide a file to upload.', 400);
        return;
      }

      const category = (req.body?.category || 'IMAGE').toUpperCase() as any;
      const result = await storageService.saveFile(file, category);

      sendSuccess(res, result, 201);
    } catch (error) {
      next(error);
    }
  }
}

export default new MediaController();
