import prisma from '../../prisma/client';

export class UserService {
  async getMe(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { profile: true },
    });

    if (!user) {
      throw { code: 'USER_NOT_FOUND', message: 'User not found.', status: 404 };
    }

    const { passwordHash, ...safeUser } = user;
    return safeUser;
  }

  async updateMe(userId: string, data: {
    displayName?: string;
    bio?: string;
    phone?: string;
    avatarUrl?: string | null;
    status?: string;
  }) {
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        ...(data.displayName ? { displayName: data.displayName.trim() } : {}),
        ...(data.bio !== undefined ? { bio: data.bio.trim() } : {}),
        ...(data.phone !== undefined ? { phone: data.phone } : {}),
        ...(data.avatarUrl !== undefined ? { avatarUrl: data.avatarUrl } : {}),
        ...(data.status ? { status: data.status } : {}),
      },
      include: { profile: true },
    });

    const { passwordHash, ...safeUser } = updatedUser;
    return safeUser;
  }

  async updateSettings(userId: string, data: {
    customStatus?: string;
    themeMode?: string;
    oledMode?: boolean;
    notificationsEnabled?: boolean;
    hapticsEnabled?: boolean;
    readReceiptsEnabled?: boolean;
    language?: string;
    chatWallpaper?: string;
  }) {
    const profile = await prisma.profile.upsert({
      where: { userId },
      create: {
        userId,
        ...data,
      },
      update: {
        ...data,
      },
    });

    return profile;
  }

  async getUserById(currentUserId: string, targetUserId: string) {
    // Check if target has blocked current user or current user blocked target
    const isBlocked = await prisma.blockedUser.findFirst({
      where: {
        OR: [
          { blockerId: currentUserId, blockedId: targetUserId },
          { blockerId: targetUserId, blockedId: currentUserId },
        ],
      },
    });

    const user = await prisma.user.findUnique({
      where: { id: targetUserId },
      select: {
        id: true,
        username: true,
        displayName: true,
        avatarUrl: true,
        bio: true,
        status: true,
        isOnline: true,
        lastSeenAt: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw { code: 'USER_NOT_FOUND', message: 'User not found.', status: 404 };
    }

    return {
      ...user,
      isBlocked: Boolean(isBlocked),
    };
  }

  async searchUsers(currentUserId: string, query: string, page = 1, limit = 20) {
    const normalizedQuery = query.trim().toLowerCase();
    const skip = (page - 1) * limit;

    // Get list of blocked IDs to exclude
    const blockedRecords = await prisma.blockedUser.findMany({
      where: {
        OR: [
          { blockerId: currentUserId },
          { blockedId: currentUserId },
        ],
      },
    });

    const excludedIds = new Set<string>([
      currentUserId,
      ...blockedRecords.map((b) => (b.blockerId === currentUserId ? b.blockedId : b.blockerId)),
    ]);

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where: {
          id: { notIn: Array.from(excludedIds) },
          OR: [
            { username: { contains: normalizedQuery, mode: 'insensitive' } },
            { displayName: { contains: normalizedQuery, mode: 'insensitive' } },
          ],
        },
        select: {
          id: true,
          username: true,
          displayName: true,
          avatarUrl: true,
          bio: true,
          status: true,
          isOnline: true,
          lastSeenAt: true,
        },
        skip,
        take: limit,
        orderBy: { displayName: 'asc' },
      }),
      prisma.user.count({
        where: {
          id: { notIn: Array.from(excludedIds) },
          OR: [
            { username: { contains: normalizedQuery, mode: 'insensitive' } },
            { displayName: { contains: normalizedQuery, mode: 'insensitive' } },
          ],
        },
      }),
    ]);

    return {
      users,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async blockUser(blockerId: string, blockedId: string) {
    if (blockerId === blockedId) {
      throw { code: 'INVALID_OPERATION', message: 'You cannot block yourself.', status: 400 };
    }

    const target = await prisma.user.findUnique({ where: { id: blockedId } });
    if (!target) {
      throw { code: 'USER_NOT_FOUND', message: 'Target user does not exist.', status: 404 };
    }

    await prisma.blockedUser.upsert({
      where: {
        blockerId_blockedId: { blockerId, blockedId },
      },
      create: { blockerId, blockedId },
      update: {},
    });

    return { success: true, message: 'User has been blocked.' };
  }

  async unblockUser(blockerId: string, blockedId: string) {
    await prisma.blockedUser.deleteMany({
      where: { blockerId, blockedId },
    });

    return { success: true, message: 'User has been unblocked.' };
  }

  async getBlockedUsers(userId: string) {
    const blockedList = await prisma.blockedUser.findMany({
      where: { blockerId: userId },
      include: {
        blocked: {
          select: {
            id: true,
            username: true,
            displayName: true,
            avatarUrl: true,
          },
        },
      },
    });

    return blockedList.map((item) => item.blocked);
  }
}

export default new UserService();
