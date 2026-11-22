import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_prayer_app/services/notification_service.dart';

void main() {
  final service = NotificationService();

  tearDown(() => service.setNavigationHandler(null));

  test('queues the tasbih destination until navigation is ready', () {
    service.setNavigationHandler(null);
    service.handleNotificationResponse(
      const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        payload: NotificationService.salawatNotificationPayload,
      ),
    );

    int? destination;
    service.setNavigationHandler((pageIndex) => destination = pageIndex);
    expect(destination, 4);
  });

  test('does not redirect unrelated notification responses', () {
    final destinations = <int>[];
    service.setNavigationHandler(destinations.add);
    service.handleNotificationResponse(
      const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        payload: 'firdaws:prayer-alarm',
      ),
    );

    expect(destinations, isEmpty);
  });
}
