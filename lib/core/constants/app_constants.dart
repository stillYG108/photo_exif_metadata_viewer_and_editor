class AppConstants {
  // App Info
  static const String appName = 'EXIF Forensics Workbench';
  static const String appVersion = '2.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String forensicCasesCollection = 'forensic_cases';
  static const String serviceUsageCollection = 'service_usage';
  static const String activityLogsCollection = 'activity_logs';
  static const String evidenceReportsCollection = 'evidence_reports';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleAnalyst = 'analyst';
  static const String roleViewer = 'viewer';
  
  // User Status
  static const String statusActive = 'active';
  static const String statusSuspended = 'suspended';
  static const String statusPending = 'pending';
  
  // Case Status
  static const String caseStatusOpen = 'open';
  static const String caseStatusInProgress = 'in_progress';
  static const String caseStatusClosed = 'closed';
  static const String caseStatusArchived = 'archived';
  
  // Case Priority
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
  static const String priorityCritical = 'critical';
  
  // Event Types
  static const String eventLogin = 'login';
  static const String eventLogout = 'logout';
  static const String eventAnalysis = 'analysis';
  static const String eventEdit = 'edit';
  static const String eventExport = 'export';
  static const String eventError = 'error';
  static const String eventAccessDenied = 'access_denied';
  
  // Service Types
  static const String serviceAnalyzer = 'analyzer';
  static const String serviceEditor = 'editor';
  static const String serviceReporter = 'reporter';
  static const String serviceExporter = 'exporter';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxCaseNumberLength = 13; // FC-YYYY-NNNN
  static const int sha256HashLength = 64;
}
