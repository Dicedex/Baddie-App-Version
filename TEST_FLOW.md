# Complete User Flow Test Guide

## Testing the Signup → Profile Creation → Home Flow

### Step 1: Launch the App
- Run: `flutter run`
- App should show **SplashScreen** briefly, then navigate to **AuthGuard**
- AuthGuard should check if user is logged in and route to LoginScreen or HomeScreen

### Step 2: Sign Up Flow
1. **On LoginScreen:**
   - Tap "Create Account" link or navigate to signup
   - Should see **SignUpScreen** with pink-to-red gradient background

2. **On SignUpScreen:**
   - Modern UI with gradient background (Colors.pink.shade500 → Colors.red.shade500)
   - Fade-in animation should play on page load (800ms)
   - Form inputs should have focus animations (scale 0.95x → 1.0x)
   
3. **Enter Account Details:**
   - Email: Enter valid email (e.g., test@example.com)
   - Password: Enter 8+ chars with letter + special char (e.g., test123!)
   - Confirm Password: Must match password
   
4. **Submit:**
   - Tap "Sign Up" button
   - Button should show loading spinner
   - Firebase Auth should create account
   - After success, should navigate to **ProfileSetupScreen** with email passed as argument

### Step 3: Profile Setup Flow
1. **ProfileSetupScreen Loaded:**
   - Should show **cyan-to-blue gradient** background (Colors.cyan.shade400 → Colors.blue.shade500)
   - Fade-in animation should play on load (800ms)
   - Header should display: "Create Your Profile"
   - Email should display below title (e.g., "for test@example.com")
   - Live profile preview card should update in real-time as user types

2. **Fill Profile Form:**
   - **Display Name:** Enter name (required)
   - **Age:** Enter age 18+ (required, validated)
   - **Short Bio:** Enter optional bio
   - **Upload Photos:** Tap placeholders to select images (max 3)
   - **Interests:** Select interests from chips (Music, Travel, Fitness, etc.)
   - **Personality:** Select one (Casual, Serious, Friendship, Networking)
   - **Preferences:**
     - Distance slider: Adjust max distance (5-200 km)
     - Age range slider: Select age range (18-100)
     - Verified only: Checkbox to show only verified profiles

3. **Form Validation:**
   - Name field: Shows error "Name required" if empty
   - Age field: Shows error "Enter a valid age (18+)" if invalid
   - All validators should trigger on focus loss or submit attempt

4. **Profile Preview:**
   - Live card in center should update as you type
   - Shows: Profile pic, name, age, bio, interests

5. **Submit Profile:**
   - Tap "Continue to Home" button
   - Button should show loading spinner
   - Profile data should save to `UserService.instance.setUser(profile)`
   - After success, should navigate to **HomeScreen** with `pushReplacementNamed`

### Step 4: Home Screen
1. **HomeScreen Loaded:**
   - Should see main app UI (SwipeScreen, MatchesScreen, MessagesScreen tabs)
   - Bottom navigation should work correctly
   - UserService.instance.currentUser should have profile data

### Step 5: Verify Complete Flow
✅ Check navigation flow: SignUp → ProfileSetup → Home  
✅ Email passed from SignUp to ProfileSetup  
✅ Profile data stored in UserService  
✅ All animations play smoothly  
✅ Form validation works on all fields  
✅ Error messages display correctly  
✅ Loading states show/hide properly  

### Expected Success Indicators
- No blank pages at any step
- No navigation stuck states
- All animations play smoothly (800ms fade-in, 200ms interactions)
- Form validation prevents invalid submissions
- Error messages display in toast notifications
- Loading spinners show during async operations
- Profile preview updates in real-time
- Navigation completes without errors

### Error Troubleshooting

**Issue: Profile Setup page appears blank**
- ✅ Fixed: Page now has cyan-blue gradient background
- ✅ Fixed: Email argument passed from signup
- ✅ Fixed: Form renders with proper styling
- ✅ Fixed: Animations initialized in initState

**Issue: Email not displaying on profile setup**
- ✅ Fixed: Email extracted from route arguments with `ModalRoute.of(context)?.settings.arguments`
- ✅ Fixed: Email passed from signup with `arguments: {'email': _emailController.text.trim()}`

**Issue: "Platform._operatingSystem" error**
- ✅ Fixed: BiometricService now wraps Platform checks in try-catch
- ✅ Fixed: Added kIsWeb check before platform-specific code

**Issue: Form validation not working**
- ✅ Fixed: Validators properly check for empty/invalid values
- ✅ Fixed: Error messages display when validation fails
- ✅ Fixed: Form prevents submission if invalid

**Issue: Navigation not completing**
- ✅ Fixed: Mounted checks before setState/navigation
- ✅ Fixed: PushReplacementNamed used to clear route stack
- ✅ Fixed: Error handling catches and displays exceptions

## Tech Stack Used
- **UI Framework:** Flutter with Material Design
- **Authentication:** Firebase Auth (email/password)
- **Data Storage:** UserService (ValueNotifier singleton)
- **Animations:** AnimationController with Tween
- **Local Storage:** SharedPreferences (for remember me)
- **State Management:** StatefulWidget with setState

## Key Files to Review
- [lib/screens/signup_screen.dart](lib/screens/signup_screen.dart) - Signup with email/password
- [lib/screens/profile_setup.dart](lib/screens/profile_setup.dart) - Profile creation form
- [lib/screens/home_screen.dart](lib/screens/home_screen.dart) - Main app after auth
- [lib/screens/login_screen.dart](lib/screens/login_screen.dart) - Login with remember me
- [lib/services/user_service.dart](lib/services/user_service.dart) - Profile data storage
- [lib/services/auth_service.dart](lib/services/auth_service.dart) - Firebase auth operations
