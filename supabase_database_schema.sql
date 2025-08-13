-- =====================================================
-- VYĀPĀRA GATEWAY - COMPLETE DATABASE SCHEMA
-- Supabase PostgreSQL Database Design
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- ENUMS AND TYPES
-- =====================================================

-- User roles enum
CREATE TYPE user_role AS ENUM (
    'business_owner',
    'lawyer', 
    'mentor',
    'admin'
);

-- Business types enum
CREATE TYPE business_type AS ENUM (
    'sole_proprietorship',
    'partnership', 
    'private_limited_company',
    'public_limited_company',
    'ngo',
    'cooperative'
);

-- Application status enum
CREATE TYPE application_status AS ENUM (
    'draft',
    'submitted',
    'document_review',
    'additional_info_required',
    'approved',
    'rejected',
    'completed'
);

-- Document status enum
CREATE TYPE document_status AS ENUM (
    'pending',
    'uploaded',
    'under_review',
    'approved',
    'rejected',
    'resubmission_required'
);

-- Appointment status enum
CREATE TYPE appointment_status AS ENUM (
    'scheduled',
    'confirmed',
    'in_progress',
    'completed',
    'cancelled',
    'rescheduled'
);

-- Payment status enum
CREATE TYPE payment_status AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded'
);

-- Chat message type enum
CREATE TYPE message_type AS ENUM (
    'user',
    'ai',
    'system'
);

-- =====================================================
-- CORE USER TABLES
-- =====================================================

-- User profiles table (extends Supabase auth.users)
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    nic TEXT UNIQUE,
    role user_role NOT NULL DEFAULT 'business_owner',
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_nic_verified BOOLEAN DEFAULT FALSE,
    is_phone_verified BOOLEAN DEFAULT FALSE,
    profile_image_url TEXT,
    address JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- NIC validation data (sample showcase table)
CREATE TABLE nic_validation_data (
    nic TEXT PRIMARY KEY,
    full_name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    gender TEXT NOT NULL,
    district TEXT NOT NULL,
    is_valid BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- BUSINESS MANAGEMENT TABLES
-- =====================================================

-- Business types configuration
CREATE TABLE business_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type business_type UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    description TEXT,
    required_documents TEXT[] NOT NULL,
    estimated_processing_days INTEGER DEFAULT 1,
    base_fee DECIMAL(10,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Main businesses table
CREATE TABLE businesses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    business_name TEXT NOT NULL,
    business_type business_type NOT NULL,
    business_type_id UUID REFERENCES business_types(id),
    business_details JSONB NOT NULL, -- Store type-specific data
    business_address JSONB,
    proposed_trade_name TEXT,
    nature_of_business TEXT,
    status application_status DEFAULT 'draft',
    registration_number TEXT UNIQUE, -- Generated after approval
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Business partners table (for partnerships)
CREATE TABLE business_partners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    partner_id UUID NOT NULL REFERENCES user_profiles(id),
    partnership_percentage DECIMAL(5,2),
    is_primary_partner BOOLEAN DEFAULT FALSE,
    role TEXT, -- Managing Partner, Silent Partner, etc.
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(business_id, partner_id)
);

-- =====================================================
-- APPLICATION MANAGEMENT TABLES
-- =====================================================

-- Business applications table
CREATE TABLE business_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    applicant_id UUID NOT NULL REFERENCES user_profiles(id),
    application_number TEXT UNIQUE NOT NULL,
    status application_status DEFAULT 'draft',
    current_step TEXT,
    total_steps INTEGER,
    completed_steps INTEGER DEFAULT 0,
    submitted_at TIMESTAMP WITH TIME ZONE,
    approved_at TIMESTAMP WITH TIME ZONE,
    rejected_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    estimated_completion_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Application steps tracking
CREATE TABLE application_steps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID NOT NULL REFERENCES business_applications(id) ON DELETE CASCADE,
    step_name TEXT NOT NULL,
    step_order INTEGER NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    required_documents TEXT[],
    notes TEXT,
    assigned_to UUID REFERENCES user_profiles(id), -- Admin assigned
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- DOCUMENT MANAGEMENT TABLES
-- =====================================================

-- Document templates
CREATE TABLE document_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_type business_type NOT NULL,
    document_name TEXT NOT NULL,
    document_code TEXT NOT NULL, -- e.g., 'FORM_1', 'NIC_COPY'
    description TEXT,
    is_required BOOLEAN DEFAULT TRUE,
    file_format TEXT[], -- ['pdf', 'jpg', 'png']
    max_file_size_mb INTEGER DEFAULT 5,
    instructions TEXT,
    sample_document_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Business documents
CREATE TABLE business_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    application_id UUID REFERENCES business_applications(id),
    template_id UUID REFERENCES document_templates(id),
    document_name TEXT NOT NULL,
    document_type TEXT NOT NULL,
    status document_status DEFAULT 'pending',
    current_version INTEGER DEFAULT 1,
    uploaded_by UUID NOT NULL REFERENCES user_profiles(id),
    reviewed_by UUID REFERENCES user_profiles(id),
    review_notes TEXT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Document versions (for resubmissions)
CREATE TABLE document_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES business_documents(id) ON DELETE CASCADE,
    version_number INTEGER NOT NULL,
    file_path TEXT NOT NULL, -- Supabase storage path
    file_name TEXT NOT NULL,
    file_size INTEGER,
    mime_type TEXT,
    upload_notes TEXT,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(document_id, version_number)
);

