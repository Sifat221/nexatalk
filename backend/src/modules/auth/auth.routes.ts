import { Router } from 'express';
import authController from './auth.controller';
import { validateBody } from '../../middlewares/validate.middleware';
import { authenticateJwt } from '../../middlewares/auth.middleware';
import {
  registerSchema,
  loginSchema,
  refreshTokenSchema,
  sendOtpSchema,
  verifyOtpSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  googleOAuthSchema,
  appleOAuthSchema,
  demoLoginSchema,
} from './auth.schema';

const router = Router();

router.post('/register', validateBody(registerSchema), authController.register);
router.post('/login', validateBody(loginSchema), authController.login);
router.post('/refresh', validateBody(refreshTokenSchema), authController.refresh);
router.post('/logout', authController.logout);
router.get('/me', authenticateJwt, authController.getMe);

// Phone OTP
router.post('/phone/send-otp', validateBody(sendOtpSchema), authController.sendPhoneOtp);
router.post('/phone/verify-otp', validateBody(verifyOtpSchema), authController.verifyPhoneOtp);

// Password Reset
router.post('/forgot-password', validateBody(forgotPasswordSchema), authController.forgotPassword);
router.post('/reset-password', validateBody(resetPasswordSchema), authController.resetPassword);

// OAuth
router.post('/google', validateBody(googleOAuthSchema), authController.googleOAuth);
router.post('/apple', validateBody(appleOAuthSchema), authController.appleOAuth);

// Development Demo Shortcut
router.post('/demo-login', validateBody(demoLoginSchema), authController.demoLogin);

export default router;
