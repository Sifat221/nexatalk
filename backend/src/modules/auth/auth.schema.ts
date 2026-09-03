import { z } from 'zod';

export const registerSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
  displayName: z.string().min(2, 'Name must be at least 2 characters'),
  username: z
    .string()
    .min(3, 'Username must be at least 3 characters')
    .regex(/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers, and underscores'),
  phone: z.string().optional(),
});

export const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(1, 'Password is required'),
});

export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});

export const sendOtpSchema = z.object({
  phoneNumber: z.string().min(8, 'Phone number must be at least 8 digits'),
});

export const verifyOtpSchema = z.object({
  phoneNumber: z.string().min(8, 'Phone number must be at least 8 digits'),
  otp: z.string().length(6, 'OTP must be 6 digits'),
});

export const forgotPasswordSchema = z.object({
  email: z.string().email('Invalid email address'),
});

export const resetPasswordSchema = z.object({
  email: z.string().email('Invalid email address'),
  token: z.string().min(1, 'Reset token is required'),
  newPassword: z.string().min(6, 'Password must be at least 6 characters'),
});

export const googleOAuthSchema = z.object({
  idToken: z.string().min(1, 'Google ID token is required'),
});

export const appleOAuthSchema = z.object({
  identityToken: z.string().min(1, 'Apple identity token is required'),
  authorizationCode: z.string().optional(),
  fullName: z.string().optional(),
});

export const demoLoginSchema = z.object({
  role: z.enum(['primary', 'maya', 'ryan', 'sophia']).optional(),
});
