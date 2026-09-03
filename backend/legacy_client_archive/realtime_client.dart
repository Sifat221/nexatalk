import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';
import '../../services/persistence_service.dart';

class RealtimeClient {
  final PersistenceService _persistence;
  io.Socket? _socket;
  bool _isConnected = false;

  // Stream Controllers for broadcasting incoming realtime events
  final _messageNewController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _messageDeletedController = StreamController<Map<String, dynamic>>.broadcast();
  final _conversationUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _reactionUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _callEventController = StreamController<Map<String, dynamic>>.broadcast();

  // Public Streams
  Stream<Map<String, dynamic>> get onMessageNew => _messageNewController.stream;
  Stream<Map<String, dynamic>> get onMessageUpdated => _messageUpdatedController.stream;
  Stream<Map<String, dynamic>> get onMessageDeleted => _messageDeletedController.stream;
  Stream<Map<String, dynamic>> get onConversationUpdated => _conversationUpdatedController.stream;
  Stream<Map<String, dynamic>> get onTypingUpdate => _typingUpdateController.stream;
  Stream<Map<String, dynamic>> get onPresenceUpdate => _presenceUpdateController.stream;
  Stream<Map<String, dynamic>> get onReactionUpdated => _reactionUpdateController.stream;
  Stream<Map<String, dynamic>> get onCallEvent => _callEventController.stream;

  bool get isConnected => _isConnected;

  RealtimeClient(this._persistence);

  void connect() {
    final token = _persistence.getAccessToken();
    if (token == null) {
      debugPrint('[RealtimeClient] No access token available, skipping socket connection.');
      return;
    }

    if (_socket != null && _socket!.connected) {
      return;
    }

    _socket?.dispose();

    final options = io.OptionBuilder()
        .setTransports(['websocket', 'polling'])
        .setAuth({'token': token})
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionDelay(1000)
        .setReconnectionDelayMax(5000)
        .setReconnectionAttempts(10)
        .build();

    _socket = io.io(AppConfig.wsBaseUrl, options);

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('[RealtimeClient] Connected to WebSocket gateway.');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('[RealtimeClient] Disconnected from WebSocket gateway.');
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      debugPrint('[RealtimeClient] Connection error: $err');
    });

    // Listen to server events
    _socket!.on('message:new', (data) {
      if (data is Map) {
        _messageNewController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('message:updated', (data) {
      if (data is Map) {
        _messageUpdatedController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('message:deleted', (data) {
      if (data is Map) {
        _messageDeletedController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('conversation:updated', (data) {
      if (data is Map) {
        _conversationUpdatedController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('typing:update', (data) {
      if (data is Map) {
        _typingUpdateController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('presence:update', (data) {
      if (data is Map) {
        _presenceUpdateController.add(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('reaction:updated', (data) {
      if (data is Map) {
        _reactionUpdateController.add(Map<String, dynamic>.from(data));
      }
    });

    // Calls
    _socket!.on('call:incoming', (data) {
      if (data is Map) {
        _callEventController.add({'event': 'incoming', ...Map<String, dynamic>.from(data)});
      }
    });

    _socket!.on('call:accepted', (data) {
      if (data is Map) {
        _callEventController.add({'event': 'accepted', ...Map<String, dynamic>.from(data)});
      }
    });

    _socket!.on('call:rejected', (data) {
      if (data is Map) {
        _callEventController.add({'event': 'rejected', ...Map<String, dynamic>.from(data)});
      }
    });

    _socket!.on('call:ended', (data) {
      if (data is Map) {
        _callEventController.add({'event': 'ended', ...Map<String, dynamic>.from(data)});
      }
    });
  }

  void joinConversation(String conversationId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('conversation:join', {'conversationId': conversationId});
    }
  }

  void leaveConversation(String conversationId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('conversation:leave', {'conversationId': conversationId});
    }
  }

  void startTyping(String conversationId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('typing:start', {'conversationId': conversationId});
    }
  }

  void stopTyping(String conversationId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('typing:stop', {'conversationId': conversationId});
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _messageNewController.close();
    _messageUpdatedController.close();
    _messageDeletedController.close();
    _conversationUpdatedController.close();
    _typingUpdateController.close();
    _presenceUpdateController.close();
    _reactionUpdateController.close();
    _callEventController.close();
  }
}
