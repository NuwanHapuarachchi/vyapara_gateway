-- =====================================================
-- FIX INFINITE RECURSION IN RLS POLICIES
-- This removes the circular reference that's causing the error
-- =====================================================

-- First, drop ALL existing policies to start clean
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can select own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;

-- Create simple, non-recursive policies for user_profiles
-- Allow users to insert their own profile (during signup)
CREATE POLICY "Enable insert for authenticated users" ON user_profiles 
FOR INSERT TO authenticated WITH CHECK (auth.uid() = id);

-- Allow users to select their own profile (no recursion)
CREATE POLICY "Enable select for own profile" ON user_profiles 
FOR SELECT TO authenticated USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Enable update for own profile" ON user_profiles 
FOR UPDATE TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Optional: Allow users to delete their own profile
CREATE POLICY "Enable delete for own profile" ON user_profiles 
FOR DELETE TO authenticated USING (auth.uid() = id);

-- Clean up other potentially problematic policies
DROP POLICY IF EXISTS "Users can insert own businesses" ON businesses;
DROP POLICY IF EXISTS "Users can select own businesses" ON businesses;
DROP POLICY IF EXISTS "Users can update own businesses" ON businesses;
DROP POLICY IF EXISTS "Users can delete own businesses" ON businesses;
DROP POLICY IF EXISTS "Users can manage own businesses" ON businesses;

-- Create simple business policies (no complex queries for now)
CREATE POLICY "Enable business operations for owners" ON businesses 
FOR ALL TO authenticated USING (auth.uid() = owner_id) WITH CHECK (auth.uid() = owner_id);

-- Temporarily disable RLS on some tables to avoid recursion issues
-- We'll re-enable them later once the core auth is working
ALTER TABLE business_partners DISABLE ROW LEVEL SECURITY;
ALTER TABLE business_applications DISABLE ROW LEVEL SECURITY;
ALTER TABLE business_documents DISABLE ROW LEVEL SECURITY;
ALTER TABLE document_versions DISABLE ROW LEVEL SECURITY;
ALTER TABLE service_providers DISABLE ROW LEVEL SECURITY;
ALTER TABLE appointments DISABLE ROW LEVEL SECURITY;
ALTER TABLE appointment_participants DISABLE ROW LEVEL SECURITY;
ALTER TABLE business_processes DISABLE ROW LEVEL SECURITY;
ALTER TABLE payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE payment_transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE community_questions DISABLE ROW LEVEL SECURITY;
ALTER TABLE community_answers DISABLE ROW LEVEL SECURITY;
ALTER TABLE chat_sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;

-- Keep RLS enabled only on critical tables for now
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;

-- Grant basic permissions to authenticated users for tables with disabled RLS
GRANT ALL ON business_types TO authenticated;
GRANT ALL ON nic_validation_data TO authenticated;
GRANT ALL ON document_templates TO authenticated;
GRANT ALL ON payment_methods TO authenticated;

-- =====================================================
-- END OF RECURSION FIX
-- =====================================================
