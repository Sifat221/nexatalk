import { Request, Response, NextFunction } from 'express';
import { sendError } from '../utils/response.util';
import { logger } from '../utils/logger.util';

export const errorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  logger.error(`Unhandled API Error: ${err.message}`, {
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  const statusCode = err.status || err.statusCode || 500;
  const message =
    process.env.NODE_ENV === 'production' && statusCode === 500
      ? 'An unexpected internal server error occurred.'
      : err.message || 'Internal server error';

  const code = err.code || 'INTERNAL_SERVER_ERROR';

  sendError(res, code, message, statusCode);
};

export const notFoundHandler = (req: Request, res: Response): void => {
  sendError(res, 'NOT_FOUND', `Route ${req.method} ${req.path} not found.`, 404);
};
