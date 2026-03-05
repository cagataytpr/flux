// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get dashboardTitle => 'Kontrol Paneli';

  @override
  String get settings => 'Ayarlar';

  @override
  String get history => 'Geçmiş';

  @override
  String get addExpense => 'Gider Ekle';

  @override
  String get totalBalance => 'Toplam Bakiye';

  @override
  String get subscriptions => 'Abonelikler';

  @override
  String get goals => 'Hedefler';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get stats => 'İstatistikler';

  @override
  String get dashboard => 'Kontrol Paneli';

  @override
  String get flux => 'Flux';

  @override
  String get myGoals => 'Hedeflerim';

  @override
  String get spendingByCategory => 'Kategoriye Göre Harcama';

  @override
  String get preferences => 'TERCİHLER';

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistem';

  @override
  String get light => 'Açık';

  @override
  String get dark => 'Koyu';

  @override
  String get language => 'Dil';

  @override
  String get defaultCurrency => 'Varsayılan Para Birimi';

  @override
  String get notificationsUppercase => 'BİLDİRİMLER';

  @override
  String get pushNotifications => 'Anlık Bildirimler';

  @override
  String get pushNotificationsSubtitle => 'Faturalar ve bütçe uyarıları';

  @override
  String get dataAndBackup => 'VERİ VE YEDEKLEME';

  @override
  String get exportData => 'Veriyi CSV\'ye Aktar';

  @override
  String get wipeAllData => 'Tüm Verileri Sil';

  @override
  String get errorLoadingSettings => 'Ayarlar yüklenirken hata oluştu';

  @override
  String get income => 'Gelir';

  @override
  String get expenses => 'Giderler';

  @override
  String get monthlyBudget => 'Aylık Bütçe';

  @override
  String get spent => 'Harcanan';

  @override
  String get remaining => 'Kalan';

  @override
  String get upcomingPayment => 'Yaklaşan Ödeme';

  @override
  String dueToday(String name) {
    return '$name bugün ödeniyor.';
  }

  @override
  String dueTomorrow(String name) {
    return '$name yarın ödeniyor.';
  }

  @override
  String dueInDays(String name, int days) {
    return '$name ödemesine $days gün kaldı.';
  }

  @override
  String get thisMonth => 'Bu Ay';

  @override
  String get analytics => 'Analizler';

  @override
  String get emptyAnalytics =>
      'Henüz analiz için yeterli veri yok.\nHarcama ekleyerek başla!';

  @override
  String get spentThisMonth => 'Bu Ay Harcanan';

  @override
  String get spendingRank => 'Harcama Sıralaması';

  @override
  String budgetPercentage(String percent) {
    return '%$percent bütçe';
  }

  @override
  String get fluxAiRealityCheck => 'FluxAI Gerçeklik Kontrolü';

  @override
  String get refresh => 'Yenile';

  @override
  String get analyzingSpending => 'Harcamaların analiz ediliyor...';

  @override
  String get analysisFailed => 'Analiz şu an yapılamıyor.';

  @override
  String get historyAndInsights => 'Geçmiş ve İçgörüler';

  @override
  String get all => 'Tümü';

  @override
  String get noExpensesCategory => 'Bu kategoride harcama yok.';

  @override
  String get noExpensesYet => 'Henüz harcama yok!\nHarcama zamanı?';

  @override
  String get catMarket => 'Market';

  @override
  String get catFood => 'Yemek';

  @override
  String get catBills => 'Faturalar';

  @override
  String get catSalary => 'Maaş';

  @override
  String get catInvestment => 'Yatırım';

  @override
  String get catTransport => 'Ulaşım';

  @override
  String get catEntertainment => 'Eğlence';

  @override
  String get catHealth => 'Sağlık';

  @override
  String savedSuccessfully(String name) {
    return '\"$name\" başarıyla kaydedildi! 🎉';
  }

  @override
  String get saveSubscription => 'Aboneliği Kaydet';

  @override
  String get saveTransaction => 'İşlemi Kaydet';

  @override
  String addToGoal(String name) {
    return '$name hedefine ekle';
  }

  @override
  String get cancel => 'İptal';

  @override
  String get add => 'Ekle';

  @override
  String get savingsGoals => 'Birikim Hedefleri';

  @override
  String get deleteGoal => 'Hedefi Sil?';

  @override
  String deleteGoalConfirm(String name) {
    return '\"$name\" hedefini silmek istediğinize emin misiniz?';
  }

  @override
  String get delete => 'Sil';

  @override
  String get createGoal => 'Hedef Oluştur';

  @override
  String get chooseIcon => 'İkon Seç';

  @override
  String get chooseColor => 'Renk Seç';

  @override
  String get receiptScanned => 'Fiş Tarandı';

  @override
  String get receiptScanError => 'Fiş okunamadı. Lütfen tekrar deneyin.';

  @override
  String get unlockFlux => 'Flux\'ın Kilidini Aç';

  @override
  String get monthlyBurnRate => 'Aylık Sabit Gider';

  @override
  String get totalScheduledPayments => 'Bu ay planlanan toplam ödemeler';

  @override
  String get noSubscriptions => 'Abonelik Bulunamadı';

  @override
  String get noSubscriptionsDesc =>
      'Netflix veya Spotify gibi servislerden fiş tarattığınızda, buraya kaydetmek için \"Her Ay Tekrarla?\" seçeneğini aktifleştirin.';

  @override
  String get goalAchieved => 'Hedefine Ulaştın! 🎉';

  @override
  String goalLeftToGo(String remaining) {
    return 'Hedefe $remaining kaldı!';
  }

  @override
  String get goalTargetDateReached =>
      'Hedef tarihine ulaşıldı. Değerlendirme zamanı!';

  @override
  String goalSavePerDay(String dailyTarget) {
    return 'Zamanında ulaşmak için günde $dailyTarget biriktir.';
  }

  @override
  String get goalEmptyStateDesc =>
      'Hayal kurmaya başla! Yeni bir araba, tatil veya acil durum fonu, hepsini buradan takip et.';

  @override
  String get newTransaction => 'Yeni İşlem';

  @override
  String get newTransactionDesc => 'Bunu nasıl eklemek istersin?';

  @override
  String get scanReceipt => 'Fiş Tara';

  @override
  String get scanReceiptDesc =>
      'Yapay zeka detayları saniyeler içinde çıkarsın';

  @override
  String get manualEntry => 'Manuel Ekleme';

  @override
  String get manualEntryDesc => 'Detayları kendin gir';

  @override
  String get regularSubscription => 'Düzenli Abonelik';

  @override
  String get regularSubscriptionDesc => 'Yeni bir tekrarlayan ödeme takip et';

  @override
  String get titleLabel => 'Başlık';

  @override
  String get titleHint => 'Örn. Market Alışverişi';

  @override
  String amountLabel(String sym) {
    return 'Tutar ($sym)';
  }

  @override
  String get amountHint => 'Örn. 150.50';

  @override
  String get categoryLabel => 'Kategori';

  @override
  String get dateLabel => 'Tarih';

  @override
  String get recurringSubscription => 'Düzenli Abonelik';

  @override
  String get recurringSubscriptionDesc =>
      'Bunu düzenli bir ödeme olarak takip eder';

  @override
  String get expenseType => 'Gider';

  @override
  String get incomeType => 'Gelir';

  @override
  String get monthlyCycle => 'Aylık';

  @override
  String get yearlyCycle => 'Yıllık';

  @override
  String get addSubscriptionTitle => 'Abonelik Ekle';

  @override
  String get requiredField => 'Zorunlu';

  @override
  String get invalidNumber => 'Geçersiz sayı';

  @override
  String get edit => 'Düzenle';

  @override
  String get deleteSubscriptionTitle => 'Aboneliği Sil';

  @override
  String deleteSubscriptionContent(String name) {
    return '$name aboneliğini silmek istediğine emin misin?';
  }

  @override
  String streakDays(int days) {
    return '$days Günlük Seri! 🔥';
  }

  @override
  String get eomForecast => 'Ay Sonu Tahmini';

  @override
  String get predictedBalance => 'Tahmini Bakiye';

  @override
  String forecastBasedOn(String sym, String amount) {
    return 'Günlük ortalama $sym$amount harcamanıza ve gelecek aboneliklere göre.';
  }

  @override
  String get homeScreenWidget => 'Ana Ekran Widget\'ı';

  @override
  String get widgetSetupDesc =>
      'Bakiye ve bütçe durumunu anlık görmek için ana ekranına widget ekle.';

  @override
  String get addToHomeScreen => 'Ana Ekrana Ekle';

  @override
  String get manualSetup => 'Manuel Kurulum Talimatları';

  @override
  String get widgetInstructionsTitle => 'Manuel olarak nasıl eklenir?';

  @override
  String get widgetInstructionsAndroid =>
      '1. Ana ekranda boş bir yere basılı tutun.\n2. \'Widget\'lar\' öğesine dokunun.\n3. \'Flux\' uygulamasını bulun ve widget\'ı ekranınıza sürükleyin.';

  @override
  String get widgetInstructionsiOS =>
      '1. Uygulamalar titreyene kadar ana ekranda boş bir yere basılı tutun.\n2. Sol üst köşedeki \'+\' butonuna dokunun.\n3. \'Flux\'ı arayın ve \'Widget Ekle\'ye dokunun.';

  @override
  String get pinWidgetError =>
      'Cihazınız otomatik eklemeyi desteklemiyor. Lütfen manuel olarak ekleyin.';

  @override
  String get done => 'Tamam';
}
