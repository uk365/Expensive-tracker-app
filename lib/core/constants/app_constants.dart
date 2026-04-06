class AppConstants {
  AppConstants._();

  static const appName = 'Finance Tracker';
  static const appVersion = '1.0.0';

  // Supabase — fill in your own project credentials
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_ANON_KEY',
  );

  // Pagination
  static const pageSize = 20;

  // Currencies
  static const defaultCurrency = 'INR';
  static const supportedCurrencies = [
    'USD', 'EUR', 'GBP', 'CAD', 'AUD',
    'JPY', 'CHF', 'SGD', 'INR', 'BRL',
  ];

  // Billing cycles
  static const billingCycles = [
    'one_time', 'daily', 'weekly', 'monthly', 'quarterly', 'yearly',
  ];

  static const billingCycleLabels = {
    'one_time': 'One-time',
    'daily': 'Daily',
    'weekly': 'Weekly',
    'monthly': 'Monthly',
    'quarterly': 'Quarterly',
    'yearly': 'Yearly',
  };

  // Node types
  static const nodeTypes = [
    'root', 'income', 'expense', 'client',
    'service', 'donation', 'category', 'subscription',
  ];

  // Payment methods
  static const paymentMethods = [
    'bank_transfer', 'credit_card', 'paypal',
    'crypto', 'cash', 'stripe', 'other',
  ];

  static const paymentMethodLabels = {
    'bank_transfer': 'Bank Transfer',
    'credit_card': 'Credit Card',
    'paypal': 'PayPal',
    'crypto': 'Crypto',
    'cash': 'Cash',
    'stripe': 'Stripe',
    'other': 'Other',
  };

  // Client statuses
  static const clientStatuses = ['active', 'inactive', 'lead', 'churned'];
  static const clientTiers = ['free', 'standard', 'premium', 'enterprise'];

  // Transaction statuses
  static const transactionStatuses = [
    'pending', 'completed', 'failed', 'refunded', 'cancelled',
  ];

  // Transaction types
  static const transactionTypes = ['income', 'expense', 'transfer', 'donation'];

  // Renewal warning threshold (days)
  static const renewalWarningDays = 7;
  static const renewalAlertDays = 30;
}
