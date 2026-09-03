import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken, JwtUserPayload } from '../utils/jwt.util';
import { sendError } from '../utils/response.util';
import prisma from '../prisma/client';

export interface AuthenticatedRequest extends Request {
  user?: {
    id: string;
    email: string | null;
    username: string;
    displayName: string;
  };
}

export const authenticateJwt = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      sendError(res, 'UNAUTHORIZED', 'Access token is required.', 401);
      return;
    }

    const token = authHeader.substring(7);
    let payload: JwtUserPayload;

    try {
      payload = verifyAccessToken(token);
    } catch (err: any) {
      if (err.name === 'TokenExpiredError') {
        sendError(res, 'TOKEN_EXPIRED', 'Access token has expired. Please refresh token.', 401);
        return;
      }
      sendError(res, 'INVALID_TOKEN', 'Invalid access token.', 401);
      return;
    }

    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: {
        id: true,
        email: true,
        username: true,
        displayName: true,
      },
    });

    if (!user) {
      sendError(res, 'USER_NOT_FOUND', 'User account no longer exists.', 401);
      return;
    }

    req.user = user;
    next();
  } catch (error) {
    next(error);
  }
};
