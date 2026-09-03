import { z } from 'zod';

export const sendMessageSchema = z.object({
  text: z.string().default(''),
  type: z.enum(['TEXT', 'IMAGE', 'DOCUMENT', 'VOICE_NOTE', 'SYSTEM']).default('TEXT'),
  attachmentUrl: z.string().url().optional().nullable(),
  attachmentData: z.string().optional().nullable(), // JSON string
}).refine(
  (data) => Boolean(data.text?.trim() || data.attachmentUrl),
  { message: 'Message must have either text content or an attachment.' }
);

export const editMessageSchema = z.object({
  text: z.string().min(1, 'Updated message text cannot be empty'),
});

export const addReactionSchema = z.object({
  emoji: z.string().min(1).max(10, 'Emoji must be valid single emoji'),
});

export const getMessagesQuerySchema = z.object({
  cursor: z.string().uuid().optional(),
  limit: z.coerce.number().int().min(1).max(100).default(30),
});
