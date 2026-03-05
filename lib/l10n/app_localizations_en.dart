// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get settings => 'Settings';

  @override
  String get history => 'History';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get goals => 'Goals';

  @override
  String get home => 'Home';

  @override
  String get stats => 'Stats';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get flux => 'Flux';

  @override
  String get myGoals => 'My Goals';

  @override
  String get spendingByCategory => 'Spending by Category';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get theme => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get defaultCurrency => 'Default Currency';

  @override
  String get notificationsUppercase => 'NOTIFICATIONS';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle =>
      'Reminders for bills and budget alerts';

  @override
  String get dataAndBackup => 'DATA & BACKUP';

  @override
  String get exportData => 'Export Data to CSV';

  @override
  String get wipeAllData => 'Wipe All Data';

  @override
  String get errorLoadingSettings => 'Error loading settings';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get upcomingPayment => 'Upcoming Payment';

  @override
  String dueToday(String name) {
    return '$name is due today.';
  }

  @override
  String dueTomorrow(String name) {
    return '$name is due tomorrow.';
  }

  @override
  String dueInDays(String name, int days) {
    return '$name is due in $days days.';
  }

  @override
  String get thisMonth => 'This Month';

  @override
  String get analytics => 'Analytics';

  @override
  String get emptyAnalytics =>
      'Not enough data for analysis yet.\nStart by adding expenses!';

  @override
  String get spentThisMonth => 'Spent This Month';

  @override
  String get spendingRank => 'Top Spending';

  @override
  String budgetPercentage(String percent) {
    return '$percent% of budget';
  }

  @override
  String get fluxAiRealityCheck => 'FluxAI Reality Check';

  @override
  String get refresh => 'Refresh';

  @override
  String get analyzingSpending => 'Analyzing your spending...';

  @override
  String get analysisFailed => 'Analysis is currently unavailable.';

  @override
  String get historyAndInsights => 'History & Insights';

  @override
  String get all => 'All';

  @override
  String get noExpensesCategory => 'No expenses in this category.';

  @override
  String get noExpensesYet => 'No expenses yet!\nTime to spend?';

  @override
  String get catMarket => 'Market';

  @override
  String get catFood => 'Food';

  @override
  String get catBills => 'Bills';

  @override
  String get catSalary => 'Salary';

  @override
  String get catInvestment => 'Investment';

  @override
  String get catTransport => 'Transport';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catHealth => 'Health';

  @override
  String savedSuccessfully(String name) {
    return 'Saved \"$name\" successfully! 🎉';
  }

  @override
  String get saveSubscription => 'Save Subscription';

  @override
  String get saveTransaction => 'Save Transaction';

  @override
  String addToGoal(String name) {
    return 'Add to $name';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get savingsGoals => 'Savings Goals';

  @override
  String get deleteGoal => 'Delete Goal?';

  @override
  String deleteGoalConfirm(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get createGoal => 'Create Goal';

  @override
  String get chooseIcon => 'Choose Icon';

  @override
  String get chooseColor => 'Choose Color';

  @override
  String get receiptScanned => 'Receipt Scanned';

  @override
  String get receiptScanError =>
      'Could not read the receipt. Please try again.';

  @override
  String get unlockFlux => 'Unlock Flux';

  @override
  String get monthlyBurnRate => 'Monthly Burn Rate';

  @override
  String get totalScheduledPayments => 'Total scheduled payments this month';

  @override
  String get noSubscriptions => 'No Subscriptions';

  @override
  String get noSubscriptionsDesc =>
      'When you scan a receipt from services like Netflix or Spotify, enable \"Repeat Monthly?\" to track it here.';

  @override
  String get goalAchieved => 'Goal Achieved! 🎉';

  @override
  String goalLeftToGo(String remaining) {
    return '$remaining left to go!';
  }

  @override
  String get goalTargetDateReached => 'Target date reached. Time to evaluate!';

  @override
  String goalSavePerDay(String dailyTarget) {
    return 'Save $dailyTarget / day to reach it in time.';
  }

  @override
  String get goalEmptyStateDesc =>
      'Start dreaming! Whether it\'s a new car, a vacation, or an emergency fund, track it here.';

  @override
  String get newTransaction => 'New Transaction';

  @override
  String get newTransactionDesc => 'How would you like to add this?';

  @override
  String get scanReceipt => 'Scan Receipt';

  @override
  String get scanReceiptDesc => 'AI will instantly extract the details';

  @override
  String get manualEntry => 'Manual Entry';

  @override
  String get manualEntryDesc => 'Type in the details yourself';

  @override
  String get regularSubscription => 'Regular Subscription';

  @override
  String get regularSubscriptionDesc => 'Track a new recurring payment';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleHint => 'e.g. Grocery Shopping';

  @override
  String amountLabel(String sym) {
    return 'Amount ($sym)';
  }

  @override
  String get amountHint => 'e.g. 150.50';

  @override
  String get categoryLabel => 'Category';

  @override
  String get dateLabel => 'Date';

  @override
  String get recurringSubscription => 'Recurring Subscription';

  @override
  String get recurringSubscriptionDesc =>
      'Automatically tracks this as a payment';

  @override
  String get expenseType => 'Expense';

  @override
  String get incomeType => 'Income';

  @override
  String get monthlyCycle => 'Monthly';

  @override
  String get yearlyCycle => 'Yearly';

  @override
  String get addSubscriptionTitle => 'Add Subscription';

  @override
  String get requiredField => 'Required';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get edit => 'Edit';

  @override
  String get deleteSubscriptionTitle => 'Delete Subscription';

  @override
  String deleteSubscriptionContent(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String streakDays(int days) {
    return '$days Day Streak! 🔥';
  }

  @override
  String get eomForecast => 'End of Month Forecast';

  @override
  String get predictedBalance => 'Predicted Balance';

  @override
  String forecastBasedOn(String sym, String amount) {
    return 'Based on your daily spend of $sym$amount and upcoming subscriptions.';
  }

  @override
  String get homeScreenWidget => 'Home Screen Widget';

  @override
  String get widgetSetupDesc =>
      'Add a widget to your home screen to see your balance and budget at a glance.';

  @override
  String get addToHomeScreen => 'Add to Home Screen';

  @override
  String get manualSetup => 'Manual Setup Instructions';

  @override
  String get widgetInstructionsTitle => 'How to add manually';

  @override
  String get widgetInstructionsAndroid =>
      '1. Long press on your home screen.\n2. Tap \'Widgets\'.\n3. Find \'Flux\' and drag the widget to your screen.';

  @override
  String get widgetInstructionsiOS =>
      '1. Long press an empty area on your home screen until the apps jiggle.\n2. Tap the \'+\' button in the upper-left corner.\n3. Search for \'Flux\' and tap \'Add Widget\'.';

  @override
  String get pinWidgetError =>
      'Your device doesn\'t support automatic pinning. Please add the widget manually.';

  @override
  String get done => 'Done';
}
