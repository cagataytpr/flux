/// Flux Application - Native Widget Manager
///
/// Syncs Isar data to Android SharedPreferences and iOS UserDefaults
/// so the native home screen widgets can display up-to-date information.
library;

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

const String appGroupId = 'group.com.cagatay.flux'; // Setup for iOS later if needed
const String androidWidgetName = 'FluxWidgetProvider';

class WidgetManager {
  static Future<void> init() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  static Future<void> updateWidgetData({
    required double totalBalance,
    required double currentMonthSpent,
    required double currentMonthBudget,
    required String currencySymbol,
  }) async {
    try {
      final remaining = currentMonthBudget - currentMonthSpent;
      
      await HomeWidget.saveWidgetData<String>('total_balance', '$currencySymbol${totalBalance.toStringAsFixed(0)}');
      await HomeWidget.saveWidgetData<String>('month_spent', '$currencySymbol${currentMonthSpent.toStringAsFixed(0)}');
      await HomeWidget.saveWidgetData<String>('month_remaining', '$currencySymbol${remaining.toStringAsFixed(0)}');
      
      // We can also save a progress percentage (0.0 to 1.0)
      final progress = currentMonthBudget > 0 
          ? (currentMonthSpent / currentMonthBudget).clamp(0.0, 1.0) 
          : 0.0;
      await HomeWidget.saveWidgetData<double>('budget_progress', progress);

      // Trigger widget update
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: 'FluxWidget',
      );
    } catch (e) {
      debugPrint('Error updating widget data: $e');
    }
  }

  /// Requests the OS to pin the widget to the home screen (Android only).
  static Future<bool> requestPinWidget() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await HomeWidget.requestPinWidget(
          name: androidWidgetName,
          androidName: androidWidgetName,
        );
        return true; // Assume success if no exception thrown
      }
      return false;
    } catch (e) {
      debugPrint('Error pinning widget: $e');
      return false;
    }
  }
}
