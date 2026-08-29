abstract final class AppConstants {
  static const appName = 'عمار - Gaza Build';
  static const appTagline = 'المنصة الهندسية لإعادة الإعمار والتصميم الداخلي في غزة';
  static const defaultCity = 'غزة';

  static const minPasswordLength = 6;

  // Gaza Municipalities & Regions
  static const gazaCities = [
    'غزة',
    'مدينة غزة (الرمال، النصر، الدرج، التفاح)',
    'شمال غزة (جباليا، بيت لاهيا، بيت حانون)',
    'المنطقة الوسطى (دير البلح، النصيرات، البريج، المغازي)',
    'خان يونس (البلد، معن، القرارة، السطر)',
    'رفح (البلد، تل السلطان، الشابورة، الجنينة)',
  ];

  // Project Types for Clients
  static const clientProjectTypes = [
    'إعادة تأهيل وترميم منزل متضرر',
    'تشطيب وتصميم شقة سكنية جديدة',
    'تصميم وتنفيذ محل أو معرض تجاري',
    'تصميم مكتب ومساحة عمل هندسية',
    'استشارة هندسية سريعة (ديكور وألوان)',
    'تقييم سلامة إنشائية وحلول تدعيم',
    'تنسيق حدائق وفناء خارجي (Landscape)',
  ];

  // Architectural Styles
  static const architecturalStyles = [
    'مودرن حديث (Modern Minimalist)',
    'تراثي فلسطيني معاصر (Palestinian Heritage)',
    'صناعي حضري (Industrial)',
    'اقتصادي مستدام بمواد بديلة (Sustainable)',
    'كلاسيكي نيوكلاسيك (Neoclassical)',
  ];

  // Engineering Specialties
  static const engineerSpecialties = [
    'التصميم الداخلي والديكور (Interior Design)',
    'الهندسة المعمارية (Architecture)',
    'إعادة تأهيل المباني المتضررة (Rehabilitation & Retrofitting)',
    'الإشراف الهندسي وإدارة المشاريع (Site Supervision)',
    'التصميم المستدام وحلول الطاقة (Sustainable Design)',
    'حساب الكميات وجداول المواصفات (BOQ & Estimation)',
  ];

  // Universities in Gaza
  static const gazaUniversities = [
    'الجامعة الإسلامية بغزة (IUG)',
    'جامعة الأزهر - غزة (AUG)',
    'جامعة فلسطين (UP)',
    'الكلية الجامعية للعلوم التطبيقية (UCAS)',
    'جامعة الإسراء',
    'بوليتكنك فلسطين',
  ];

  // Student Departments
  static const studentDepartments = [
    'الهندسة المعمارية (Architecture)',
    'التصميم الداخلي والديكور (Interior Architecture)',
    'الهندسة المدنية والإنشائية (Civil & Structural)',
    'التخطيط الحضري وتطوير المدن (Urban Planning)',
  ];

  // Student Technical Skills & Software
  static const studentSkills = [
    'AutoCAD 2D (مخططات تنفيذية ورسم معماري)',
    'SketchUp & V-Ray (نمذجة ثلاثية الأبعاد وإظهار)',
    '3ds Max & Corona Render (رندرات واقعية 3D)',
    'Revit BIM (نمذجة معلومات البناء)',
    'Adobe Photoshop (معالجة اللوحات والبوست برودكشن)',
    'Mood Boards & Material Selection (لوحات المزاج والأثاث)',
    'BOQ Excel (حساب كميات أولي)',
  ];

  // Micro Task Categories (Delegated from Engineers to Students)
  static const microTaskTypes = [
    'رسم وتعديل مخططات 2D على AutoCAD',
    'بناء كتلة ثلاثية الأبعاد 3D على SketchUp',
    'إعداد لوحة مزاج وتناسق ألوان (Mood Board)',
    'إخراج لقطة واقعية 3D Render',
    'تفريغ وتنسيق جدول مواصفات وكميات أولي',
  ];

  // Reconstruction Technical Manual Topics
  static const reconstructionTopics = [
    'استخدام الركام المعاد تدويره في البناء المؤقت والمستدام',
    'حلول بديلة وسريعة لمعالجة التصدعات والترميم الإنشائي',
    'عزل الأسقف الخفيفة والبديلة ضد الحرارة والأمطار',
    'تشطيبات ديكور اقتصادية بالمواد المحلية المتاحة في غزة',
    'معايير السلامة الإنشائية للمباني الآيلة للسقوط',
  ];
}
