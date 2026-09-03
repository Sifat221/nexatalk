import { z } from 'zod';

export const createReportSchema = z.object({
  targetType: z.enum(['USER', 'MESSAGE', 'CONVERSATION']),
  targetId: z.string().min(1, 'Target ID is required'),
  reason: z.string().min(3, 'Reason must be at least 3 characters').max(500),
});
