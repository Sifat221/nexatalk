import { z } from 'zod';

export const updateProfileSchema = z.object({
  displayName: z.string().min(2, 'Name must be at least 2 characters').optional(),
  bio: z.string().max(250, 'Bio cannot exceed 250 characters').optional(),
  phone: z.string().optional(),
  avatarUrl: z.string().url('Invalid avatar URL').optional().nullable(),
  status: z.string().max(100).optional(),
});

export const updateSettingsSchema = z.object({
  customStatus: z.string().optional(),
  themeMode: z.enum(['DARK', 'OLED']).optional(),
  oledMode: z.boolean().optional(),
  notificationsEnabled: z.boolean().optional(),
  hapticsEnabled: z.boolean().optional(),
  readReceiptsEnabled: z.boolean().optional(),
  language: z.string().optional(),
  chatWallpaper: z.string().optional(),
});

export const searchUsersQuerySchema = z.object({
  q: z.string().min(1, 'Search query is required'),
  limit: z.coerce.number().int().min(1).max(50).default(20),
  page: z.coerce.number().int().min(1).default(1),
});
