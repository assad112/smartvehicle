import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/notification_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    print('📱 NotificationsScreen build - userId: $userId');
    print('📱 NotificationsScreen build - currentUser: ${authProvider.currentUser?.email}');

    if (userId == null) {
      print('⚠️ NotificationsScreen - No userId found');
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Notifications',
          showBackButton: false,
          showNotifications: false,
        ),
        body: const Center(child: Text('No user logged in')),
      );
    }

    final databaseService = DatabaseService();
    print('📱 NotificationsScreen - DatabaseService created');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: false,
        showNotifications: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            tooltip: 'Mark all as read',
            onPressed: () async {
              await databaseService.markAllNotificationsAsRead(userId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: databaseService.getNotifications(userId),
        builder: (context, snapshot) {
          print('📱 NotificationsScreen - ConnectionState: ${snapshot.connectionState}');
          print('📱 NotificationsScreen - HasError: ${snapshot.hasError}');
          print('📱 NotificationsScreen - HasData: ${snapshot.hasData}');
          print('📱 NotificationsScreen - UserId: $userId');
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('❌ NotificationsScreen Error: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final notifications = snapshot.data ?? [];
          print('📱 NotificationsScreen - Notifications count: ${notifications.length}');

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You will be notified when there are new updates',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // StreamBuilder will automatically refresh
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(context, notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, NotificationModel notification) {
    final typeColor = _getNotificationTypeColor(notification.type);
    final typeIcon = _getNotificationTypeIcon(notification.type);
    final databaseService = DatabaseService();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: notification.isRead
            ? LinearGradient(
                colors: [
                  Colors.white,
                  AppTheme.backgroundColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  Colors.white,
                  typeColor.withOpacity(0.08),
                  typeColor.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: notification.isRead
                ? Colors.black.withOpacity(0.06)
                : typeColor.withOpacity(0.2),
            blurRadius: notification.isRead ? 8 : 20,
            offset: const Offset(0, 6),
            spreadRadius: notification.isRead ? 0 : 2,
          ),
        ],
        border: Border.all(
          color: notification.isRead
              ? AppTheme.textSecondary.withOpacity(0.1)
              : typeColor.withOpacity(0.4),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            if (!notification.isRead) {
              await databaseService.markNotificationAsRead(notification.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container with enhanced design
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        typeColor.withOpacity(0.25),
                        typeColor.withOpacity(0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: typeColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: notification.isRead
                                            ? FontWeight.w600
                                            : FontWeight.bold,
                                        color: notification.isRead
                                            ? AppTheme.textPrimary
                                            : typeColor,
                                        fontSize: 16,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notification.message,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.textPrimary,
                                        height: 1.6,
                                        fontSize: 14,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 14,
                              height: 14,
                              margin: const EdgeInsets.only(top: 2, right: 4),
                              decoration: BoxDecoration(
                                color: typeColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: typeColor.withOpacity(0.6),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.backgroundColor,
                              AppTheme.backgroundColor.withOpacity(0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.textSecondary.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.access_time,
                                size: 12,
                                color: typeColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(notification.createdAt),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationTypeColor(String type) {
    switch (type) {
      case AppConstants.notificationTypeAlert:
        return AppTheme.errorColor;
      case AppConstants.notificationTypeWarning:
        return AppTheme.warningColor;
      case AppConstants.notificationTypeMaintenance:
        return AppTheme.primaryColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getNotificationTypeIcon(String type) {
    switch (type) {
      case AppConstants.notificationTypeAlert:
        return Icons.error;
      case AppConstants.notificationTypeWarning:
        return Icons.warning;
      case AppConstants.notificationTypeMaintenance:
        return Icons.build;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minute(s) ago';
      }
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day(s) ago';
    } else {
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }
  }
}

