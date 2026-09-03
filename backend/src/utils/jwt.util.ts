import jwt, { SignOptions } from 'jsonwebtoken';
import { config } from '../config/config';

export interface JwtUserPayload {
  userId: string;
  email?: string | null;
  username: string;
}

export const generateAccessToken = (payload: JwtUserPayload): string => {
  return jwt.sign(payload, config.jwt.accessSecret, {
    expiresIn: config.jwt.accessExpiry as any,
  });
};

export const generateRefreshToken = (payload: JwtUserPayload): string => {
  return jwt.sign(payload, config.jwt.refreshSecret, {
    expiresIn: config.jwt.refreshExpiry as any,
  });
};

export const verifyAccessToken = (token: string): JwtUserPayload => {
  return jwt.verify(token, config.jwt.accessSecret) as JwtUserPayload;
};

export const verifyRefreshToken = (token: string): JwtUserPayload => {
  return jwt.verify(token, config.jwt.refreshSecret) as JwtUserPayload;
};
