import { Response, NextFunction } from 'express';
import userService from './user.service';
import { sendSuccess, sendError } from '../../utils/response.util';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';

export class UserController {
  async getMe(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const user = await userService.getMe(req.user!.id);
      sendSuccess(res, user);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async updateMe(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const user = await userService.updateMe(req.user!.id, req.body);
      sendSuccess(res, user);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async updateSettings(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const profile = await userService.updateSettings(req.user!.id, req.body);
      sendSuccess(res, profile);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async searchUsers(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const { q, page, limit } = req.query as any;
      const result = await userService.searchUsers(req.user!.id, q, page, limit);
      sendSuccess(res, result.users, 200, { pagination: result.pagination });
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async getUserById(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const user = await userService.getUserById(req.user!.id, req.params.id as string);
      sendSuccess(res, user);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async blockUser(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await userService.blockUser(req.user!.id, req.params.id as string);
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async unblockUser(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await userService.unblockUser(req.user!.id, req.params.id as string);
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async getBlockedUsers(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await userService.getBlockedUsers(req.user!.id);
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }
}

export default new UserController();
