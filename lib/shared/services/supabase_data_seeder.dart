import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class SupabaseDataSeeder {
  static Future<void> seedAll() async {
    final client = SupabaseService.instance.client;
    if (client == null) {
      debugPrint('[SupabaseDataSeeder] Supabase client is not ready.');
      return;
    }

    try {
      debugPrint('[SupabaseDataSeeder] Starting Supabase Cloud Seeding...');

      // 1. Base Profiles
      await client.from('profiles').upsert([
        {
          'id': '11111111-1111-1111-1111-111111111111',
          'email': 'client@gaza.ps',
          'role': 'client',
          'full_name': 'أبو أحمد النجار',
          'phone': '0599123456',
          'city': 'مدينة غزة (الرمال، تل الهوا)',
          'bio': 'صاحب منزل متضرر في تل الهوا، أرغب في إعادة ترميم وتأهيل الصالون وغرف النوم وحل مشاكل التصدعات الداخلية.',
          'is_profile_complete': true,
          'verification_status': 'approved',
        },
        {
          'id': '22222222-2222-2222-2222-222222222222',
          'email': 'engineer@gaza.ps',
          'role': 'engineer',
          'full_name': 'م. يوسف الغول',
          'phone': '0599765432',
          'city': 'مدينة غزة (الرمال، النصر)',
          'bio': 'مهندس ديكور ومعماري معتمد بنقابة المهندسين، خبرة 7 سنوات في إعادة الترميم الإنشائي وتطوير التصاميم بالمواد البديلة الاقتصادية.',
          'is_profile_complete': true,
          'verification_status': 'approved',
        },
        {
          'id': '33333333-3333-3333-3333-333333333333',
          'email': 'student@gaza.ps',
          'role': 'student',
          'full_name': 'أحمد سالم النجار',
          'phone': '0599112233',
          'city': 'المنطقة الوسطى (دير البلح، النصيرات)',
          'bio': 'طالب هندسة معمارية سنة رابعة بالجامعة الإسلامية بغزة، متقن للأوتوكاد والمخططات التنفيذية والرفع ثلاثي الأبعاد واللقطات الواقعية.',
          'is_profile_complete': true,
          'verification_status': 'approved',
        },
        {
          'id': '44444444-4444-4444-4444-444444444444',
          'email': 'syndicate@gaza.ps',
          'role': 'syndicate',
          'full_name': 'م. خالد الرنتيسي',
          'phone': '0599887766',
          'city': 'مدينة غزة',
          'bio': 'مقرر لجنة التحكيم والاعتماد الهندسي بنقابة المهندسين - محافظات غزة، مشرف على أكواد البناء والتحكيم بين الملاك والمكاتب.',
          'is_profile_complete': true,
          'verification_status': 'approved',
        },
      ]);

      // 2. Role Extension Tables
      await client.from('client_profiles').upsert({
        'user_id': '11111111-1111-1111-1111-111111111111',
        'address': 'غزة - تل الهوا - بالقرب من مستشفى القدس',
        'preferred_project_types': ['ترميم أضرار جزئية', 'تصميم داخلي وديكور شقق', 'فحص إنشائي مسبق'],
        'property_condition_note': 'أضرار في الواجهة الجنوبية وقواطع الصالون متضررة، بحاجة لحلول ديكورية خفيفة وغير مكلفة.',
      });

      await client.from('engineer_profiles').upsert({
        'user_id': '22222222-2222-2222-2222-222222222222',
        'syndicate_membership_number': 'ENG-GZ-2018-4421',
        'university_degree_url': 'engineer_degree_verified.pdf',
        'years_of_experience': 7,
        'specialties': ['ترميم وتدعيم المباني المتضررة', 'تصميم داخلي وديكور اقتصادي', 'تخطيط الفراغات بالمخططات 2D/3D', 'إشراف على توريد المواد البديلة'],
        'portfolio_description': 'إنجاز أكثر من 30 مشروع سكني وتجاري في قطاع غزة، تخصص في استغلال الركام المعالج والمواد البديلة لتقليل التكلفة بنسبة 40%.',
        'rating': 4.95,
        'completed_projects_count': 18,
      });

      await client.from('student_profiles').upsert({
        'user_id': '33333333-3333-3333-3333-333333333333',
        'university': 'الجامعة الإسلامية بغزة (IUG)',
        'department': 'قسم الهندسة المعمارية',
        'year_of_study': 4,
        'enrollment_proof_url': 'student_card_iug.pdf',
        'available_for_internship': true,
        'skills': ['AutoCAD 2D', 'SketchUp', 'Revit', 'Lumion', 'Photoshop Architecture', '3Ds Max'],
        'mentorship_score': 4.90,
        'completed_micro_tasks': 8,
      });

      await client.from('syndicate_profiles').upsert({
        'user_id': '44444444-4444-4444-4444-444444444444',
        'official_title': 'مقرر لجنة التحكيم والاعتماد الهندسي',
        'department': 'دائرة المواصفات والأكواد الفنية ولجنة الطوارئ',
        'authorization_document_url': 'syndicate_board_resolution_2024.pdf',
      });

      // 3. Projects
      await client.from('projects').upsert([
        {
          'id': 'aaaaaaaa-1111-1111-1111-111111111111',
          'client_id': '11111111-1111-1111-1111-111111111111',
          'client_name': 'أبو أحمد النجار',
          'title': 'ترميم وتأهيل صالون وغرف نوم شقة متضررة جزئياً - تل الهوا',
          'description': 'شقة سكنية متضررة في الطابق الثالث، مساحة 140 م²، بحاجة لإعادة توزيع القواطع الداخلية وتدعيم الأبواب والشبابيك، وعمل تشطيب داخلي حديث وعازل باستخدام المواد البديلة المعتمدة من النقابة.',
          'project_type': 'ترميم أضرار جزئية وتأهيل سكني',
          'area_m2': 140.0,
          'approximate_budget_usd': 3500.0,
          'preferred_style': 'مودرن اقتصادي بالمواد البديلة',
          'city': 'مدينة غزة (تل الهوا)',
          'detailed_address': 'تل الهوا - مقابل مدرسة تل الإسلام',
          'status': 'in_progress',
          'selected_engineer_id': '22222222-2222-2222-2222-222222222222',
          'selected_engineer_name': 'م. يوسف الغول',
          'agreed_price_usd': 3400.0,
          'is_escrow_secured': true,
          'completion_percentage': 50,
        },
        {
          'id': 'bbbbbbbb-2222-2222-2222-222222222222',
          'client_id': '11111111-1111-1111-1111-111111111111',
          'client_name': 'أبو أحمد النجار',
          'title': 'إعادة تشطيب وتصميم صالة معيشة ومطبخ أمريكي - حي الرمال',
          'description': 'نرغب في مهندس معماري وديكور لتقديم مخططات تنفيذية ولقطات ثلاثية الأبعاد 3D لتجديد شقة عائلية، مع التركيز على استغلال الإضاءة الطبيعية واستخدام دهانات عازلة للرطوبة.',
          'project_type': 'تصميم داخلي وتشطيب شقة',
          'area_m2': 110.0,
          'approximate_budget_usd': 2800.0,
          'preferred_style': 'نيوكلاسيك دافئ',
          'city': 'مدينة غزة (الرمال الشمالي)',
          'detailed_address': 'الرمال - شارع خليل الوزير',
          'status': 'bidding',
          'is_escrow_secured': false,
          'completion_percentage': 0,
        },
        {
          'id': 'cccccccc-3333-3333-3333-333333333333',
          'client_id': '11111111-1111-1111-1111-111111111111',
          'client_name': 'أبو أحمد النجار',
          'title': 'تأهيل وتشطيب واجهة محل تجاري ومكتب خدمات - النصيرات',
          'description': 'تجهيز ديكور مكتب خدمات ومحل تجاري متضرر، يشمل تصميم القواطع الزجاجية وأعمال الجبس بورد والإضاءة الموفرة للطاقة.',
          'project_type': 'تصميم وتشطيب تجاري',
          'area_m2': 65.0,
          'approximate_budget_usd': 1600.0,
          'preferred_style': 'صناعي عملي (Industrial)',
          'city': 'المنطقة الوسطى (مخيم النصيرات)',
          'detailed_address': 'النصيرات - السوق العام',
          'status': 'bidding',
          'is_escrow_secured': false,
          'completion_percentage': 0,
        },
      ]);

      // 4. Project Bids
      await client.from('project_bids').upsert([
        {
          'id': 'dddddddd-1111-1111-1111-111111111111',
          'project_id': 'aaaaaaaa-1111-1111-1111-111111111111',
          'engineer_id': '22222222-2222-2222-2222-222222222222',
          'engineer_name': 'م. يوسف الغول',
          'engineer_specialty': 'ترميم معماري وديكور داخلي',
          'engineer_rating': 4.95,
          'proposed_price_usd': 3400.0,
          'estimated_duration_days': 20,
          'proposal_message': 'سأقوم بإعداد المخططات التنفيذية واللقطات 3D خلال أسبوع، والإشراف الكامل على استبدال القواطع بالجبس المصفح المعتمد من النقابة لتوفير 35% من التكلفة.',
          'mood_board_description': 'لوحة خامات ترابية دافئة، قواطع عازلة خفيفة الوزن، إضاءة ليد مخفية موفرة.',
          'status': 'accepted',
        },
        {
          'id': 'dddddddd-2222-2222-2222-222222222222',
          'project_id': 'bbbbbbbb-2222-2222-2222-222222222222',
          'engineer_id': '22222222-2222-2222-2222-222222222222',
          'engineer_name': 'م. يوسف الغول',
          'engineer_specialty': 'تصميم داخلي وديكور شقق',
          'engineer_rating': 4.95,
          'proposed_price_usd': 2600.0,
          'estimated_duration_days': 14,
          'proposal_message': 'عرض فني يشمل مخططات توزيع الفرش والإضاءة، ونماذج 3D واقعية، وجدول كميات مفصل لكافة البنود لتجنب الهدر في المواد.',
          'mood_board_description': 'مودبورد نيوكلاسيك: خشب سويدي معالج، دهانات مائية صديقة للبيئة، بدائل رخام مقاومة.',
          'status': 'pending',
        },
      ]);

      // 5. Project Milestones
      await client.from('project_milestones').upsert([
        {
          'id': 'eeeeeeee-1111-1111-1111-111111111111',
          'project_id': 'aaaaaaaa-1111-1111-1111-111111111111',
          'title': 'المرحلة 1: المخططات التنفيذية 2D وتوزيع المساحات',
          'description': 'رفع القياسات الدقيقة ورسم المخطط المعماري وتوزيع القواطع واعتمادها من المالك.',
          'percentage_weight': 25,
          'is_completed': true,
          'payment_amount_usd': 850.0,
          'is_paid': true,
          'proof_image_url': 'milestone_2d_plans_signed.pdf',
        },
        {
          'id': 'eeeeeeee-2222-2222-2222-222222222222',
          'project_id': 'aaaaaaaa-1111-1111-1111-111111111111',
          'title': 'المرحلة 2: اللقطات ثلاثية الأبعاد 3D ولوحات الخامات (Mood Boards)',
          'description': 'تجسيد التصميم بالكامل وإظهار توزيع الإضاءة والمواد البديلة المعتمدة.',
          'percentage_weight': 25,
          'is_completed': true,
          'payment_amount_usd': 850.0,
          'is_paid': true,
          'proof_image_url': 'render_3d_living_room.jpg',
        },
        {
          'id': 'eeeeeeee-3333-3333-3333-333333333333',
          'project_id': 'aaaaaaaa-1111-1111-1111-111111111111',
          'title': 'المرحلة 3: جدول الكميات والمواصفات (BOQ) وتوريد المواد',
          'description': 'إعداد جداول الحصر ومطابقة المواد البديلة مع مواصفات نقابة المهندسين.',
          'percentage_weight': 25,
          'is_completed': false,
          'payment_amount_usd': 850.0,
          'is_paid': false,
        },
        {
          'id': 'eeeeeeee-4444-4444-4444-444444444444',
          'project_id': 'aaaaaaaa-1111-1111-1111-111111111111',
          'title': 'المرحلة 4: الإشراف والتنفيذ والتسليم النهائي للموقع',
          'description': 'معاينة الموقع ومطابقة التنفيذ وتسليم الشقة للمالك خالية من أي ملاحظات.',
          'percentage_weight': 25,
          'is_completed': false,
          'payment_amount_usd': 850.0,
          'is_paid': false,
        },
      ]);

      // 6. Micro-Tasks for Students
      await client.from('micro_tasks').upsert([
        {
          'id': 'fa111111-1111-1111-1111-111111111111',
          'engineer_id': '22222222-2222-2222-2222-222222222222',
          'engineer_name': 'م. يوسف الغول',
          'assigned_student_id': '33333333-3333-3333-3333-333333333333',
          'assigned_student_name': 'أحمد سالم النجار',
          'title': 'رسم مخطط أوتوكاد 2D تفصيلي لصالون وممر شقة تل الهوا',
          'description': 'المطلوب تحويل الكروكي اليدوي المرفق إلى مخطط AutoCAD تنفيذي دقيق بمقياس رسم 1:50 مع توضيح فتحات الأبواب والشبابيك وسماكات الجدران.',
          'task_type': 'مخططات معمارية 2D',
          'software_needed': 'AutoCAD',
          'reward_usd': 50.0,
          'deadline_days': 3,
          'status': 'completed',
          'deliverable_note': 'تم إنجاز المخطط كاملاً وتسمية الطبقات (Layers) حسب الأصول الهندسية وإرفاق ملف DWG + PDF.',
          'deliverable_file_url': 'tel_hawa_living_2d_final.dwg',
          'mentor_feedback': 'عمل ممتاز ودقيق جداً ومطابق للمقاسات، أحسنت يا أحمد.',
          'rating': 5.0,
        },
        {
          'id': 'fa222222-2222-2222-2222-222222222222',
          'engineer_id': '22222222-2222-2222-2222-222222222222',
          'engineer_name': 'م. يوسف الغول',
          'assigned_student_id': '33333333-3333-3333-3333-333333333333',
          'assigned_student_name': 'أحمد سالم النجار',
          'title': 'رفع كتلة معمارية ثلاثية الأبعاد 3D SketchUp للمطبخ والصالة',
          'description': 'المطلوب بناء نموذج 3D SketchUp دقيق للمطبخ المفتوح وتوزيع الخزائن وطاولة الطعام بناء على المخطط 2D المعتمد.',
          'task_type': 'رفع ثلاثي الأبعاد 3D',
          'software_needed': 'SketchUp',
          'reward_usd': 75.0,
          'deadline_days': 3,
          'status': 'in_progress',
        },
        {
          'id': 'fa333333-3333-3333-3333-333333333333',
          'engineer_id': '22222222-2222-2222-2222-222222222222',
          'engineer_name': 'م. يوسف الغول',
          'title': 'تجهيز لوحة خامات ومودبورد (Moodboard) لتشطيب شقة حي الرمال',
          'description': 'مطلوب إعداد لوحة خامات بصرية أنيقة وعالية الدقة تجمع خيارات الألوان، بدائل الرخام، والأخشاب المعالجة المقترحة للشقة.',
          'task_type': 'لوحات خامات وتصميم داخلي',
          'software_needed': 'Photoshop / InDesign',
          'reward_usd': 40.0,
          'deadline_days': 2,
          'status': 'available',
        },
      ]);

      // 7. Reconstruction Guides
      await client.from('reconstruction_guides').upsert([
        {
          'id': 'fb111111-1111-1111-1111-111111111111',
          'title': 'كود استخدام خرسانة الركام المعاد تدويره (Recycled Aggregate) في المباني السكنية',
          'category': 'مواد بديلة وتدوير الركام',
          'summary': 'المعايير الفنية ونسب الاستبدال الآمنة لاستخدام مخلفات الهدم والركام المعاد تدويره في أعمال الصب والتشطيب لتقليل التكلفة وحماية البيئة.',
          'full_content': 'تعتمد نقابة المهندسين في محافظات غزة إمكانية استبدال الركام الطبيعي بركام خرساني معاد تدويره بنسبة تصل إلى 30% للعناصر غير الحاملة و 100% للخرسانة العادية (النظافة)، مع ضرورة الفحص المخبري لمقاومة الكسر وامتصاص الماء.',
          'approved_materials': ['خرسانة الركام المعاد', 'طوب الرماد المتطاير', 'مونة البوزولانا الطبيعية', 'ألياف البولي بروبيلين'],
          'author': 'اللجنة الفنية العليا - نقابة المهندسين غزة',
        },
        {
          'id': 'fb222222-2222-2222-2222-222222222222',
          'title': 'دليل المواصفات الفنية لترميم الجدران المتصدعة واستخدام القواطع الجبسية المقاومة',
          'category': 'ترميم وسلامة إنشائية',
          'summary': 'اشتراطات تركيب القواطع الجدارية خفيفة الوزن والعازلة للصوت والحرارة كبديل عن الطوب الإسمنتي الثقيل في المباني المتضررة.',
          'full_content': 'يوصى باستخدام ألواح الجبس المقاومة للرطوبة والمحشوة بالصوف الصخري العازل بسماكة لا تقل عن 10 سم لتخفيف الأحمال الميتة على البلاطات والجسور الخرسانية المتأثرة بالاهتزازات.',
          'approved_materials': ['ألواح جبس مصفحة', 'صوف صخري عازل', 'قطاعات صاج مجلفن خفيف', 'معجون فواصل فايبر جلاس'],
          'author': 'دائرة المواصفات والرقابة الهندسية',
        },
        {
          'id': 'fb333333-3333-3333-3333-333333333333',
          'title': 'دليل السلامة الإنشائية والفحص البصري للعناصر الحاملة قبل البدء بأعمال الديكور',
          'category': 'فحص وسلامة إنشائية',
          'summary': 'خطوات الفحص الهندسي الإلزامي للأعمدة والجسور للتأكد من خلوها من التشققات الإنشائية الخطرة قبل البدء بأعمال التشطيب الداخلي.',
          'full_content': 'يحظر إخفاء أي تشققات مائلة أو انتفاخات في الأعمدة والجسور الخرسانية بأعمال الديكور أو الجبس دون إجراء تقرير تدعيم فني معتمد ومختوم من مهندس نقابي معتمد.',
          'approved_materials': ['حقن الإيبوكسي الإنشائي', 'شرائح ألياف الكربون CFRP', 'مونة الإسمنت غير القابل للانكماش'],
          'author': 'لجنة تقييم السلامة الإنشائية بالنقابة',
        },
      ]);

      // 8. Arbitration Cases
      await client.from('arbitration_cases').upsert([
        {
          'id': 'fc111111-1111-1111-1111-111111111111',
          'project_id': 'aaaaaaaa-1111-1111-1111-111111111111',
          'project_title': 'ترميم وتأهيل صالون وغرف نوم - تل الهوا',
          'client_id': '11111111-1111-1111-1111-111111111111',
          'client_name': 'أبو أحمد النجار',
          'engineer_id': '22222222-2222-2222-2222-222222222222',
          'engineer_name': 'م. يوسف الغول',
          'dispute_reason': 'طلب المالك تعديل توزيع فتحات الإضاءة بعد اعتماد المخططات 3D دون إضافة تكلفة جديدة.',
          'requested_resolution': 'التحكيم حول ما إذا كانت التعديلات تتطلب ملحق عقد إضافي أم تدخل ضمن التعديلات المسموحة.',
          'syndicate_ruling': 'قررت لجنة التحكيم إلزام المهندس بإجراء تعديلين بسيطين على فتحات الإضاءة مجاناً، مع التزام المالك باعتماد المخطط النهائي دون تعديلات لاحقة.',
          'status': 'resolved',
        },
      ]);

      debugPrint('[SupabaseDataSeeder] Seeding completed successfully!');
    } catch (e) {
      debugPrint('[SupabaseDataSeeder] Seeding error: $e');
    }
  }
}
