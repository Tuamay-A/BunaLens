// All user-facing strings in English and Amharic.
// Add new strings here and reference them via L.t('key').

class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> values = {
    'en': {
      // App
      'app_name':           'BunaLens',
      'app_tagline':        'See your beans. Know your grade.',

      // Splash
      'loading':            'Loading…',

      // Home
      'home_title':         'BunaLens',
      'hero_title':         'Grade a coffee bean',
      'hero_body':          'Take a photo or pick one from your gallery. '
                            'BunaLens will predict its class and show what it looked at.',
      'scan_bean':          'Scan a bean',
      'recent_scans':       'Recent scans',
      'see_all':            'See all',
      'no_scans_yet':       'No scans yet',

      // Camera
      'camera_title':       'Scan a bean',
      'camera_instruction': 'Place one bean in the center\nof the frame, then capture.',
      'take_photo':         'Take a photo',
      'pick_gallery':       'Pick from gallery',
      'analyzing':          'Analyzing…',
      'camera_error':       'Camera error',
      'gallery_error':      'Gallery error',
      'grading_failed':     'Grading failed',

      // Result
      'result_title':       'Result',
      'class_probabilities':'Class probabilities',
      'confidence':         'Confidence',
      'unsure_warning':     'Low confidence — retake the photo for a better result.',
      'not_a_bean':         'This doesn\'t look like a coffee bean. Please try again.',
      'try_again':          'Try again',

      // History
      'history_title':      'History',
      'no_history':         'No history yet',
      'clear_history':      'Clear history',
      'clear_history_q':    'Clear history?',
      'cannot_undo':        'This cannot be undone.',
      'cancel':             'Cancel',
      'clear':              'Clear',

      // Classes
      'class_defect':       'Defect',
      'class_longberry':    'Longberry',
      'class_peaberry':     'Peaberry',
      'class_premium':      'Premium',

      // Class descriptions
      'desc_defect':        'Damaged, discolored, or broken bean',
      'desc_longberry':     'Standard elongated bean',
      'desc_peaberry':      'Round single-lobed bean',
      'desc_premium':       'Top-grade uniform bean',

      // About
      'about_title':        'About',
      'about_body':         'BunaLens uses an EfficientNet-B0 convolutional neural network '
                            'trained on 8,000 labeled Ethiopian coffee bean images to classify '
                            'each bean into one of four categories: Defect, Longberry, '
                            'Peaberry, and Premium.',
      'about_disclaimer':   'This app is intended as an advisory tool. It supports — but does '
                            'not replace — trained Q-graders.',
      'model_arch':         'Model: EfficientNet-B0',
      'model_arch_sub':     'Transfer learning, ImageNet pretrained',
      'model_acc':          'Test accuracy: 95.58%',
      'model_acc_sub':      '4-class classification on held-out test set',
      'on_device':          'On-device inference',
      'on_device_sub':      'TensorFlow Lite — works offline',

      // Settings
      'settings_title':     'Settings',
      'appearance':         'Appearance',
      'theme_system':       'System',
      'theme_light':        'Light',
      'theme_dark':         'Dark',
      'language':           'Language',
      'lang_english':       'English',
      'lang_amharic':       'አማርኛ',
      'data':               'Data',

      // Authentication
      'auth_sign_in':       'Sign in',
      'auth_sign_up':       'Sign up',
      'auth_sign_out':      'Sign out',
      'auth_email':         'Email',
      'auth_password':      'Password',
      'auth_confirm_password': 'Confirm password',
      'auth_display_name':  'Display name',
      'auth_sign_in_btn':   'Sign in',
      'auth_sign_up_btn':   'Create account',
      'auth_have_account':  'Already have an account?',
      'auth_no_account':    'Don\'t have an account?',
      'auth_forgot_password': 'Forgot password?',
      'auth_reset_password': 'Reset password',
      'auth_send_reset':    'Send reset link',
      'auth_back_to_sign_in': 'Back to sign in',
      'auth_or_continue_with': 'Or continue with',
      'auth_reset_email_sent': 'Password reset email sent',
      'auth_check_inbox':   'Check your inbox for reset instructions',
      
      // Auth validation
      'auth_invalid_email': 'Please enter a valid email',
      'auth_weak_password': 'Password must be at least 8 characters with 1 uppercase and 1 digit',
      'auth_password_mismatch': 'Passwords do not match',
      'auth_email_required': 'Email is required',
      'auth_password_required': 'Password is required',
      'auth_name_required': 'Display name is required',
      
      // Auth errors
      'auth_error_generic': 'An error occurred. Please try again.',
      'auth_error_network': 'Network error. Check your connection.',
      'auth_error_unauthenticated': 'Please sign in to continue',
      
      // Onboarding
      'onboarding_skip':    'Skip',
      'onboarding_next':    'Next',
      'onboarding_done':    'Get started',
      'onboarding_title_1': 'Scan any bean',
      'onboarding_body_1':  'Point your camera at a coffee bean and get instant quality grading',
      'onboarding_title_2': 'Get an honest grade',
      'onboarding_body_2':  'AI-powered analysis classifies beans into 4 quality categories',
      'onboarding_title_3': 'Works offline',
      'onboarding_body_3':  'All processing happens on your device. No internet needed.',
      
      // Dashboard/Home
      'dashboard_greeting': 'Hello',
      'dashboard_scan_card_title': 'Scan a coffee bean',
      'dashboard_scan_card_body': 'Get instant quality grading',
      'dashboard_stats_total': 'Total scans',
      'dashboard_stats_week': 'This week',
      'dashboard_stats_premium': 'Premium beans',
      'dashboard_recent':   'Recent scans',
      'dashboard_see_all':  'See all',
      
      // History filters
      'history_filter_all': 'All',
      'history_filter_defect': 'Defect',
      'history_filter_longberry': 'Longberry',
      'history_filter_peaberry': 'Peaberry',
      'history_filter_premium': 'Premium',
      'history_search_hint': 'Search scans...',
      
      // Scan detail
      'scan_detail_title':  'Scan details',
      'scan_detail_notes':  'Notes',
      'scan_detail_add_notes': 'Add notes...',
      'scan_detail_edit':   'Edit',
      'scan_detail_delete': 'Delete scan',
      'scan_detail_confirm_delete': 'Delete this scan?',
      'scan_detail_share':  'Share',
      'scan_detail_metadata': 'Metadata',
      'scan_detail_timestamp': 'Scanned',
      'scan_detail_device': 'Device',
      
      // Profile
      'profile_title':      'Profile',
      'profile_display_name': 'Display name',
      'profile_email':      'Email',
      'profile_language':   'Language',
      'profile_theme':      'Theme',
      'profile_cloud_sync': 'Cloud sync',
      'profile_last_sync':  'Last synced',
      'profile_never_synced': 'Never synced',
      'profile_edit':       'Edit profile',
      'profile_save':       'Save',
      
      // Settings (extended)
      'settings_data_sync': 'Data & sync',
      'settings_clear_local': 'Clear local data',
      'settings_force_sync': 'Sync now',
      'settings_danger_zone': 'Danger zone',
      'settings_delete_account': 'Delete account',
      'settings_confirm_delete_account': 'Delete your account and all data?',
      'settings_confirm_clear_data': 'Clear all local scans?',
      
      // Sync status
      'sync_synced':        'Synced',
      'sync_local_only':    'Local only',
      'sync_syncing':       'Syncing...',
      'sync_failed':        'Sync failed',
      'sync_retry':         'Retry',
      'sync_disabled':      'Sync disabled',
      'sync_enabled':       'Sync enabled',
      
      // Common actions
      'save':               'Save',
      'delete':             'Delete',
      'edit':               'Edit',
      'share':              'Share',
      'retry':              'Retry',
      'ok':                 'OK',
      'yes':                'Yes',
      'no':                 'No',
    },

