import 'package:flutter/widgets.dart';

const _maxBreadcrumbs = 20;

class BreadcrumbEntry {
  final String type;
  final String name;
  final DateTime timestamp;
  final Map<String, dynamic>? extra;

  const BreadcrumbEntry({
    required this.type,
    required this.name,
    required this.timestamp,
    this.extra,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'name': name,
        'ts': timestamp.toIso8601String(),
        if (extra != null) ...extra!,
      };
}

class BreadcrumbService {
  BreadcrumbService._();
  static final BreadcrumbService instance = BreadcrumbService._();

  String _currentScreen = '';
  String _appVersion = '';
  String _buildNumber = '';

  final List<BreadcrumbEntry> _breadcrumbs = [];

  String get currentScreen => _currentScreen;

  void setAppVersion(String version, String buildNumber) {
    _appVersion = version;
    _buildNumber = buildNumber;
  }

  void setScreen(String screenName) {
    _currentScreen = screenName;
    _add('navigation', screenName);
  }

  void addAction(String action, {Map<String, dynamic>? extra}) {
    _add('action', action, extra: extra);
  }

  void _add(String type, String name, {Map<String, dynamic>? extra}) {
    _breadcrumbs.add(
      BreadcrumbEntry(
        type: type,
        name: name,
        timestamp: DateTime.now(),
        extra: extra,
      ),
    );
    if (_breadcrumbs.length > _maxBreadcrumbs) {
      _breadcrumbs.removeRange(0, _breadcrumbs.length - _maxBreadcrumbs);
    }
  }

  List<Map<String, dynamic>> getBreadcrumbs() =>
      _breadcrumbs.map((b) => b.toMap()).toList();

  Map<String, dynamic> buildErrorContext() {
    return {
      'current_screen': _currentScreen,
      'app_version': _appVersion,
      'build_number': _buildNumber,
      'breadcrumbs': getBreadcrumbs(),
    };
  }
}

final breadcrumb = BreadcrumbService.instance;

class BreadcrumbRouteObserver extends RouteObserver<ModalRoute<void>> {
  @override
  void didPush(Route<void> route, Route<void>? previousRoute) {
    super.didPush(route, previousRoute);
    _record(route);
  }

  @override
  void didReplace({Route<void>? newRoute, Route<void>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _record(newRoute);
  }

  void _record(Route<void> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      BreadcrumbService.instance.setScreen(name);
    }
  }
}
