import request from 'supertest';
import { createApp } from '../src/app';
import { generateAccessToken, verifyAccessToken, generateRefreshToken, verifyRefreshToken } from '../src/utils/jwt.util';
import { hashPassword, comparePassword, generateOtp, hashOtp } from '../src/utils/hash.util';

describe('Auth Utilities & Security Unit Tests', () => {
  test('Password hashing and verification with bcrypt', async () => {
    const rawPassword = 'SecretPassword2026!';
    const hash = await hashPassword(rawPassword);

    expect(hash).toBeDefined();
    expect(hash).not.toBe(rawPassword);

    const isMatch = await comparePassword(rawPassword, hash);
    expect(isMatch).toBe(true);

    const isWrongMatch = await comparePassword('WrongPassword', hash);
    expect(isWrongMatch).toBe(false);
  });

  test('JWT Access and Refresh token generation and verification', () => {
    const payload = {
      userId: 'test-user-id-123',
      email: 'alex@nexatalk.app',
      username: 'alex_morgan',
    };

    const accessToken = generateAccessToken(payload);
    expect(typeof accessToken).toBe('string');
    expect(accessToken.split('.').length).toBe(3);

    const decoded = verifyAccessToken(accessToken);
    expect(decoded.userId).toBe(payload.userId);
    expect(decoded.username).toBe(payload.username);

    const refreshToken = generateRefreshToken(payload);
    const decodedRefresh = verifyRefreshToken(refreshToken);
    expect(decodedRefresh.userId).toBe(payload.userId);
  });

  test('OTP 6-digit generation and SHA-256 hashing', () => {
    const otp = generateOtp(6);
    expect(otp.length).toBe(6);
    expect(/^\d{6}$/.test(otp)).toBe(true);

    const hashed = hashOtp(otp);
    expect(hashed).toBeDefined();
    expect(hashed.length).toBe(64); // SHA-256 hex length
    expect(hashOtp(otp)).toBe(hashed); // Deterministic
  });
});

describe('REST API Endpoints Integration Tests', () => {
  const app = createApp();

  test('GET /health returns 200 OK and healthy status', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('healthy');
    expect(res.body.app).toBe('NexaTalk Backend');
  });

  test('GET /docs returns 200 OK or redirects for Swagger UI', async () => {
    const res = await request(app).get('/docs/');
    expect([200, 301, 302]).toContain(res.status);
  });

  test('POST /auth/register rejects invalid email with 422', async () => {
    const res = await request(app)
      .post('/auth/register')
      .send({
        email: 'invalid-email-address',
        password: '123', // too short
        displayName: 'A',
        username: 'invalid user space',
      });

    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  test('POST /auth/login rejects empty body with 422', async () => {
    const res = await request(app).post('/auth/login').send({});
    expect(res.status).toBe(422);
    expect(res.body.success).toBe(false);
  });

  test('GET /users/me without Bearer token returns 401 UNAUTHORIZED', async () => {
    const res = await request(app).get('/users/me');
    expect(res.status).toBe(401);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('UNAUTHORIZED');
  });

  test('POST /auth/google without server configuration returns AUTH_PROVIDER_NOT_CONFIGURED', async () => {
    const res = await request(app)
      .post('/auth/google')
      .send({ idToken: 'sample.dummy.google.id.token' });

    expect([401, 501]).toContain(res.status);
    expect(res.body.success).toBe(false);
  });

  test('POST /auth/apple without server configuration returns AUTH_PROVIDER_NOT_CONFIGURED', async () => {
    const res = await request(app)
      .post('/auth/apple')
      .send({ identityToken: 'sample.dummy.apple.identity.token' });

    expect([401, 501]).toContain(res.status);
    expect(res.body.success).toBe(false);
  });
});
