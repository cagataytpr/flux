import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @flux.
  ///
  /// In en, this message translates to:
  /// **'Flux'**
  String get flux;

  /// No description provided for @myGoals.
  ///
  /// In en, this message translates to:
  /// **'My Goals'**
  String get myGoals;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get spendingByCategory;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @defaultCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default Currency'**
  String get defaultCurrency;

  /// No description provided for @notificationsUppercase.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notificationsUppercase;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders for bills and budget alerts'**
  String get pushNotificationsSubtitle;

  /// No description provided for @dataAndBackup.
  ///
  /// In en, this message translates to:
  /// **'DATA & BACKUP'**
  String get dataAndBackup;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data to CSV'**
  String get exportData;

  /// No description provided for @wipeAllData.
  ///
  /// In en, this message translates to:
  /// **'Wipe All Data'**
  String get wipeAllData;

  /// No description provided for @errorLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings'**
  String get errorLoadingSettings;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudget;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @upcomingPayment.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Payment'**
  String get upcomingPayment;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'{name} is due today.'**
  String dueToday(String name);

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{name} is due tomorrow.'**
  String dueTomorrow(String name);

  /// No description provided for @dueInDays.
  ///
  /// In en, this message translates to:
  /// **'{name} is due in {days} days.'**
  String dueInDays(String name, int days);

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @emptyAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Not enough data for analysis yet.\nStart by adding expenses!'**
  String get emptyAnalytics;

  /// No description provided for @spentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent This Month'**
  String get spentThisMonth;

  /// No description provided for @spendingRank.
  ///
  /// In en, this message translates to:
  /// **'Top Spending'**
  String get spendingRank;

  /// No description provided for @budgetPercentage.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of budget'**
  String budgetPercentage(String percent);

  /// No description provided for @fluxAiRealityCheck.
  ///
  /// In en, this message translates to:
  /// **'FluxAI Reality Check'**
  String get fluxAiRealityCheck;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @analyzingSpending.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your spending...'**
  String get analyzingSpending;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis is currently unavailable.'**
  String get analysisFailed;

  /// No description provided for @historyAndInsights.
  ///
  /// In en, this message translates to:
  /// **'History & Insights'**
  String get historyAndInsights;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noExpensesCategory.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this category.'**
  String get noExpensesCategory;

  /// No description provided for @noExpensesYet.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet!\nTime to spend?'**
  String get noExpensesYet;

  /// No description provided for @catMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get catMarket;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// No description provided for @catBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get catBills;

  /// No description provided for @catSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catSalary;

  /// No description provided for @catInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get catInvestment;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved \"{name}\" successfully! 🎉'**
  String savedSuccessfully(String name);

  /// No description provided for @saveSubscription.
  ///
  /// In en, this message translates to:
  /// **'Save Subscription'**
  String get saveSubscription;

  /// No description provided for @saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get saveTransaction;

  /// No description provided for @addToGoal.
  ///
  /// In en, this message translates to:
  /// **'Add to {name}'**
  String addToGoal(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @savingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoals;

  /// No description provided for @deleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal?'**
  String get deleteGoal;

  /// No description provided for @deleteGoalConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteGoalConfirm(String name);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// No description provided for @chooseIcon.
  ///
  /// In en, this message translates to:
  /// **'Choose Icon'**
  String get chooseIcon;

  /// No description provided for @chooseColor.
  ///
  /// In en, this message translates to:
  /// **'Choose Color'**
  String get chooseColor;

  /// No description provided for @receiptScanned.
  ///
  /// In en, this message translates to:
  /// **'Receipt Scanned'**
  String get receiptScanned;

  /// No description provided for @receiptScanError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the receipt. Please try again.'**
  String get receiptScanError;

  /// No description provided for @unlockFlux.
  ///
  /// In en, this message translates to:
  /// **'Unlock Flux'**
  String get unlockFlux;

  /// No description provided for @monthlyBurnRate.
  ///
  /// In en, this message translates to:
  /// **'Monthly Burn Rate'**
  String get monthlyBurnRate;

  /// No description provided for @totalScheduledPayments.
  ///
  /// In en, this message translates to:
  /// **'Total scheduled payments this month'**
  String get totalScheduledPayments;

  /// No description provided for @noSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'No Subscriptions'**
  String get noSubscriptions;

  /// No description provided for @noSubscriptionsDesc.
  ///
  /// In en, this message translates to:
  /// **'When you scan a receipt from services like Netflix or Spotify, enable \"Repeat Monthly?\" to track it here.'**
  String get noSubscriptionsDesc;

  /// No description provided for @goalAchieved.
  ///
  /// In en, this message translates to:
  /// **'Goal Achieved! 🎉'**
  String get goalAchieved;

  /// No description provided for @goalLeftToGo.
  ///
  /// In en, this message translates to:
  /// **'{remaining} left to go!'**
  String goalLeftToGo(String remaining);

  /// No description provided for @goalTargetDateReached.
  ///
  /// In en, this message translates to:
  /// **'Target date reached. Time to evaluate!'**
  String get goalTargetDateReached;

  /// No description provided for @goalSavePerDay.
  ///
  /// In en, this message translates to:
  /// **'Save {dailyTarget} / day to reach it in time.'**
  String goalSavePerDay(String dailyTarget);

  /// No description provided for @goalEmptyStateDesc.
  ///
  /// In en, this message translates to:
  /// **'Start dreaming! Whether it\'s a new car, a vacation, or an emergency fund, track it here.'**
  String get goalEmptyStateDesc;

  /// No description provided for @newTransaction.
  ///
  /// In en, this message translates to:
  /// **'New Transaction'**
  String get newTransaction;

  /// No description provided for @newTransactionDesc.
  ///
  /// In en, this message translates to:
  /// **'How would you like to add this?'**
  String get newTransactionDesc;

  /// No description provided for @scanReceipt.
  ///
  /// In en, this message translates to:
  /// **'Scan Receipt'**
  String get scanReceipt;

  /// No description provided for @scanReceiptDesc.
  ///
  /// In en, this message translates to:
  /// **'AI will instantly extract the details'**
  String get scanReceiptDesc;

  /// No description provided for @manualEntry.
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get manualEntry;

  /// No description provided for @manualEntryDesc.
  ///
  /// In en, this message translates to:
  /// **'Type in the details yourself'**
  String get manualEntryDesc;

  /// No description provided for @regularSubscription.
  ///
  /// In en, this message translates to:
  /// **'Regular Subscription'**
  String get regularSubscription;

  /// No description provided for @regularSubscriptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Track a new recurring payment'**
  String get regularSubscriptionDesc;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Grocery Shopping'**
  String get titleHint;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount ({sym})'**
  String amountLabel(String sym);

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 150.50'**
  String get amountHint;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @recurringSubscription.
  ///
  /// In en, this message translates to:
  /// **'Recurring Subscription'**
  String get recurringSubscription;

  /// No description provided for @recurringSubscriptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically tracks this as a payment'**
  String get recurringSubscriptionDesc;

  /// No description provided for @expenseType.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseType;

  /// No description provided for @incomeType.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeType;

  /// No description provided for @monthlyCycle.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyCycle;

  /// No description provided for @yearlyCycle.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearlyCycle;

  /// No description provided for @addSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Subscription'**
  String get addSubscriptionTitle;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteSubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Subscription'**
  String get deleteSubscriptionTitle;

  /// No description provided for @deleteSubscriptionContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String deleteSubscriptionContent(String name);

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} Day Streak! 🔥'**
  String streakDays(int days);

  /// No description provided for @eomForecast.
  ///
  /// In en, this message translates to:
  /// **'End of Month Forecast'**
  String get eomForecast;

  /// No description provided for @predictedBalance.
  ///
  /// In en, this message translates to:
  /// **'Predicted Balance'**
  String get predictedBalance;

  /// No description provided for @forecastBasedOn.
  ///
  /// In en, this message translates to:
  /// **'Based on your daily spend of {sym}{amount} and upcoming subscriptions.'**
  String forecastBasedOn(String sym, String amount);

  /// No description provided for @homeScreenWidget.
  ///
  /// In en, this message translates to:
  /// **'Home Screen Widget'**
  String get homeScreenWidget;

  /// No description provided for @widgetSetupDesc.
  ///
  /// In en, this message translates to:
  /// **'Add a widget to your home screen to see your balance and budget at a glance.'**
  String get widgetSetupDesc;

  /// No description provided for @addToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Add to Home Screen'**
  String get addToHomeScreen;

  /// No description provided for @manualSetup.
  ///
  /// In en, this message translates to:
  /// **'Manual Setup Instructions'**
  String get manualSetup;

  /// No description provided for @widgetInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'How to add manually'**
  String get widgetInstructionsTitle;

  /// No description provided for @widgetInstructionsAndroid.
  ///
  /// In en, this message translates to:
  /// **'1. Long press on your home screen.\n2. Tap \'Widgets\'.\n3. Find \'Flux\' and drag the widget to your screen.'**
  String get widgetInstructionsAndroid;

  /// No description provided for @widgetInstructionsiOS.
  ///
  /// In en, this message translates to:
  /// **'1. Long press an empty area on your home screen until the apps jiggle.\n2. Tap the \'+\' button in the upper-left corner.\n3. Search for \'Flux\' and tap \'Add Widget\'.'**
  String get widgetInstructionsiOS;

  /// No description provided for @pinWidgetError.
  ///
  /// In en, this message translates to:
  /// **'Your device doesn\'t support automatic pinning. Please add the widget manually.'**
  String get pinWidgetError;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
