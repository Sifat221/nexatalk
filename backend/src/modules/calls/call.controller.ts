import { Response, NextFunction } from 'express';
import callService from './call.service';
import { sendSuccess, sendError } from '../../utils/response.util';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';

export class CallController {
  async initiate(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const { receiverId, type, sdpOffer } = req.body;
      const call = await callService.initiateCall(req.user!.id, receiverId, type, sdpOffer);
      sendSuccess(res, call, 201);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async accept(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const { sdpAnswer } = req.body;
      const call = await callService.acceptCall(req.user!.id, id, sdpAnswer);
      sendSuccess(res, call);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async reject(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const call = await callService.rejectCall(req.user!.id, id);
      sendSuccess(res, call);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async end(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const call = await callService.endCall(req.user!.id, id);
      sendSuccess(res, call);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async history(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const calls = await callService.getCallHistory(req.user!.id);
      sendSuccess(res, calls);
    } catch (error) {
      next(error);
    }
  }
}

export default new CallController();