    'am': {
      // App
      'app_name':           'ቡናሌንስ',
      'app_tagline':        'ባቄላዎን ይመልከቱ። ደረጃውን ያውቁ።',

      // Splash
      'loading':            'በመጫን ላይ…',

      // Home
      'home_title':         'ቡናሌንስ',
      'hero_title':         'ባቄላ ይመዝኑ',
      'hero_body':          'ፎቶ ያንሱ ወይም ከጋለሪ ይምረጡ። ቡናሌንስ ዓይነቱን ይተነብያል '
                            'እና የተመለከተውን ያሳያል።',
      'scan_bean':          'ባቄላ ይቃኙ',
      'recent_scans':       'የቅርብ ጊዜ ቅኝቶች',
      'see_all':            'ሁሉንም ይመልከቱ',
      'no_scans_yet':       'እስካሁን ቅኝት የለም',

      // Camera
      'camera_title':       'ባቄላ ይቃኙ',
      'camera_instruction': 'አንድ ባቄላ በፍሬሙ መሃል\nያስቀምጡ፣ ከዚያ ያንሱ።',
      'take_photo':         'ፎቶ ያንሱ',
      'pick_gallery':       'ከጋለሪ ይምረጡ',
      'analyzing':          'በመተንተን ላይ…',
      'camera_error':       'የካሜራ ስህተት',
      'gallery_error':      'የጋለሪ ስህተት',
      'grading_failed':     'መመዘን አልተሳካም',

      // Result
      'result_title':       'ውጤት',
      'class_probabilities':'የዓይነት እድሎች',
      'confidence':         'እምነት',
      'unsure_warning':     'ዝቅተኛ እምነት — ለተሻለ ውጤት ፎቶውን እንደገና ያንሱ።',
      'not_a_bean':         'ይህ የቡና ባቄላ አይመስልም። እባክዎ እንደገና ይሞክሩ።',
      'try_again':          'እንደገና ይሞክሩ',

      // History
      'history_title':      'ታሪክ',
      'no_history':         'እስካሁን ታሪክ የለም',
      'clear_history':      'ታሪክ አጥፋ',
      'clear_history_q':    'ታሪክ ያጥፉ?',
      'cannot_undo':        'ይህ መመለስ አይቻልም።',
      'cancel':             'ተው',
      'clear':              'አጥፋ',

      // Classes
      'class_defect':       'ጉድለት',
      'class_longberry':    'ሎንግቤሪ',
      'class_peaberry':     'ፒበሪ',
      'class_premium':      'ፕሪሚየም',

      // Class descriptions
      'desc_defect':        'የተበላሸ፣ ቀለም የተለወጠ ወይም የተሰበረ ባቄላ',
      'desc_longberry':     'መደበኛ ረጅም ባቄላ',
      'desc_peaberry':      'ክብ ነጠላ አንገት ያለው ባቄላ',
      'desc_premium':       'ከፍተኛ ደረጃ አንድ ዓይነት ባቄላ',

      // About
      'about_title':        'ስለ መተግበሪያው',
      'about_body':         'ቡናሌንስ በ 8,000 ምልክት የተደረገባቸው የኢትዮጵያ ቡና ባቄላ ምስሎች '
                            'ላይ የተሰለጠነ EfficientNet-B0 ኮንቮሉሽናል ነርቭ ኔትወርክ ይጠቀማል። '
                            'እያንዳንዱን ባቄላ በአራት ምድቦች ይመድባል፦ ጉድለት፣ ሎንግቤሪ፣ ፒበሪ እና ፕሪሚየም።',
      'about_disclaimer':   'ይህ መተግበሪያ እንደ አማካሪ መሳሪያ ነው። የሰለጠኑ የጥራት ግምገማ '
                            'ባለሙያዎችን ይደግፋል — አይተካም።',
      'model_arch':         'ሞዴል፦ EfficientNet-B0',
      'model_arch_sub':     'የተላለፈ ትምህርት፣ በ ImageNet የተሰለጠነ',
      'model_acc':          'የፍተሻ ትክክለኛነት፦ 95.58%',
      'model_acc_sub':      'የ 4 ክፍል ምድብ በተጠበቀ የፍተሻ ስብስብ',
      'on_device':          'በመሳሪያው ላይ ማመዛዘን',
      'on_device_sub':      'TensorFlow Lite — ያለ ኢንተርኔት ይሰራል',

      // Settings
      'settings_title':     'ቅንብሮች',
      'appearance':         'አቀራረብ',
      'theme_system':       'የስርዓቱ',
      'theme_light':        'ብሩህ',
      'theme_dark':         'ጨለማ',
      'language':           'ቋንቋ',
      'lang_english':       'English',
      'lang_amharic':       'አማርኛ',
      'data':               'ውሂብ',

      // Authentication
      'auth_sign_in':       'ግባ',
      'auth_sign_up':       'ተመዝገብ',
      'auth_sign_out':      'ውጣ',
      'auth_email':         'ኢሜይል',
      'auth_password':      'የይለፍ ቃል',
      'auth_confirm_password': 'የይለፍ ቃል አረጋግጥ',
      'auth_display_name':  'ስም',
      'auth_sign_in_btn':   'ግባ',
      'auth_sign_up_btn':   'መለያ ፍጠር',
      'auth_have_account':  'መለያ አለዎት?',
      'auth_no_account':    'መለያ የለዎትም?',
      'auth_forgot_password': 'የይለፍ ቃል ረሱት?',
      'auth_reset_password': 'የይለፍ ቃል ዳግም አስጀምር',
      'auth_send_reset':    'የዳግም ማስጀመሪያ አገናኝ ላክ',
      'auth_back_to_sign_in': 'ወደ መግቢያ ተመለስ',
      'auth_or_continue_with': 'ወይም ቀጥል በ',
      'auth_reset_email_sent': 'የይለፍ ቃል ዳግም ማስጀመሪያ ኢሜይል ተልኳል',
      'auth_check_inbox':   'ለዳግም ማስጀመሪያ መመሪያዎች የእርስዎን ኢንቦክስ ይመልከቱ',
      
      // Auth validation
      'auth_invalid_email': 'እባክዎ ትክክለኛ ኢሜይል ያስገቡ',
      'auth_weak_password': 'የይለፍ ቃል ቢያንስ 8 ፊደላት ከ 1 ትልቅ ፊደል እና 1 ቁጥር ጋር መሆን አለበት',
      'auth_password_mismatch': 'የይለፍ ቃሎች አይዛመዱም',
      'auth_email_required': 'ኢሜይል ያስፈልጋል',
      'auth_password_required': 'የይለፍ ቃል ያስፈልጋል',
      'auth_name_required': 'ስም ያስፈልጋል',
      
      // Auth errors
      'auth_error_generic': 'ስህተት ተከስቷል። እባክዎ እንደገና ይሞክሩ።',
      'auth_error_network': 'የኔትወርክ ስህተት። ግንኙነትዎን ይመልከቱ።',
      'auth_error_unauthenticated': 'ለመቀጠል እባክዎ ይግቡ',
      
      // Onboarding
      'onboarding_skip':    'ዝለል',
      'onboarding_next':    'ቀጥል',
      'onboarding_done':    'ጀምር',
      'onboarding_title_1': 'ማንኛውንም ባቄላ ይቃኙ',
      'onboarding_body_1':  'ካሜራዎን በቡና ባቄላ ላይ ያነጣጥሩ እና ፈጣን የጥራት ደረጃ ይቀበሉ',
      'onboarding_title_2': 'ታማኝ ደረጃ ይቀበሉ',
      'onboarding_body_2':  'በአይ የሚሰራ ትንተና ባቄላዎችን ወደ 4 የጥራት ምድቦች ይመድባል',
      'onboarding_title_3': 'ያለ ኢንተርኔት ይሰራል',
      'onboarding_body_3':  'ሁሉም ሂደት በመሳሪያዎ ላይ ይከናወናል። ኢንተርኔት አያስፈልግም።',
      
      // Dashboard/Home
      'dashboard_greeting': 'ሰላም',
      'dashboard_scan_card_title': 'የቡና ባቄላ ይቃኙ',
      'dashboard_scan_card_body': 'ፈጣን የጥራት ደረጃ ይቀበሉ',
      'dashboard_stats_total': 'አጠቃላይ ቅኝቶች',
      'dashboard_stats_week': 'በዚህ ሳምንት',
      'dashboard_stats_premium': 'ፕሪሚየም ባቄላዎች',
      'dashboard_recent':   'የቅርብ ጊዜ ቅኝቶች',
      'dashboard_see_all':  'ሁሉንም ይመልከቱ',
      
      // History filters
      'history_filter_all': 'ሁሉም',
      'history_filter_defect': 'ጉድለት',
      'history_filter_longberry': 'ሎንግቤሪ',
      'history_filter_peaberry': 'ፒበሪ',
      'history_filter_premium': 'ፕሪሚየም',
      'history_search_hint': 'ቅኝቶችን ፈልግ...',
      
      // Scan detail
      'scan_detail_title':  'የቅኝት ዝርዝሮች',
      'scan_detail_notes':  'ማስታወሻዎች',
      'scan_detail_add_notes': 'ማስታወሻዎች ያክሉ...',
      'scan_detail_edit':   'አርትዕ',
      'scan_detail_delete': 'ቅኝትን ሰርዝ',
      'scan_detail_confirm_delete': 'ይህን ቅኝት ይሰርዙ?',
      'scan_detail_share':  'አጋራ',
      'scan_detail_metadata': 'ሜታዳታ',
      'scan_detail_timestamp': 'ተቃኝቷል',
      'scan_detail_device': 'መሳሪያ',
      
      // Profile
      'profile_title':      'መገለጫ',
      'profile_display_name': 'ስም',
      'profile_email':      'ኢሜይል',
      'profile_language':   'ቋንቋ',
      'profile_theme':      'ገጽታ',
      'profile_cloud_sync': 'የደመና ማመሳሰል',
      'profile_last_sync':  'መጨረሻ ተመሳሰለ',
      'profile_never_synced': 'በጭራሽ አልተመሳሰለም',
      'profile_edit':       'መገለጫ አርትዕ',
      'profile_save':       'አስቀምጥ',
      
      // Settings (extended)
      'settings_data_sync': 'ውሂብ እና ማመሳሰል',
      'settings_clear_local': 'የአካባቢ ውሂብ አጥፋ',
      'settings_force_sync': 'አሁን ማመሳሰል',
      'settings_danger_zone': 'የአደጋ ዞን',
      'settings_delete_account': 'መለያ ሰርዝ',
      'settings_confirm_delete_account': 'መለያዎን እና ሁሉንም ውሂብ ይሰርዙ?',
      'settings_confirm_clear_data': 'ሁሉንም የአካባቢ ቅኝቶች ያጥፉ?',
      
      // Sync status
      'sync_synced':        'ተመሳስሏል',
      'sync_local_only':    'የአካባቢ ብቻ',
      'sync_syncing':       'በማመሳሰል ላይ...',
      'sync_failed':        'ማመሳሰል አልተሳካም',
      'sync_retry':         'እንደገና ሞክር',
      'sync_disabled':      'ማመሳሰል ተሰናክሏል',
      'sync_enabled':       'ማመሳሰል ነቅቷል',
      
      // Common actions
      'save':               'አስቀምጥ',
      'delete':             'ሰርዝ',
      'edit':               'አርትዕ',
      'share':              'አጋራ',
      'retry':              'እንደገና ሞክር',
      'ok':                 'እሺ',
      'yes':                'አዎ',
      'no':                 'አይ',
    },
  };
}