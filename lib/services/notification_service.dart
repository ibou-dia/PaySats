import 'package:flutter/material.dart';

class NotificationMessage {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String? phoneNumber;
  final bool isRead;

  NotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.phoneNumber,
    this.isRead = false,
  });

  NotificationMessage copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? phoneNumber,
    bool? isRead,
  }) {
    return NotificationMessage(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationService extends ChangeNotifier {
  final List<NotificationMessage> _notifications = [];
  OverlayEntry? _currentOverlay;

  List<NotificationMessage> get notifications => List.unmodifiable(_notifications);
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Simule l'arrivée d'un SMS avec une notification visuelle
  Future<void> simulateSmsNotification({
    required BuildContext context,
    required String phoneNumber,
    required String message,
    String title = "Messages",
  }) async {
    // Créer la notification
    final notification = NotificationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: message,
      timestamp: DateTime.now(),
      phoneNumber: phoneNumber,
    );

    _notifications.insert(0, notification);
    notifyListeners();

    // Afficher la notification à l'écran
    await _showNotificationOverlay(context, notification);
  }

  /// Affiche une notification en overlay
  Future<void> _showNotificationOverlay(BuildContext context, NotificationMessage notification) async {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
    }

    _currentOverlay = OverlayEntry(
      builder: (context) => _NotificationOverlay(
        notification: notification,
        onDismiss: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
        onTap: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
          markAsRead(notification.id);
        },
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);

    // Auto-dismiss après 4 secondes
    Future.delayed(const Duration(seconds: 4), () {
      if (_currentOverlay != null) {
        _currentOverlay!.remove();
        _currentOverlay = null;
      }
    });
  }

  /// Marque une notification comme lue
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Marque toutes les notifications comme lues
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  /// Supprime une notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  /// Supprime toutes les notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _currentOverlay?.remove();
    super.dispose();
  }
}

class _NotificationOverlay extends StatefulWidget {
  final NotificationMessage notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _NotificationOverlay({
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<_NotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onTap,
            onPanUpdate: (details) {
              if (details.delta.dy < -5) {
                _dismiss();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.sms,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.notification.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,

                                decoration: TextDecoration.none,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatTime(widget.notification.timestamp),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.notification.body,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            decoration: TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Icon(
                      Icons.close,
                      color: Colors.grey.shade400,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'maintenant';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}