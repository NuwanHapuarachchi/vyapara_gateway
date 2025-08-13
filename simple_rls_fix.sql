-- =====================================================
-- SIMPLE RLS FIX FOR USER SIGNUP
-- This creates the most basic RLS policies to allow signup
-- =====================================================

-- Drop all existing policies on user_profiles
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can select own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON user_profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON user_profiles;
DROP POLICY IF EXISTS "Enable select for own profile" ON user_profiles;
DROP POLICY IF EXISTS "Enable update for own profile" ON user_profiles;
DROP POLICY IF EXISTS "Enable delete for own profile" ON user_profiles;

-- Create the simplest possible policies that allow signup
CREATE POLICY "Allow all operations for authenticated users" ON user_profiles
FOR ALL TO authenticated
USING (true)
WITH CHECK (true);

-- Or if you want more security, use these individual policies instead:
-- CREATE POLICY "Users can insert profiles" ON user_profiles
-- FOR INSERT TO authenticated
-- WITH CHECK (auth.uid() = id);

-- CREATE POLICY "Users can read profiles" ON user_profiles
-- FOR SELECT TO authenticated
-- USING (auth.uid() = id);

-- CREATE POLICY "Users can update profiles" ON user_profiles
-- FOR UPDATE TO authenticated
-- USING (auth.uid() = id)
-- WITH CHECK (auth.uid() = id);

-- Ensure RLS is enabled on user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Grant necessary permissions
GRANT ALL ON user_profiles TO authenticated;
GRANT USAGE ON SEQUENCE application_number_seq TO authenticated;

-- Make sure other essential tables are accessible
GRANT SELECT ON business_types TO authenticated;
GRANT SELECT ON nic_validation_data TO authenticated;
GRANT SELECT ON document_templates TO authenticated;
GRANT SELECT ON payment_methods TO authenticated;

-- =====================================================
-- END OF SIMPLE RLS FIX
-- =====================================================
