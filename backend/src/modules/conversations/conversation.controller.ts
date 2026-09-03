import { Response, NextFunction } from 'express';
import conversationService from './conversation.service';
import { sendSuccess, sendError } from '../../utils/response.util';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';

export class ConversationController {
  async list(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const conversations = await conversationService.listConversations(req.user!.id);
      sendSuccess(res, conversations);
    } catch (error) {
      next(error);
    }
  }

  async create(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const { type, recipientId, title, memberIds } = req.body;
      let conv;
      if (type === 'GROUP') {
        conv = await conversationService.createGroup(req.user!.id, title, memberIds);
      } else {
        conv = await conversationService.createDirectOrGet(req.user!.id, recipientId);
      }
      sendSuccess(res, conv, 201);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async getById(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const conv = await conversationService.getConversationById(req.user!.id, req.params.id as string);
      sendSuccess(res, conv);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async updateMemberSettings(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const updated = await conversationService.updateMemberSettings(req.user!.id, req.params.id as string, req.body);
      sendSuccess(res, updated);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async delete(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await conversationService.deleteOrLeave(req.user!.id, req.params.id as string);
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

export default new ConversationController();
