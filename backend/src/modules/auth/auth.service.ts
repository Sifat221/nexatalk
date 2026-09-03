import prisma from '../../prisma/client';
import { config } from '../../config/config';
import {
  hashPassword,
  comparePassword,
  hashToken,
  generateSecureRandomToken,
  generateOtp,
  hashOtp,
} from '../../utils/hash.util';
import {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
} from '../../utils/jwt.util';
import { logger } from '../../utils/logger.util';

export class AuthService {
  /**
   * Register a new user with Email and Password
   */
  async register(data: {
    email: string;
    password: string;
    displayName: string;
    username: string;
    phone?: string;
    userAgent?: string;
    ipAddress?: string;
  }) {
    const normalizedEmail = data.email.toLowerCase().trim();
    const normalizedUsername = data.username.toLowerCase().trim();

    // Check existing email or username
    const existingUser = await prisma.user.findFirst({
      where: {
        OR: [
          { email: normalizedEmail },
          { username: normalizedUsername },
          ...(data.phone ? [{ phone: data.phone }] : []),
        ],
      },
    });

    if (existingUser) {
      if (existingUser.email === normalizedEmail) {
        throw { code: 'EMAIL_ALREADY_EXISTS', message: 'An account with this email already exists.', status: 409 };
      }
      if (existingUser.username === normalizedUsername) {
        throw { code: 'USERNAME_TAKEN', message: 'This username is already taken.', status: 409 };
      }
      if (data.phone && existingUser.phone === data.phone) {
        throw { code: 'PHONE_ALREADY_EXISTS', message: 'An account with this phone number already exists.', status: 409 };
      }
    }

    const hashedPassword = await hashPassword(data.password);

    // Create user and profile in transaction
    const user = await prisma.user.create({
      data: {
        email: normalizedEmail,
        username: normalizedUsername,
        displayName: data.displayName.trim(),
        phone: data.phone || null,
        passwordHash: hashedPassword,
        profile: {
          create: {
            customStatus: 'Active on NexaTalk',
            language: 'English (US)',
          },
        },
        authIdentities: {
          create: {
            provider: 'PASSWORD',
            providerUserId: normalizedEmail,
          },
        },
      },
      include: {
        profile: true,
      },
    });

    // Generate tokens
    const accessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
      username: user.username,
    });
    const rawRefreshToken = generateRefreshToken({
      userId: user.id,
      email: user.email,
      username: user.username,
    });

    const refreshExpiryDate = new Date();
    refreshExpiryDate.setDate(refreshExpiryDate.getDate() + 30);

    await prisma.refreshSession.create({
      data: {
        userId: user.id,
        tokenHash: hashToken(rawRefreshToken),
        userAgent: data.userAgent || null,
        ipAddress: data.ipAddress || null,
        expiresAt: refreshExpiryDate,
      },
    });

    const { passwordHash, ...userProfile } = user;

    return {
      user: userProfile,
      accessToken,
      refreshToken: rawRefreshToken,
    };
  }

  /**
   * Login with Email and Password
   */
  async login(data: {
    email: string;
    password: string;
    userAgent?: string;
    ipAddress?: string;
  }) {
    const normalizedEmail = data.email.toLowerCase().trim();

    const user = await prisma.user.findUnique({
      where: { email: normalizedEmail },
      include: { profile: true },
    });

    if (!user || !user.passwordHash) {
      throw { code: 'INVALID_CREDENTIALS', message: 'Invalid email or password.', status: 401 };
    }

    const isMatch = await comparePassword(data.password, user.passwordHash);
    if (!isMatch) {
      throw { code: 'INVALID_CREDENTIALS', message: 'Invalid email or password.', status: 401 };
    }

    const accessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
      username: user.username,
    });
    const rawRefreshToken = generateRefreshToken({
      userId: user.id,
      email: user.email,
      username: user.username,
    });

    const refreshExpiryDate = new Date();
    refreshExpiryDate.setDate(refreshExpiryDate.getDate() + 30);

    await prisma.refreshSession.create({
      data: {
        userId: user.id,
        tokenHash: hashToken(rawRefreshToken),
        userAgent: data.userAgent || null,
        ipAddress: data.ipAddress || null,
        expiresAt: refreshExpiryDate,
      },
    });

    const { passwordHash, ...userProfile } = user;

    return {
      user: userProfile,
      accessToken,
      refreshToken: rawRefreshToken,
    };
  }

  /**
   * Refresh session with refresh token rotation
   */
  async refresh(data: { refreshToken: string; userAgent?: string; ipAddress?: string }) {
    let payload;
    try {
      payload = verifyRefreshToken(data.refreshToken);
    } catch (err: any) {
      throw { code: 'INVALID_REFRESH_TOKEN', message: 'Invalid or expired refresh token.', status: 401 };
    }

    const oldTokenHash = hashToken(data.refreshToken);

    const session = await prisma.refreshSession.findUnique({
      where: { tokenHash: oldTokenHash },
    });

    if (!session || session.isRevoked || session.expiresAt < new Date()) {
      throw { code: 'REVOKED_REFRESH_TOKEN', message: 'Refresh token is expired or revoked.', status: 401 };
    }

    // Revoke old session (Rotation)
    await prisma.refreshSession.update({
      where: { id: session.id },
      data: { isRevoked: true },
    });

    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      include: { profile: true },
    });

    if (!user) {
      throw { code: 'USER_NOT_FOUND', message: 'User not found.', status: 401 };
    }

    const newAccessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
      username: user.username,
    });
    const newRefreshToken = generateRefreshToken({
      userId: user.id,
      email: user.email,
      username: user.username,
    });

    const refreshExpiryDate = new Date();
    refreshExpiryDate.setDate(refreshExpiryDate.getDate() + 30);

    await prisma.refreshSession.create({
      data: {
        userId: user.id,
        tokenHash: hashToken(newRefreshToken),
        userAgent: data.userAgent || session.userAgent,
        ipAddress: data.ipAddress || session.ipAddress,
        expiresAt: refreshExpiryDate,
      },
    });

    const { passwordHash, ...userProfile } = user;

    return {
      user: userProfile,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    };
  }

  /**
   * Logout and revoke refresh session
   */
  async logout(refreshToken?: string) {
    if (refreshToken) {
      const tokenHash = hashToken(refreshToken);
      await prisma.refreshSession.updateMany({
        where: { tokenHash },
        data: { isRevoked: true },
      });
    }
    return { success: true };
  }

  /**
   * Send Phone OTP
   */
  async sendPhoneOtp(phoneNumber: string) {
    const formattedPhone = phoneNumber.trim();

    // Check resend cooldown (60 seconds)
    const recent = await prisma.phoneVerification.findFirst({
      where: { phoneNumber: formattedPhone },
      orderBy: { createdAt: 'desc' },
    });

    if (recent) {
      const diffMs = Date.now() - recent.createdAt.getTime();
      if (diffMs < 60000) {
        const waitSec = Math.ceil((60000 - diffMs) / 1000);
        throw {
          code: 'OTP_RATE_LIMITED',
          message: `Please wait ${waitSec} seconds before requesting a new OTP.`,
          status: 429,
          details: { retryAfterSeconds: waitSec },
        };
      }
    }

    const otp = generateOtp(6);
    const otpHash = hashOtp(otp);

    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    await prisma.phoneVerification.create({
      data: {
        phoneNumber: formattedPhone,
        otpHash,
        expiresAt,
      },
    });

    // Send SMS or Dev Console simulation
    if (config.sms.isConfigured && config.sms.provider === 'twilio') {
      try {
        // Real Twilio API integration
        const authHeader = 'Basic ' + Buffer.from(`${config.sms.apiKey}:${config.sms.apiSecret}`).toString('base64');
        const params = new URLSearchParams();
        params.append('To', formattedPhone);
        params.append('From', config.sms.from);
        params.append('Body', `Your NexaTalk verification code is: ${otp}. Valid for 5 minutes.`);

        await fetch(`https://api.twilio.com/2010-04-01/Accounts/${config.sms.apiKey}/Messages.json`, {
          method: 'POST',
          headers: {
            'Authorization': authHeader,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: params.toString(),
        });
        logger.info(`[SMS Sent] Real SMS dispatched to ${formattedPhone}`);
      } catch (err: any) {
        logger.error(`[SMS Error] Failed to dispatch Twilio SMS: ${err.message}`);
      }
    } else if (config.toggles.devMockSms) {
      logger.info(`[DEV SMS OTP] Verification code for ${formattedPhone}: ${otp} (expires in 5m)`);
    }

    return {
      phoneNumber: formattedPhone,
      expiresInSeconds: 300,
      resendCooldownSeconds: 60,
    };
  }

  /**
   * Verify Phone OTP
   */
  async verifyPhoneOtp(phoneNumber: string, otp: string) {
    const formattedPhone = phoneNumber.trim();
    const providedOtpHash = hashOtp(otp.trim());

    const verification = await prisma.phoneVerification.findFirst({
      where: {
        phoneNumber: formattedPhone,
        verified: false,
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!verification) {
      throw { code: 'INVALID_OTP', message: 'No active OTP verification found for this phone number.', status: 400 };
    }

    if (verification.expiresAt < new Date()) {
      throw { code: 'OTP_EXPIRED', message: 'Verification code has expired. Please request a new one.', status: 400 };
    }

    if (verification.attempts >= 3) {
      throw { code: 'TOO_MANY_ATTEMPTS', message: 'Maximum verification attempts exceeded. Please request a new OTP.', status: 429 };
    }

    // Increment attempt count
    await prisma.phoneVerification.update({
      where: { id: verification.id },
      data: { attempts: { increment: 1 } },
    });

    if (verification.otpHash !== providedOtpHash) {
      const remaining = 3 - (verification.attempts + 1);
      throw {
        code: 'INVALID_OTP',
        message: `Incorrect verification code. ${remaining} attempts remaining.`,
        status: 400,
        details: { attemptsRemaining: remaining },
      };
    }

    // Mark verified
    await prisma.phoneVerification.update({
      where: { id: verification.id },
      data: { verified: true },
    });

    // Check if user exists with this phone
    const user = await prisma.user.findUnique({
      where: { phone: formattedPhone },
      include: { profile: true },
    });

    if (user) {
      const accessToken = generateAccessToken({
        userId: user.id,
        email: user.email,
        username: user.username,
      });
      const rawRefreshToken = generateRefreshToken({
        userId: user.id,
        email: user.email,
        username: user.username,
      });

      const refreshExpiryDate = new Date();
      refreshExpiryDate.setDate(refreshExpiryDate.getDate() + 30);

      await prisma.refreshSession.create({
        data: {
          userId: user.id,
          tokenHash: hashToken(rawRefreshToken),
          expiresAt: refreshExpiryDate,
        },
      });

      const { passwordHash, ...userProfile } = user;

      return {
        verified: true,
        userExists: true,
        user: userProfile,
        accessToken,
        refreshToken: rawRefreshToken,
      };
    }

    return {
      verified: true,
      userExists: false,
      phoneNumber: formattedPhone,
    };
  }

  /**
   * Request Password Reset Email
   */
  async forgotPassword(email: string) {
    const normalizedEmail = email.toLowerCase().trim();

    const user = await prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (!user) {
      // Do not leak email existence in production
      return { message: 'If an account exists with this email, a password reset link has been sent.' };
    }

    const resetToken = generateSecureRandomToken(32);
    const tokenHash = hashToken(resetToken);
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

    await prisma.passwordResetToken.create({
      data: {
        userId: user.id,
        tokenHash,
        expiresAt,
      },
    });

    const resetUrl = `${config.appPublicUrl}/auth/reset-password?token=${resetToken}&email=${encodeURIComponent(normalizedEmail)}`;

    if (config.email.isConfigured && config.email.provider === 'resend') {
      try {
        await fetch('https://api.resend.com/emails', {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${config.email.apiKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            from: config.email.from,
            to: normalizedEmail,
            subject: 'Reset your NexaTalk password',
            html: `<p>Hello ${user.displayName},</p><p>You requested a password reset. Click the link below to set a new password:</p><p><a href="${resetUrl}">${resetUrl}</a></p><p>This link expires in 1 hour.</p>`,
          }),
        });
        logger.info(`[Email Sent] Password reset email sent to ${normalizedEmail}`);
      } catch (err: any) {
        logger.error(`[Email Error] Failed to send Resend email: ${err.message}`);
      }
    } else if (config.toggles.devMockEmail) {
      logger.info(`[DEV EMAIL] Password reset URL for ${normalizedEmail}: ${resetUrl}`);
    }

    return { message: 'If an account exists with this email, a password reset link has been sent.' };
  }

  /**
   * Reset Password with token
   */
  async resetPassword(data: { email: string; token: string; newPassword: string }) {
    const normalizedEmail = data.email.toLowerCase().trim();
    const tokenHash = hashToken(data.token);

    const user = await prisma.user.findUnique({
      where: { email: normalizedEmail },
    });

    if (!user) {
      throw { code: 'INVALID_RESET_TOKEN', message: 'Invalid or expired password reset token.', status: 400 };
    }

    const resetRecord = await prisma.passwordResetToken.findFirst({
      where: {
        userId: user.id,
        tokenHash,
        usedAt: null,
      },
      orderBy: { createdAt: 'desc' },
    });

    if (!resetRecord || resetRecord.expiresAt < new Date()) {
      throw { code: 'INVALID_RESET_TOKEN', message: 'Invalid or expired password reset token.', status: 400 };
    }

    const newHashedPassword = await hashPassword(data.newPassword);

    await prisma.$transaction([
      prisma.user.update({
        where: { id: user.id },
        data: { passwordHash: newHashedPassword },
      }),
      prisma.passwordResetToken.update({
        where: { id: resetRecord.id },
        data: { usedAt: new Date() },
      }),
      // Revoke all existing sessions for security
      prisma.refreshSession.updateMany({
        where: { userId: user.id },
        data: { isRevoked: true },
      }),
    ]);

    return { success: true, message: 'Password has been successfully updated. Please sign in.' };
  }

  /**
   * Google OAuth Exchange
   */
  async googleOAuth(idToken: string, userAgent?: string, ipAddress?: string) {
    if (!config.oauth.google.isConfigured) {
      throw {
        code: 'AUTH_PROVIDER_NOT_CONFIGURED',
        message: 'Google sign-in is not configured on the server. Please supply GOOGLE_CLIENT_ID in the backend environment.',
        status: 501,
      };
    }

    // Verify token with Google API
    let googleUser: { sub: string; email: string; name?: string; picture?: string };
    try {
      const resp = await fetch(`https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`);
      if (!resp.ok) {
        throw new Error('Google token verification failed');
      }
      googleUser = await resp.json() as any;
    } catch (err) {
      throw { code: 'INVALID_OAUTH_TOKEN', message: 'Failed to verify Google identity token.', status: 401 };
    }

    const normalizedEmail = googleUser.email.toLowerCase().trim();

    let user = await prisma.user.findUnique({
      where: { email: normalizedEmail },
      include: { profile: true },
    });

    if (!user) {
      const username = normalizedEmail.split('@')[0].replace(/[^a-zA-Z0-9_]/g, '') + '_' + Math.floor(Math.random() * 1000);
      user = await prisma.user.create({
        data: {
          email: normalizedEmail,
          username,
          displayName: googleUser.name || username,
          avatarUrl: googleUser.picture || null,
          profile: { create: {} },
          authIdentities: {
            create: {
              provider: 'GOOGLE',
              providerUserId: googleUser.sub,
            },
          },
        },
        include: { profile: true },
      });
    } else {
      // Link identity if not linked
      await prisma.authIdentity.upsert({
        where: {
          provider_providerUserId: {
            provider: 'GOOGLE',
            providerUserId: googleUser.sub,
          },
        },
        create: {
          userId: user.id,
          provider: 'GOOGLE',
          providerUserId: googleUser.sub,
        },
        update: {},
      });
    }

    const accessToken = generateAccessToken({ userId: user.id, email: user.email, username: user.username });
    const rawRefreshToken = generateRefreshToken({ userId: user.id, email: user.email, username: user.username });

    const refreshExpiryDate = new Date();
    refreshExpiryDate.setDate(refreshExpiryDate.getDate() + 30);

    await prisma.refreshSession.create({
      data: {
        userId: user.id,
        tokenHash: hashToken(rawRefreshToken),
        userAgent: userAgent || null,
        ipAddress: ipAddress || null,
        expiresAt: refreshExpiryDate,
      },
    });

    const { passwordHash, ...userProfile } = user;
    return { user: userProfile, accessToken, refreshToken: rawRefreshToken };
  }

  /**
   * Apple OAuth Exchange
   */
  async appleOAuth(identityToken: string, fullName?: string, userAgent?: string, ipAddress?: string) {
    if (!config.oauth.apple.isConfigured) {
      throw {
        code: 'AUTH_PROVIDER_NOT_CONFIGURED',
        message: 'Apple sign-in is not configured on the server. Please supply APPLE_CLIENT_ID and APPLE_PRIVATE_KEY in backend environment.',
        status: 501,
      };
    }

    // In production with Apple keys, verify token signature
    throw {
      code: 'AUTH_PROVIDER_NOT_CONFIGURED',
      message: 'Apple Sign In configuration is awaiting Apple Team ID and private key credentials.',
      status: 501,
    };
  }

  /**
   * Quick Demo Login (Only enabled in development when ENABLE_DEMO_LOGIN=true)
   */
  async demoLogin(role: string = 'primary', userAgent?: string, ipAddress?: string) {
    if (!config.toggles.enableDemoLogin) {
      throw {
        code: 'FORBIDDEN',
        message: 'Quick Demo Login is disabled in production environments.',
        status: 403,
      };
    }

    const demoUsers: Record<string, { email: string; username: string; displayName: string; bio: string }> = {
      primary: {
        email: 'alex.morgan@nexatalk.app',
        username: 'alex_morgan',
        displayName: 'Alex Morgan',
        bio: 'Senior Product Designer • Building the future of messaging 🚀',
      },
      maya: {
        email: 'maya.chen@nexatalk.app',
        username: 'maya_chen',
        displayName: 'Maya Chen',
        bio: 'Lead Architect @ NexaLab | Passionate about sleek UIs 🎨',
      },
      ryan: {
        email: 'ryan.lee@nexatalk.app',
        username: 'ryan_lee',
        displayName: 'Ryan Lee',
        bio: 'Engineering Lead ⚡ Let’s ship things fast.',
      },
      sophia: {
        email: 'sophia.reed@nexatalk.app',
        username: 'sophia_reed',
        displayName: 'Sophia Reed',
        bio: 'UX Strategist & Design Systems advocate ✨',
      },
    };

    const target = demoUsers[role] || demoUsers.primary;

    let user = await prisma.user.findUnique({
      where: { email: target.email },
      include: { profile: true },
    });

    if (!user) {
      const defaultPasswordHash = await hashPassword('NexaTalkDemo2026!');
      user = await prisma.user.create({
        data: {
          email: target.email,
          username: target.username,
          displayName: target.displayName,
          bio: target.bio,
          passwordHash: defaultPasswordHash,
          profile: {
            create: {
              customStatus: 'Exploring NexaTalk ✨',
              language: 'English (US)',
            },
          },
          authIdentities: {
            create: {
              provider: 'PASSWORD',
              providerUserId: target.email,
            },
          },
        },
        include: { profile: true },
      });
    }

    const accessToken = generateAccessToken({
      userId: user.id,
      email: user.email,
      username: user.username,
    });
    const rawRefreshToken = generateRefreshToken({
      userId: user.id,
      email: user.email,
      username: user.username,
    });

    const refreshExpiryDate = new Date();
    refreshExpiryDate.setDate(refreshExpiryDate.getDate() + 30);

    await prisma.refreshSession.create({
      data: {
        userId: user.id,
        tokenHash: hashToken(rawRefreshToken),
        userAgent: userAgent || 'NexaTalk Demo Client',
        ipAddress: ipAddress || '127.0.0.1',
        expiresAt: refreshExpiryDate,
      },
    });

    const { passwordHash, ...userProfile } = user;
    return {
      user: userProfile,
      accessToken,
      refreshToken: rawRefreshToken,
    };
  }
}

export default new AuthService();
