import { Request, Response, NextFunction } from 'express';
import authService from './auth.service';
import { sendSuccess, sendError } from '../../utils/response.util';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import prisma from '../../prisma/client';

export class AuthController {
  async register(req: Request, res: Response, next: NextFunction) {
    try {
      const userAgent = req.headers['user-agent'];
      const ipAddress = req.ip || req.socket.remoteAddress;
      const result = await authService.register({ ...req.body, userAgent, ipAddress });
      sendSuccess(res, result, 201);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status, error.details);
      } else {
        next(error);
      }
    }
  }

  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const userAgent = req.headers['user-agent'];
      const ipAddress = req.ip || req.socket.remoteAddress;
      const result = await authService.login({ ...req.body, userAgent, ipAddress });
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status, error.details);
      } else {
        next(error);
      }
    }
  }

  async refresh(req: Request, res: Response, next: NextFunction) {
    try {
      const userAgent = req.headers['user-agent'];
      const ipAddress = req.ip || req.socket.remoteAddress;
      const result = await authService.refresh({ ...req.body, userAgent, ipAddress });
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status, error.details);
      } else {
        next(error);
      }
    }
  }

  async logout(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const refreshToken = req.body?.refreshToken;
      const result = await authService.logout(refreshToken);
      sendSuccess(res, result);
    } catch (error) {
      next(error);
    }
  }

  async getMe(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const user = await prisma.user.findUnique({
        where: { id: userId },
        include: { profile: true },
      });

      if (!user) {
        sendError(res, 'USER_NOT_FOUND', 'User profile not found.', 404);
        return;
      }

      const { passwordHash, ...userProfile } = user;
      sendSuccess(res, userProfile);
    } catch (error) {
      next(error);
    }
  }

  async sendPhoneOtp(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authService.sendPhoneOtp(req.body.phoneNumber);
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status, error.details);
      } else {
        next(error);
      }
    }
  }

  async verifyPhoneOtp(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authService.verifyPhoneOtp(req.body.phoneNumber, req.body.otp);
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status, error.details);
      } else {
        next(error);
      }
    }
  }

  async forgotPassword(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authService.forgotPassword(req.body.email);
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status, error.details);
      } else {
        next(error);
      }
    }
  }

  async resetPassword(req: Request, res: Response, next: NextFunction) {
    try {
      const result = await authService.resetPassword(req.body);
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status, error.details);
      } else {
        next(error);
      }
    }
  }

  async googleOAuth(req: Request, res: Response, next: NextFunction) {
    try {
      const userAgent = req.headers['user-agent'];
      const ipAddress = req.ip || req.socket.remoteAddress;
      const result = await authService.googleOAuth(req.body.idToken, userAgent, ipAddress);
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status, error.details);
      } else {
        next(error);
      }
    }
  }

  async appleOAuth(req: Request, res: Response, next: NextFunction) {
    try {
      const userAgent = req.headers['user-agent'];
      const ipAddress = req.ip || req.socket.remoteAddress;
      const result = await authService.appleOAuth(
        req.body.identityToken,
        req.body.fullName,
        userAgent,
        ipAddress
      );
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status, error.details);
      } else {
        next(error);
      }
    }
  }

  async demoLogin(req: Request, res: Response, next: NextFunction) {
    try {
      const userAgent = req.headers['user-agent'];
      const ipAddress = req.ip || req.socket.remoteAddress;
      const role = req.body?.role || 'primary';
      const result = await authService.demoLogin(role, userAgent, ipAddress);
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status, error.details);
      } else {
        next(error);
      }
    }
  }
}

export default new AuthController();
