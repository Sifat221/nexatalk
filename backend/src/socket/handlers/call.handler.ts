import { Server, Socket } from 'socket.io';

export const registerCallHandlers = (io: Server, socket: Socket) => {
  const user = socket.data.user;

  // WebRTC ICE Candidate relay
  socket.on('call:signal:candidate', (data: { targetUserId: string; candidate: any; callId: string }) => {
    if (!data?.targetUserId || !data?.candidate) return;

    io.to(`user:${data.targetUserId}`).emit('call:signal:candidate', {
      fromUserId: user.id,
      callId: data.callId,
      candidate: data.candidate,
    });
  });

  // WebRTC SDP Offer relay
  socket.on('call:signal:offer', (data: { targetUserId: string; sdp: any; callId: string; type: string }) => {
    if (!data?.targetUserId || !data?.sdp) return;

    io.to(`user:${data.targetUserId}`).emit('call:signal:offer', {
      fromUserId: user.id,
      callId: data.callId,
      type: data.type,
      sdp: data.sdp,
    });
  });

  // WebRTC SDP Answer relay
  socket.on('call:signal:answer', (data: { targetUserId: string; sdp: any; callId: string }) => {
    if (!data?.targetUserId || !data?.sdp) return;

    io.to(`user:${data.targetUserId}`).emit('call:signal:answer', {
      fromUserId: user.id,
      callId: data.callId,
      sdp: data.sdp,
    });
  });
};