-- =====================================================
-- SERVICE PROVIDER TABLES
-- =====================================================

-- Service providers (lawyers, mentors)
CREATE TABLE service_providers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    provider_type user_role NOT NULL CHECK (provider_type IN ('lawyer', 'mentor')),
    specialization TEXT[],
    experience_years INTEGER,
    qualification TEXT,
    license_number TEXT,
    hourly_rate DECIMAL(8,2),
    bio TEXT,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    verification_documents JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Service provider availability
CREATE TABLE availability_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID NOT NULL REFERENCES service_providers(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0 = Sunday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- APPOINTMENT MANAGEMENT TABLES
-- =====================================================

-- Appointments table
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID REFERENCES business_applications(id),
    requester_id UUID NOT NULL REFERENCES user_profiles(id),
    provider_id UUID REFERENCES service_providers(id),
    appointment_type TEXT NOT NULL, -- 'government_office', 'bank', 'legal_consultation'
    title TEXT NOT NULL,
    description TEXT,
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status appointment_status DEFAULT 'scheduled',
    location TEXT,
    meeting_link TEXT,
    notes TEXT,
    reminder_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Appointment participants (for multiple people)
CREATE TABLE appointment_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
    participant_id UUID NOT NULL REFERENCES user_profiles(id),
    nic TEXT, -- Can add non-registered participants by NIC
    role TEXT, -- 'primary', 'partner', 'representative'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(appointment_id, participant_id)
);

-- =====================================================
-- BUSINESS PROCESS TRACKING TABLES
-- =====================================================

-- Business processes (sub-processes after approval)
CREATE TABLE business_processes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    process_name TEXT NOT NULL,
    process_type TEXT NOT NULL, -- 'bank_account', 'tax_registration', 'trade_permit'
    status application_status DEFAULT 'draft',
    priority INTEGER DEFAULT 1,
    start_date DATE,
    target_completion_date DATE,
    completion_date DATE,
    assigned_to UUID REFERENCES user_profiles(id),
    process_data JSONB, -- Store process-specific information
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- PAYMENT MANAGEMENT TABLES
-- =====================================================

