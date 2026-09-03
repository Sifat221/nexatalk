import dotenv from 'dotenv';
import path from 'path';

// Load .env
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

export const config = {
  env: process.env.NODE_ENV || 'development',
  isDev: (process.env.NODE_ENV || 'development') === 'development',
  port: parseInt(process.env.PORT || '3000', 10),
  apiBaseUrl: process.env.API_BASE_URL || 'http://localhost:3000',
  appPublicUrl: process.env.APP_PUBLIC_URL || 'http://localhost:3000',
  corsOrigin: process.env.CORS_ORIGIN || '*',

  database: {
    url: process.env.DATABASE_URL || 'postgresql://nexatalk:nexatalk_secret_password@localhost:5432/nexatalk_db?schema=public',
  },

  redis: {
    url: process.env.REDIS_URL || 'redis://localhost:6379',
  },

  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET || 'nexatalk_super_secret_jwt_access_token_key_min_32_chars_2026',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'nexatalk_super_secret_jwt_refresh_token_key_min_32_chars_2026',
    accessExpiry: process.env.JWT_ACCESS_EXPIRY || '15m',
    refreshExpiry: process.env.JWT_REFRESH_EXPIRY || '30d',
  },

  toggles: {
    devMockSms: process.env.DEV_MOCK_SMS !== 'false',
    devMockEmail: process.env.DEV_MOCK_EMAIL !== 'false',
    enableDemoLogin: process.env.ENABLE_DEMO_LOGIN === 'true',
  },

  sms: {
    provider: process.env.SMS_PROVIDER || 'twilio',
    apiKey: process.env.SMS_API_KEY || '',
    apiSecret: process.env.SMS_API_SECRET || '',
    from: process.env.SMS_FROM || '+15550192834',
    isConfigured: Boolean(process.env.SMS_API_KEY && process.env.SMS_API_SECRET),
  },

  email: {
    provider: process.env.EMAIL_PROVIDER || 'resend',
    apiKey: process.env.EMAIL_API_KEY || '',
    from: process.env.EMAIL_FROM || 'notifications@nexatalk.app',
    isConfigured: Boolean(process.env.EMAIL_API_KEY),
  },

  oauth: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID || '',
      clientSecret: process.env.GOOGLE_CLIENT_SECRET || '',
      isConfigured: Boolean(process.env.GOOGLE_CLIENT_ID),
    },
    apple: {
      teamId: process.env.APPLE_TEAM_ID || '',
      clientId: process.env.APPLE_CLIENT_ID || '',
      keyId: process.env.APPLE_KEY_ID || '',
      privateKey: process.env.APPLE_PRIVATE_KEY || '',
      isConfigured: Boolean(process.env.APPLE_CLIENT_ID && process.env.APPLE_PRIVATE_KEY),
    },
  },

  storage: {
    provider: (process.env.STORAGE_PROVIDER || 'local') as 'local' | 's3' | 'minio',
    endpoint: process.env.STORAGE_ENDPOINT || 'http://localhost:9000',
    bucket: process.env.STORAGE_BUCKET || 'nexatalk-media',
    accessKey: process.env.STORAGE_ACCESS_KEY || '',
    secretKey: process.env.STORAGE_SECRET_KEY || '',
    region: process.env.STORAGE_REGION || 'us-east-1',
  },

  fcm: {
    projectId: process.env.FCM_PROJECT_ID || '',
    clientEmail: process.env.FCM_CLIENT_EMAIL || '',
    privateKey: process.env.FCM_PRIVATE_KEY || '',
    isConfigured: Boolean(process.env.FCM_PROJECT_ID && process.env.FCM_PRIVATE_KEY),
  },

  webrtc: {
    stunServer: process.env.STUN_SERVER || 'stun:stun.l.google.com:19302',
    turnServer: process.env.TURN_SERVER || '',
    turnUsername: process.env.TURN_USERNAME || '',
    turnPassword: process.env.TURN_PASSWORD || '',
  },
};
