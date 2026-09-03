import { z } from 'zod';

export const initiateCallSchema = z.object({
  receiverId: z.string().uuid('Invalid receiver user ID'),
  type: z.enum(['AUDIO', 'VIDEO']).default('AUDIO'),
  sdpOffer: z.string().optional(),
});

export const callSignalSchema = z.object({
  sdp: z.string().optional(),
  candidate: z.any().optional(),
});
