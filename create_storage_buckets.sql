-- =====================================================
-- SUPABASE STORAGE BUCKETS CREATION
-- Vyāpāra Gateway Platform
-- =====================================================

-- 1. Business Documents (Private) - 5MB limit
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'business-documents', 
  'business-documents', 
  false, 
  5242880, -- 5MB in bytes
  ARRAY['application/pdf', 'image/jpeg', 'image/png']
);

-- 2. Document Templates (Public) - 10MB limit
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'document-templates', 
  'document-templates', 
  true, 
  10485760, -- 10MB in bytes
  ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
);

-- 3. Profile Images (Private) - 2MB limit
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'profile-images', 
  'profile-images', 
  false, 
  2097152, -- 2MB in bytes
  ARRAY['image/jpeg', 'image/png', 'image/webp']
);

-- 4. Service Provider Documents (Private) - 5MB limit
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'service-provider-docs', 
  'service-provider-docs', 
  false, 
  5242880, -- 5MB in bytes
  ARRAY['application/pdf', 'image/jpeg', 'image/png']
);

-- 5. System Assets (Public) - 5MB limit
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'system-assets', 
  'system-assets', 
  true, 
  5242880, -- 5MB in bytes
  ARRAY['image/jpeg', 'image/png', 'image/svg+xml', 'image/webp']
);

-- =====================================================
-- STORAGE RLS POLICIES
-- =====================================================

-- Business Documents Policies
CREATE POLICY "Users can upload business documents" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'business-documents' AND 
  auth.uid() IN (
    SELECT owner_id FROM businesses WHERE id::text = (storage.foldername(name))[1]
    UNION
    SELECT partner_id FROM business_partners 
    WHERE business_id::text = (storage.foldername(name))[1]
  )
);

CREATE POLICY "Users can view business documents" ON storage.objects
FOR SELECT USING (
  bucket_id = 'business-documents' AND (
    auth.uid() IN (
      SELECT owner_id FROM businesses WHERE id::text = (storage.foldername(name))[1]
      UNION
      SELECT partner_id FROM business_partners 
      WHERE business_id::text = (storage.foldername(name))[1]
    ) OR
    auth.uid() IN (SELECT id FROM user_profiles WHERE role = 'admin')
  )
);

CREATE POLICY "Users can update business documents" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'business-documents' AND 
  auth.uid() IN (
    SELECT owner_id FROM businesses WHERE id::text = (storage.foldername(name))[1]
    UNION
    SELECT partner_id FROM business_partners 
    WHERE business_id::text = (storage.foldername(name))[1]
  )
);

CREATE POLICY "Users can delete business documents" ON storage.objects
FOR DELETE USING (
  bucket_id = 'business-documents' AND 
  auth.uid() IN (
    SELECT owner_id FROM businesses WHERE id::text = (storage.foldername(name))[1]
    UNION
    SELECT partner_id FROM business_partners 
    WHERE business_id::text = (storage.foldername(name))[1]
  )
);

-- Profile Images Policies
CREATE POLICY "Users can manage own profile images" ON storage.objects
FOR ALL USING (
  bucket_id = 'profile-images' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Service Provider Documents Policies
CREATE POLICY "Service providers can upload documents" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'service-provider-docs' AND 
  auth.uid()::text = (storage.foldername(name))[1] AND
  auth.uid() IN (SELECT user_id FROM service_providers)
);

CREATE POLICY "Admins and providers can view documents" ON storage.objects
FOR SELECT USING (
  bucket_id = 'service-provider-docs' AND (
    auth.uid()::text = (storage.foldername(name))[1] OR
    auth.uid() IN (SELECT id FROM user_profiles WHERE role = 'admin')
  )
);

CREATE POLICY "Service providers can update own documents" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'service-provider-docs' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Service providers can delete own documents" ON storage.objects
FOR DELETE USING (
  bucket_id = 'service-provider-docs' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Document Templates Policies (Public read, admin write)
CREATE POLICY "Anyone can view document templates" ON storage.objects
FOR SELECT USING (bucket_id = 'document-templates');

CREATE POLICY "Admins can manage document templates" ON storage.objects
FOR ALL USING (
  bucket_id = 'document-templates' AND
  auth.uid() IN (SELECT id FROM user_profiles WHERE role = 'admin')
);

-- System Assets Policies (Public read, admin write)
CREATE POLICY "Anyone can view system assets" ON storage.objects
FOR SELECT USING (bucket_id = 'system-assets');

CREATE POLICY "Admins can manage system assets" ON storage.objects
FOR ALL USING (
  bucket_id = 'system-assets' AND
  auth.uid() IN (SELECT id FROM user_profiles WHERE role = 'admin')
);

-- =====================================================
-- END OF STORAGE SETUP
-- =====================================================
