-- =====================================================
-- FIX RLS POLICIES FOR USER SIGNUP
-- This fixes the signup error by allowing users to create their own profiles
-- =====================================================

-- Drop the existing restrictive policy
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;

-- Create separate policies for different operations
-- Allow users to insert their own profile (during signup)
CREATE POLICY "Users can insert own profile" ON user_profiles 
FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow users to select their own profile
CREATE POLICY "Users can select own profile" ON user_profiles 
FOR SELECT USING (auth.uid() = id OR auth.uid() IN (SELECT id FROM user_profiles WHERE role = 'admin'));

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON user_profiles 
FOR UPDATE USING (auth.uid() = id) 
WITH CHECK (auth.uid() = id);

-- Allow users to delete their own profile (if needed)
CREATE POLICY "Users can delete own profile" ON user_profiles 
FOR DELETE USING (auth.uid() = id);

-- Also fix the businesses table RLS policy to be more specific
DROP POLICY IF EXISTS "Users can manage own businesses" ON businesses;

-- Separate policies for businesses
CREATE POLICY "Users can insert own businesses" ON businesses 
FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can select own businesses" ON businesses 
FOR SELECT USING (
  auth.uid() = owner_id OR 
  auth.uid() IN (SELECT partner_id FROM business_partners WHERE business_id = id) OR
  auth.uid() IN (SELECT id FROM user_profiles WHERE role = 'admin')
);

CREATE POLICY "Users can update own businesses" ON businesses 
FOR UPDATE USING (
  auth.uid() = owner_id OR 
  auth.uid() IN (SELECT partner_id FROM business_partners WHERE business_id = id)
) WITH CHECK (
  auth.uid() = owner_id OR 
  auth.uid() IN (SELECT partner_id FROM business_partners WHERE business_id = id)
);

CREATE POLICY "Users can delete own businesses" ON businesses 
FOR DELETE USING (auth.uid() = owner_id);

-- Fix applications table RLS
DROP POLICY IF EXISTS "Users can view own applications" ON business_applications;

CREATE POLICY "Users can insert applications" ON business_applications
FOR INSERT WITH CHECK (
  auth.uid() = applicant_id OR
  auth.uid() IN (
    SELECT owner_id FROM businesses WHERE id = business_id
    UNION
    SELECT partner_id FROM business_partners WHERE business_id = business_applications.business_id
  )
);

CREATE POLICY "Users can select applications" ON business_applications
FOR SELECT USING (
  auth.uid() = applicant_id OR
  auth.uid() IN (
    SELECT owner_id FROM businesses WHERE id = business_id
    UNION
    SELECT partner_id FROM business_partners WHERE business_id = business_applications.business_id
  ) OR
  auth.uid() IN (SELECT id FROM user_profiles WHERE role = 'admin')
);

-- Fix documents table RLS
DROP POLICY IF EXISTS "Users can manage business documents" ON business_documents;

CREATE POLICY "Users can insert business documents" ON business_documents
FOR INSERT WITH CHECK (
  auth.uid() IN (
    SELECT owner_id FROM businesses WHERE id = business_id
    UNION
    SELECT partner_id FROM business_partners WHERE business_id = business_documents.business_id
  )
);

CREATE POLICY "Users can select business documents" ON business_documents
FOR SELECT USING (
  auth.uid() IN (
    SELECT owner_id FROM businesses WHERE id = business_id
    UNION  
    SELECT partner_id FROM business_partners WHERE business_id = business_documents.business_id
  ) OR
  auth.uid() IN (SELECT id FROM user_profiles WHERE role = 'admin')
);

-- Enable RLS on all tables (in case some were missed)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointment_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_processes ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- END OF RLS POLICY FIXES
-- =====================================================
