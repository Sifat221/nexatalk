import { z } from 'zod';

export const createConversationSchema = z.object({
  recipientId: z.string().uuid('Invalid recipient ID').optional(),
  type: z.enum(['DIRECT', 'GROUP']).default('DIRECT'),
  title: z.string().min(1).max(100).optional(),
  memberIds: z.array(z.string().uuid()).optional(),
}).refine(
  (data) => {
    if (data.type === 'DIRECT') return Boolean(data.recipientId);
    if (data.type === 'GROUP') return Boolean(data.memberIds && data.memberIds.length > 0 && data.title);
    return true;
  },
  { message: 'DIRECT requires recipientId; GROUP requires title and memberIds' }
);

export const updateMemberSettingsSchema = z.object({
  isPinned: z.boolean().optional(),
  isMuted: z.boolean().optional(),
});
