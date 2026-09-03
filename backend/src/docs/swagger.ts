import swaggerJsdoc from 'swagger-jsdoc';
import { config } from '../config/config';

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'NexaTalk REST API',
      version: '1.0.0',
      description: 'Production-grade REST & Realtime API documentation for NexaTalk messaging platform.',
      contact: {
        name: 'NexaTalk Engineering',
        url: 'https://nexatalk.app',
      },
    },
    servers: [
      {
        url: config.apiBaseUrl,
        description: 'Current Environment API Server',
      },
    ],
    components: {
      securitySchemes: {
        BearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Enter your JWT access token.',
        },
      },
      schemas: {
        ApiResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: true },
            data: { type: 'object' },
            meta: { type: 'object' },
          },
        },
        ApiError: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            error: {
              type: 'object',
              properties: {
                code: { type: 'string', example: 'INVALID_CREDENTIALS' },
                message: { type: 'string', example: 'Invalid email or password.' },
              },
            },
          },
        },
      },
    },
    security: [
      {
        BearerAuth: [],
      },
    ],
  },
  apis: ['./src/modules/**/*.routes.ts', './src/modules/**/*.ts'],
};

export const swaggerSpec = swaggerJsdoc(options);
