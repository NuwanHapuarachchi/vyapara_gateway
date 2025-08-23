# Vyāpāra Gateway

A comprehensive Flutter application for government business registration and services platform in Sri Lanka.

## 🎯 Overview

Vyāpāra Gateway is a modern Flutter application that provides entrepreneurs and businesses with easy access to government services, business registration processes, community support, and AI-powered assistance. The app features a dark theme with a purple/pink color scheme and includes comprehensive features for business management.

## 🎨 Features

### ✅ Authentication & User Management
- **Login Screen**: Email/phone and password authentication with Sri Lanka LifeID integration placeholder
- **Sign Up Screen**: Complete user registration with password strength indicator and NIC validation
- **Settings Screen**: User profile management with email/NIC verification status

### ✅ Dashboard & Navigation  
- **Main Dashboard**: Quick actions grid for business services with application summary
- **Bottom Navigation**: Easy access to all major app sections
- **Quick Actions**: Business registration, document vault, community, mentorship access

### ✅ Applications Management
- **My Applications**: Timeline view of application progress with status tracking
- **Application Details**: Detailed view with progress indicators, document submission checklist
- **Status Tracking**: Real-time updates on application processing stages

### ✅ AI-Powered Help
- **AI Chat Assistant**: Contextual help for business registration and navigation
- **Smart Responses**: Tailored guidance based on user queries
- **Real-time Support**: Instant assistance for common questions

### ✅ Community Features
- **Community Feed**: Q&A platform for entrepreneurs to ask questions and share knowledge
- **Mentor System**: Reserve and chat with business mentors
- **Mentor Profiles**: Detailed mentor information with expertise areas and ratings

### ✅ State Management & Architecture
- **Riverpod**: Robust state management for authentication and app state
- **GoRouter**: Clean navigation with nested routes and deep linking support
- **Feature-based Architecture**: Organized codebase with features separation

## 🛠 Technical Stack

- **Framework**: Flutter 3.8+
- **State Management**: Riverpod 2.5+
- **Routing**: GoRouter 14.2+
- **UI/Fonts**: Google Fonts (Poppins, Inter)
- **Storage**: Flutter Secure Storage
- **Forms**: Flutter Form Builder with validation
- **HTTP**: Dio for API calls
- **Chat UI**: Flutter Chat Bubble
- **Timeline UI**: Timeline Tile
- **Progress**: Percent Indicator

## 🎨 Design System

### Color Palette
- **Primary**: Deep Purple/Indigo (#6366F1)
- **Secondary**: Pink accent (#EC4899) 
- **Accent**: Yellow (#FBBF24)
- **Success**: Green (#10B981)
- **Background**: Dark theme (#111827)

### Typography
- **Headings**: Poppins font family
- **Body Text**: Inter font family
- **Script Text**: Dancing Script for welcome text

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart          # Color definitions
│   ├── routing/
│   │   └── app_router.dart          # GoRouter configuration
│   └── theme/
│       └── theme.dart               # App theme setup
├── features/
│   ├── auth/
│   │   ├── providers/
│   │   │   └── auth_provider.dart   # Authentication state
│   │   └── screens/
│   │       ├── login_screen.dart    # Login interface
│   │       └── signup_screen.dart   # Registration interface
│   ├── dashboard/
│   │   └── screens/
│   │       └── dashboard_screen.dart # Main dashboard
│   ├── account/
│   │   └── screens/
│   │       └── settings_screen.dart  # User settings
│   ├── ai_help/
│   │   └── screens/
│   │       └── ai_chat_screen.dart   # AI assistant
│   ├── applications/
│   │   └── screens/
│   │       ├── my_applications_screen.dart
│   │       └── application_detail_screen.dart
│   └── community/
│       └── screens/
│           ├── community_feed_screen.dart
│           ├── mentor_chat_screen.dart
│           └── reserve_mentor_screen.dart
├── shared/
│   ├── widgets/                     # Reusable widgets
│   └── utils/                       # Utility functions
└── main.dart                        # App entry point
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8+
- Dart SDK 3.0+
- Android Studio / VS Code with Flutter extension

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd vyapara_gateway
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code (if needed)**
```bash
flutter packages pub run build_runner build
```

4. **Run the application**
```bash
flutter run
```

### Configuration

1. **Fonts**: Google Fonts automatically downloads required fonts
2. **Assets**: Place images in `assets/images/` and icons in `assets/icons/`
3. **API Integration**: Update API endpoints in provider files

## 📱 Screen Navigation

### Authentication Flow
- **Start**: `/login` - Welcome & Login Screen
- **Sign Up**: `/signup` - User Registration
- **Dashboard**: `/dashboard` - Main application (after login)

### Main Application
- **Dashboard**: `/dashboard` - Home with quick actions
- **Applications**: `/applications` - My Applications list
- **Application Detail**: `/applications/detail/:id` - Specific application
- **Settings**: `/settings` - User profile and settings
- **AI Help**: `/ai-help` - AI chat assistant
- **Community**: `/community` - Community feed
- **Mentors**: `/reserve-mentor` - Mentor selection
- **Mentor Chat**: `/mentor-chat/:mentorId` - Chat with mentor