-- Payment methods
CREATE TABLE payment_methods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    method_name TEXT NOT NULL,
    method_code TEXT UNIQUE NOT NULL, -- 'card', 'bank_transfer', 'mobile'
    is_active BOOLEAN DEFAULT TRUE,
    processing_fee_percentage DECIMAL(5,4) DEFAULT 0,
    processing_fee_fixed DECIMAL(8,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payments table
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    application_id UUID NOT NULL REFERENCES business_applications(id),
    payer_id UUID NOT NULL REFERENCES user_profiles(id),
    payment_method_id UUID REFERENCES payment_methods(id),
    amount DECIMAL(10,2) NOT NULL,
    currency TEXT DEFAULT 'LKR',
    status payment_status DEFAULT 'pending',
    payment_reference TEXT,
    gateway_transaction_id TEXT,
    gateway_response JSONB,
    paid_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payment transactions (for tracking)
CREATE TABLE payment_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    transaction_type TEXT NOT NULL, -- 'charge', 'refund', 'adjustment'
    amount DECIMAL(10,2) NOT NULL,
    status payment_status NOT NULL,
    gateway_reference TEXT,
    notes TEXT,
    processed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- COMMUNITY & CHAT TABLES
-- =====================================================

-- Community questions
CREATE TABLE community_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES user_profiles(id),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    business_type_filter business_type[],
    tags TEXT[],
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0,
    answer_count INTEGER DEFAULT 0,
    is_answered BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Community answers
CREATE TABLE community_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID NOT NULL REFERENCES community_questions(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES user_profiles(id),
    content TEXT NOT NULL,
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0,
    is_accepted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI Chat sessions
CREATE TABLE chat_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES user_profiles(id),
    session_title TEXT,
    last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- AI Chat messages (2-week retention)
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
    message_type message_type NOT NULL,
    content TEXT NOT NULL,
    metadata JSONB, -- Store additional context
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- NOTIFICATION SYSTEM
-- =====================================================

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipient_id UUID NOT NULL REFERENCES user_profiles(id),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL, -- 'application_update', 'appointment_reminder', 'document_status'
    related_id UUID, -- Can reference any related entity
    is_read BOOLEAN DEFAULT FALSE,
    is_sent BOOLEAN DEFAULT FALSE,
    send_email BOOLEAN DEFAULT FALSE,
    send_sms BOOLEAN DEFAULT FALSE,
    scheduled_for TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- User profile indexes
CREATE INDEX idx_user_profiles_email ON user_profiles(email);
CREATE INDEX idx_user_profiles_nic ON user_profiles(nic);
CREATE INDEX idx_user_profiles_role ON user_profiles(role);

-- Business indexes
CREATE INDEX idx_businesses_owner_id ON businesses(owner_id);
CREATE INDEX idx_businesses_type ON businesses(business_type);
CREATE INDEX idx_businesses_status ON businesses(status);
CREATE INDEX idx_businesses_created_at ON businesses(created_at);

-- Application indexes
CREATE INDEX idx_applications_business_id ON business_applications(business_id);
CREATE INDEX idx_applications_status ON business_applications(status);
CREATE INDEX idx_applications_number ON business_applications(application_number);

-- Document indexes
CREATE INDEX idx_documents_business_id ON business_documents(business_id);
CREATE INDEX idx_documents_application_id ON business_documents(application_id);
CREATE INDEX idx_documents_status ON business_documents(status);

-- Appointment indexes
CREATE INDEX idx_appointments_requester_id ON appointments(requester_id);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_provider_id ON appointments(provider_id);

-- Chat message cleanup index
CREATE INDEX idx_chat_messages_created_at ON chat_messages(created_at);

-- =====================================================
-- ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- User profiles: Users can view/edit their own profile
CREATE POLICY "Users can view own profile" ON user_profiles 
    FOR ALL USING (auth.uid() = id);

-- Businesses: Users can view/edit their own businesses and businesses they're partners in
CREATE POLICY "Users can manage own businesses" ON businesses 
    FOR ALL USING (
        auth.uid() = owner_id OR 
        auth.uid() IN (SELECT partner_id FROM business_partners WHERE business_id = id)
    );

-- Applications: Users can view applications for their businesses
CREATE POLICY "Users can view own applications" ON business_applications 
    FOR ALL USING (
        auth.uid() IN (
            SELECT owner_id FROM businesses WHERE id = business_id
            UNION
            SELECT partner_id FROM business_partners WHERE business_id = business_applications.business_id
        )
    );

-- Documents: Users can manage documents for their businesses
CREATE POLICY "Users can manage business documents" ON business_documents 
    FOR ALL USING (
        auth.uid() IN (
            SELECT owner_id FROM businesses WHERE id = business_id
            UNION  
            SELECT partner_id FROM business_partners WHERE business_id = business_documents.business_id
        )
    );

-- Appointments: Users can view their own appointments
CREATE POLICY "Users can manage own appointments" ON appointments 
    FOR ALL USING (auth.uid() = requester_id);

-- Chat: Users can only access their own chat sessions
CREATE POLICY "Users can access own chats" ON chat_sessions 
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can access own chat messages" ON chat_messages 
    FOR ALL USING (
        auth.uid() IN (SELECT user_id FROM chat_sessions WHERE id = session_id)
    );

-- Notifications: Users can view their own notifications
CREATE POLICY "Users can view own notifications" ON notifications 
    FOR ALL USING (auth.uid() = recipient_id);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_businesses_updated_at BEFORE UPDATE ON businesses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_applications_updated_at BEFORE UPDATE ON business_applications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_documents_updated_at BEFORE UPDATE ON business_documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to generate application numbers
CREATE OR REPLACE FUNCTION generate_application_number()
RETURNS TRIGGER AS $$
BEGIN
    NEW.application_number = 'VG' || TO_CHAR(NOW(), 'YYYYMM') || LPAD(nextval('application_number_seq')::text, 6, '0');
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create sequence and trigger for application numbers
CREATE SEQUENCE application_number_seq START 1;
CREATE TRIGGER generate_app_number BEFORE INSERT ON business_applications FOR EACH ROW EXECUTE FUNCTION generate_application_number();

-- Function to clean up old chat messages (2-week retention)
CREATE OR REPLACE FUNCTION cleanup_old_chat_messages()
RETURNS void AS $$
BEGIN
    DELETE FROM chat_messages 
    WHERE created_at < NOW() - INTERVAL '14 days';
END;
$$ language 'plpgsql';

-- =====================================================
-- INITIAL DATA SETUP
-- =====================================================

-- Insert business types
INSERT INTO business_types (type, display_name, description, required_documents, estimated_processing_days, base_fee) VALUES
('sole_proprietorship', 'Sole Proprietorship', 'Individual business ownership', 
 ARRAY['application_form', 'grama_niladhari_report', 'nic_copy', 'business_premises_proof', 'trade_permit'], 
 1, 5000.00),
('partnership', 'Partnership', 'Business partnership between individuals', 
 ARRAY['application_form', 'grama_niladhari_report', 'partners_nic_copies', 'partnership_agreement', 'business_premises_proof', 'trade_permit'], 
 2, 7500.00),
('private_limited_company', 'Private Limited Company', 'Private limited liability company', 
 ARRAY['form_1', 'form_18', 'form_19', 'articles_of_association', 'directors_id_copies', 'company_name_reservation'], 
 2, 15000.00),
('public_limited_company', 'Public Limited Company', 'Public limited liability company', 
 ARRAY['form_1', 'form_18', 'form_19', 'articles_of_association', 'directors_id_copies', 'company_name_reservation', 'public_notice'], 
 3, 25000.00);

-- Insert payment methods
INSERT INTO payment_methods (method_name, method_code, processing_fee_percentage, processing_fee_fixed) VALUES
('Credit/Debit Card', 'card', 0.0350, 0),
('Bank Transfer', 'bank_transfer', 0, 25.00),
('Mobile Payment', 'mobile', 0.0250, 0);

-- Insert sample NIC data for showcase
INSERT INTO nic_validation_data (nic, full_name, date_of_birth, gender, district) VALUES
('200015501234', 'Kamal Perera', '2000-06-15', 'Male', 'Colombo'),
('199856789012', 'Nimal Fernando', '1998-02-28', 'Male', 'Kandy'),
('199923456789', 'Saman Silva', '1999-08-12', 'Male', 'Gampaha');

-- =====================================================
-- END OF SCHEMA
-- =====================================================
