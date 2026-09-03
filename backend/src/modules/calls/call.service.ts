import prisma from '../../prisma/client';
import { getSocketServer } from '../../socket/socket.server';

export class CallService {
  async initiateCall(callerId: string, receiverId: string, type: 'AUDIO' | 'VIDEO' = 'AUDIO', sdpOffer?: string) {
    if (callerId === receiverId) {
      throw { code: 'INVALID_RECEIVER', message: 'You cannot call yourself.', status: 400 };
    }

    // Check blocked status
    const isBlocked = await prisma.blockedUser.findFirst({
      where: {
        OR: [
          { blockerId: callerId, blockedId: receiverId },
          { blockerId: receiverId, blockedId: callerId },
        ],
      },
    });

    if (isBlocked) {
      throw { code: 'USER_BLOCKED', message: 'Cannot initiate call with this user.', status: 403 };
    }

    const caller = await prisma.user.findUnique({
      where: { id: callerId },
      select: { id: true, displayName: true, username: true, avatarUrl: true },
    });

    const call = await prisma.call.create({
      data: {
        callerId,
        receiverId,
        type,
        status: 'RINGING',
        sessions: sdpOffer
          ? {
              create: {
                sdpOffer,
              },
            }
          : undefined,
      },
      include: {
        caller: {
          select: { id: true, displayName: true, username: true, avatarUrl: true },
        },
        receiver: {
          select: { id: true, displayName: true, username: true, avatarUrl: true },
        },
      },
    });

    // Realtime notification to receiver
    const io = getSocketServer();
    if (io) {
      io.to(`user:${receiverId}`).emit('call:incoming', {
        callId: call.id,
        caller,
        type,
        sdpOffer,
      });
    }

    return call;
  }

  async acceptCall(userId: string, callId: string, sdpAnswer?: string) {
    const call = await prisma.call.findUnique({
      where: { id: callId },
    });

    if (!call || call.receiverId !== userId) {
      throw { code: 'CALL_NOT_FOUND', message: 'Call not found or unauthorized.', status: 404 };
    }

    const updated = await prisma.call.update({
      where: { id: callId },
      data: {
        status: 'ACCEPTED',
        startedAt: new Date(),
      },
    });

    if (sdpAnswer) {
      await prisma.callSession.create({
        data: {
          callId,
          sdpAnswer,
        },
      });
    }

    const io = getSocketServer();
    if (io) {
      io.to(`user:${call.callerId}`).emit('call:accepted', {
        callId,
        sdpAnswer,
      });
    }

    return updated;
  }

  async rejectCall(userId: string, callId: string) {
    const call = await prisma.call.findUnique({
      where: { id: callId },
    });

    if (!call || (call.receiverId !== userId && call.callerId !== userId)) {
      throw { code: 'CALL_NOT_FOUND', message: 'Call not found.', status: 404 };
    }

    const updated = await prisma.call.update({
      where: { id: callId },
      data: {
        status: 'REJECTED',
        endedAt: new Date(),
      },
    });

    const io = getSocketServer();
    if (io) {
      const otherId = call.callerId === userId ? call.receiverId : call.callerId;
      io.to(`user:${otherId}`).emit('call:rejected', { callId });
    }

    return updated;
  }

  async endCall(userId: string, callId: string) {
    const call = await prisma.call.findUnique({
      where: { id: callId },
    });

    if (!call || (call.receiverId !== userId && call.callerId !== userId)) {
      throw { code: 'CALL_NOT_FOUND', message: 'Call not found.', status: 404 };
    }

    const updated = await prisma.call.update({
      where: { id: callId },
      data: {
        status: 'ENDED',
        endedAt: new Date(),
      },
    });

    const io = getSocketServer();
    if (io) {
      const otherId = call.callerId === userId ? call.receiverId : call.callerId;
      io.to(`user:${otherId}`).emit('call:ended', { callId });
    }

    return updated;
  }

  async getCallHistory(userId: string) {
    const calls = await prisma.call.findMany({
      where: {
        OR: [{ callerId: userId }, { receiverId: userId }],
      },
      take: 50,
      orderBy: { createdAt: 'desc' },
      include: {
        caller: { select: { id: true, displayName: true, avatarUrl: true } },
        receiver: { select: { id: true, displayName: true, avatarUrl: true } },
      },
    });

    return calls;
  }
}

export default new CallService();
