import { Response, NextFunction } from 'express';
import messageService from './message.service';
import { sendSuccess, sendError } from '../../utils/response.util';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';

export class MessageController {
  async list(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const conversationId = req.params.conversationId as string;
      const { limit, cursor } = req.query as any;
      const result = await messageService.getMessages(req.user!.id, conversationId, limit, cursor);
      sendSuccess(res, result.messages, 200, { nextCursor: result.nextCursor });
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async send(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const conversationId = req.params.conversationId as string;
      const message = await messageService.sendMessage(req.user!.id, conversationId, req.body);
      sendSuccess(res, message, 201);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async edit(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const message = await messageService.editMessage(req.user!.id, id, req.body.text);
      sendSuccess(res, message);
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
      const id = req.params.id as string;
      const result = await messageService.deleteMessage(req.user!.id, id);
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async markRead(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const { conversationId } = req.body;
      const result = await messageService.markRead(req.user!.id, conversationId, id);
      sendSuccess(res, result);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async addReaction(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const { emoji } = req.body;
      const reactions = await messageService.addReaction(req.user!.id, id, emoji);
      sendSuccess(res, reactions);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }

  async removeReaction(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const id = req.params.id as string;
      const emoji = req.params.emoji as string;
      const reactions = await messageService.removeReaction(req.user!.id, id, emoji);
      sendSuccess(res, reactions);
    } catch (error: any) {
      if (error.code && error.status) {
        sendError(res, error.code, error.message, error.status);
      } else {
        next(error);
      }
    }
  }
}

export default new MessageController();
