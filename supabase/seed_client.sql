-- ==============================================================================
-- Gaza Build / منصة عمار - Seeder for Client Dashboard (client@gaza.ps)
-- ==============================================================================

DO $$
DECLARE
  v_client_id uuid;
  v_engineer_id uuid;
  v_project_bidding_id uuid := 'b1111111-1111-1111-1111-111111111111';
  v_project_progress_id uuid := 'b2222222-2222-2222-2222-222222222222';
  v_project_completed_id uuid := 'b3333333-3333-3333-3333-333333333333';
  v_bid_1_id uuid := 'c1111111-1111-1111-1111-111111111111';
  v_bid_2_id uuid := 'c2222222-2222-2222-2222-222222222222';
BEGIN
  -- 1. Fetch user ID for client@gaza.ps
  SELECT id INTO v_client_id FROM auth.users WHERE email = 'client@gaza.ps' LIMIT 1;
  SELECT id INTO v_engineer_id FROM auth.users WHERE email = 'engineer@gaza.ps' LIMIT 1;

  IF v_client_id IS NULL THEN
    RAISE NOTICE ' الحساب client@gaza.ps غير مسجل بعد في auth.users. يرجى تسجيله أولاً من التطبيق أو من لوحة سوبابيز.';
    RETURN;
  END IF;

  -- 2. Upsert Client Profile in public.profiles
  INSERT INTO public.profiles (
    id,
    email,
    role,
    full_name,
    phone,
    city,
    bio,
    is_profile_complete,
    verification_status,
    created_at,
    updated_at
  ) VALUES (
    v_client_id,
    'client@gaza.ps',
    'client',
    'أبو أحمد النجار (مالك عقار)',
    '0599123456',
    'غزة',
    'مالك شقة سكنية متضررة جزئياً في تل الهوا، أبحث عن مهندسين معتمدين لإعادة التأهيل والتصميم الداخلي العصري.',
    true,
    'approved',
    now(),
    now()
  )
  ON CONFLICT (id) DO UPDATE SET
    role = 'client',
    full_name = EXCLUDED.full_name,
    phone = EXCLUDED.phone,
    city = EXCLUDED.city,
    bio = EXCLUDED.bio,
    is_profile_complete = true,
    verification_status = 'approved',
    updated_at = now();

  -- 3. Upsert Client Specific Details in public.client_profiles
  INSERT INTO public.client_profiles (
    user_id,
    address,
    preferred_project_types,
    property_condition_note,
    created_at,
    updated_at
  ) VALUES (
    v_client_id,
    'غزة - حي تل الهوا - مقابل حديقة برشلونة',
    ARRAY['إعادة تأهيل وترميم منزل متضرر', 'تشطيب وتصميم شقة سكنية جديدة', 'استشارة هندسية وفحص سلامة'],
    'العقار عبارة عن شقة سكنية 140م² تضررت القواطع والجدران الداخلية، ونحتاج تدعيم وإعادة توزيع الفراغات بديكور عصري ومواد بديلة.',
    now(),
    now()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    address = EXCLUDED.address,
    preferred_project_types = EXCLUDED.preferred_project_types,
    property_condition_note = EXCLUDED.property_condition_note,
    updated_at = now();

  -- 4. Ensure engineer profile exists if available
  IF v_engineer_id IS NOT NULL THEN
    INSERT INTO public.profiles (
      id, email, role, full_name, phone, city, is_profile_complete, verification_status
    ) VALUES (
      v_engineer_id, 'engineer@gaza.ps', 'engineer', 'م. يوسف أحمد الغول', '0599765432', 'غزة', true, 'approved'
    ) ON CONFLICT (id) DO NOTHING;
  END IF;

  -- 5. Delete old sample projects for this client to ensure clean state
  DELETE FROM public.projects WHERE client_id = v_client_id;

  -- 6. Insert Project 1: Bidding (مشروع يستقبل عروض الأسعار)
  INSERT INTO public.projects (
    id,
    client_id,
    client_name,
    title,
    description,
    project_type,
    area_m2,
    approximate_budget_usd,
    preferred_style,
    city,
    detailed_address,
    site_photos,
    status,
    is_escrow_secured,
    completion_percentage,
    created_at,
    updated_at
  ) VALUES (
    v_project_bidding_id,
    v_client_id,
    'أبو أحمد النجار',
    'إعادة تأهيل وتصميم ديكور داخلي لشقة سكنية متضررة',
    'مشروع يشمل إزالة القواطع المتصدعة، واستخدام قواطع جبسية عازلة خفيفة الوزن، وتصميم ديكور مودرن لصالة المعيشة وغرف النوم مع استغلال الإضاءة الطبيعية والركام المعالج.',
    'ترميم وإعادة تصميم داخلي',
    140.0,
    3800.0,
    'عصري بالمواد البديلة (Modern & Sustainable)',
    'غزة',
    'غزة - تل الهوا - مقابل حديقة برشلونة',
    ARRAY['https://images.unsplash.com/photo-1600585154340-be6161a56a0c'],
    'bidding',
    false,
    0,
    now() - interval '2 days',
    now()
  );

  -- 7. Insert Project 2: In Progress (مشروع قيد التنفيذ مع مهندس ودفعات)
  INSERT INTO public.projects (
    id,
    client_id,
    client_name,
    title,
    description,
    project_type,
    area_m2,
    approximate_budget_usd,
    preferred_style,
    city,
    detailed_address,
    site_photos,
    status,
    selected_engineer_id,
    selected_engineer_name,
    agreed_price_usd,
    is_escrow_secured,
    completion_percentage,
    created_at,
    updated_at
  ) VALUES (
    v_project_progress_id,
    v_client_id,
    'أبو أحمد النجار',
    'ترميم وتدعيم صالون استقبال وتصميم ديكور عصري',
    'أعمال التدعيم الإنشائي للعتبات الخرسانية، وتركيب أسقف جبسية معلقة مع إضاءة مخفية ودهانات صديقة للبيئة.',
    'ترميم وتدعيم إنشائي',
    95.0,
    2600.0,
    'نيوكلاسيك اقتصادي',
    'غزة',
    'غزة - حي الرمال الجنوبي',
    ARRAY['https://images.unsplash.com/photo-1618221195710-dd6b41faaea6'],
    'in_progress',
    COALESCE(v_engineer_id, v_client_id),
    'م. يوسف أحمد الغول',
    2400.0,
    true,
    60,
    now() - interval '15 days',
    now()
  );

  -- 8. Insert Project 3: Completed (مشروع مكتمل بنجاح وموثق)
  INSERT INTO public.projects (
    id,
    client_id,
    client_name,
    title,
    description,
    project_type,
    area_m2,
    approximate_budget_usd,
    preferred_style,
    city,
    detailed_address,
    site_photos,
    status,
    selected_engineer_id,
    selected_engineer_name,
    agreed_price_usd,
    is_escrow_secured,
    completion_percentage,
    created_at,
    updated_at
  ) VALUES (
    v_project_completed_id,
    v_client_id,
    'أبو أحمد النجار',
    'فحص سلامة إنشائية وتصميم واجهة متجر تجاري',
    'إجراء الفحص الإنشائي للاعتماد النقابي وتصميم واجهة زجاجية بديلة مع ديكور إضاءة موفر للطاقة.',
    'فحص واستشارة هندسية',
    60.0,
    1200.0,
    'تجاري حديث',
    'غزة',
    'غزة - شارع عمر المختار',
    ARRAY['https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b'],
    'completed',
    COALESCE(v_engineer_id, v_client_id),
    'م. يوسف أحمد الغول',
    1100.0,
    true,
    100,
    now() - interval '40 days',
    now()
  );

  -- 9. Insert Milestones for In Progress Project
  INSERT INTO public.project_milestones (
    project_id,
    title,
    description,
    percentage_weight,
    is_completed,
    payment_amount_usd,
    is_paid,
    proof_image_url,
    completed_at
  ) VALUES 
  (
    v_project_progress_id,
    'المخططات المعمارية والإنشائية 2D/3D',
    'تسليم المخططات التنفيذية وتوزيع الفراغات المعتمد',
    30,
    true,
    720.0,
    true,
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
    now() - interval '10 days'
  ),
  (
    v_project_progress_id,
    'أعمال التدعيم وصب الخرسانة بالركام المعالج',
    'تدعيم الجسور المتضررة وفحص مقاومة الكسر المخبري',
    30,
    true,
    720.0,
    true,
    'https://images.unsplash.com/photo-1541888946425-d0fbb186156a',
    now() - interval '3 days'
  ),
  (
    v_project_progress_id,
    'تركيب القواطع الجبسية وأعمال الكهرباء والدهانات',
    'عزل الجدران وتركيب الإضاءة المخفية والتشطيب النهائي',
    25,
    false,
    600.0,
    false,
    NULL,
    NULL
  ),
  (
    v_project_progress_id,
    'التسليم النهائي واعتماد الفحص من نقابة المهندسين',
    'الفحص الموقعي النهائي وتسليم شهادة السلامة الإنشائية',
    15,
    false,
    360.0,
    false,
    NULL,
    NULL
  );

  -- 10. Insert Bids on the Bidding Project if engineer exists
  IF v_engineer_id IS NOT NULL THEN
    INSERT INTO public.project_bids (
      id,
      project_id,
      engineer_id,
      engineer_name,
      engineer_specialty,
      engineer_rating,
      proposed_price_usd,
      estimated_duration_days,
      proposal_message,
      mood_board_description,
      mood_board_images,
      status,
      created_at
    ) VALUES (
      v_bid_1_id,
      v_project_bidding_id,
      v_engineer_id,
      'م. يوسف أحمد الغول',
      'تصميم داخلي وإعادة تأهيل',
      4.95,
      3400.0,
      18,
      'يسعدني تقديم عرض فني شامل يتضمن فحص السلامة الإنشائية المجاني، استخدام قواطع جبسية عازلة خفيفة الوزن لتخفيف الأحمال، وتصميم 3D كامل وتوزيع إضاءة طبيعية عصرية.',
      'لوحة ألوان مستوحاة من البيئة الطبيعية مع خشب البلوط والجبس الأبيض العازل',
      ARRAY['https://images.unsplash.com/photo-1600585154340-be6161a56a0c'],
      'pending',
      now() - interval '1 day'
    ) ON CONFLICT (id) DO NOTHING;
  END IF;

  RAISE NOTICE '✅ تم بنجاح تعبئة كامل بيانات لوحة تحكم العميل (client@gaza.ps) مع المشاريع والعروض والدفعات!';
END $$;
