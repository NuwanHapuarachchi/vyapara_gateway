# Supabase Integration Setup Guide

## 🎉 Supabase Successfully Integrated!

Your Vyāpāra Gateway Flutter app is now connected to Supabase with real authentication and database functionality.

## 🔧 What's Been Set Up

### 1. Database Schema ✅
- Complete database schema with all tables created
- Row Level Security (RLS) policies configured
- Storage buckets for document management
- Sample data for testing

### 2. Flutter Integration ✅
- **Supabase Flutter SDK** added to dependencies
- **Authentication system** using real Supabase Auth
- **User profile management** with database sync
- **Storage service** for file uploads
- **Real-time connection** monitoring

### 3. Updated Components ✅
- **Auth Provider**: Now uses Supabase instead of mock data
- **User Model**: Matches database schema exactly
- **Login/Signup**: Real authentication with error handling
- **Connection Test Screen**: Verify database connectivity

## 🚀 How to Test the Integration

### Method 1: Use Test Screen
1. Run your app: `flutter run`
2. Navigate to: `/test-supabase` or modify splash screen to go there temporarily
3. Test all database connections and functionality

### Method 2: Test Authentication Flow
1. Go to signup screen
2. Create a new account with:
   - Valid email address
   - Strong password (6+ characters)
   - Phone number (Sri Lankan format: +94xxxxxxxxx)
   - NIC (use sample: `200015501234` for testing)

### Method 3: Verify in Supabase Dashboard
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: `iqihgblzxtwjguyvohny`
3. Check **Authentication** → **Users** for new signups
4. Check **Table Editor** → **user_profiles** for profile data

## 📱 New Features Available

### Real Authentication
```dart
// Login
await ref.read(authProvider.notifier).login(email, password);

// Signup with profile creation
await ref.read(authProvider.notifier).signup(
  fullName: name,
  email: email,
  phone: phone,
  nic: nic,
  password: password,
);

// Logout
await ref.read(authProvider.notifier).logout();
```

### User Profile Management
```dart
// Get current user
final user = ref.watch(currentUserProvider);

// Check authentication
final isAuth = ref.watch(isAuthenticatedProvider);

// Update profile
await ref.read(authProvider.notifier).updateProfile(updatedUser);
```

### Database Operations
```dart
// Test connection
final isConnected = await SupabaseService.testConnection();

// Validate NIC
final nicData = await SupabaseService.validateNic(nic);

// Get business types
final types = await SupabaseService.getBusinessTypes();
```

## 🔐 Security Features

- **Row Level Security (RLS)**: Users can only access their own data
- **Email verification**: Built-in with Supabase Auth
- **Password validation**: Minimum 6 characters required
- **NIC validation**: Against sample database
- **Secure storage**: JWT tokens handled automatically

## 🗄️ Database Structure

Your database includes:
- **user_profiles**: User information and verification status
- **businesses**: Business registration data
- **business_applications**: Application workflow tracking
- **business_documents**: Document management with versions
- **appointments**: Booking system for services
- **service_providers**: Lawyer and mentor profiles
- **community_questions**: Q&A system
- **chat_sessions**: AI chat with history
- **payments**: Payment tracking and history

## 📁 Storage Buckets

5 storage buckets configured:
1. **business-documents** (Private): User uploaded documents
2. **document-templates** (Public): Sample forms and templates
3. **profile-images** (Private): User profile pictures
4. **service-provider-docs** (Private): Lawyer/mentor credentials
5. **system-assets** (Public): App logos and icons

## 🔄 Next Development Steps

### Phase 1: Business Registration Forms
1. Create step-by-step business registration wizard
2. Implement document upload functionality
3. Build application tracking system

### Phase 2: Document Management
1. File upload with validation
2. Document versioning system
3. Admin verification interface

### Phase 3: Service Integration
1. Appointment booking system
2. Payment gateway integration
3. Notification system

## 🛠️ Development Commands

```bash
# Install dependencies
flutter pub get

# Run with hot reload
flutter run

# Build for Android
flutter build apk --release

# Run tests
flutter test

# Check for issues
flutter doctor
```

## 🔧 Environment Variables

Your Supabase credentials are in `lib/core/config/supabase_config.dart`:
- **URL**: `https://iqihgblzxtwjguyvohny.supabase.co`
- **Anon Key**: Your anon key (safely stored in code)

## 📊 Sample Test Data

Use these for testing:
- **Valid NIC**: `200015501234` (Kamal Perera)
- **Valid NIC**: `199856789012` (Nimal Fernando)
- **Test Email**: Any valid email address
- **Test Phone**: +94712345678

## 🚨 Important Notes

1. **Email Verification**: New users must verify email before full access
2. **RLS Policies**: Ensure users can only access their own data
3. **File Limits**: Documents limited to 5MB, images to 2MB
4. **Development Mode**: Debug logging enabled for Supabase client

## 🔗 Helpful Resources

- [Supabase Flutter Docs](https://supabase.com/docs/reference/dart)
- [Flutter Riverpod Guide](https://riverpod.dev/docs/introduction/getting_started)
- [Your Supabase Dashboard](https://supabase.com/dashboard/project/iqihgblzxtwjguyvohny)

---

**Status**: ✅ **Supabase Integration Complete**  
**Next**: Start building business registration forms!
