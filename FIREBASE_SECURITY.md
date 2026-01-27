# Firebase API Keys Security Guide

## Overview
Firebase API keys are now kept secure using environment variables instead of being hardcoded in the repository.

## Setup Instructions

### 1. Create Your Local Environment File
```bash
# Copy the template file
cp .env.example .env.local
```

### 2. Fill in Your API Keys
Edit `.env.local` and replace the placeholder values with your actual Firebase API keys:
```
FIREBASE_WEB_API_KEY=AIzaSyBAvwZpTAUe1mb6Kgn_TOovHEJ_QpGPtpc
FIREBASE_ANDROID_API_KEY=AIzaSyBBIdyzmPbuA-kO81nYGZCQ3BdJ0IPon2c
FIREBASE_IOS_API_KEY=AIzaSyDdJnEJuphJAdN7Jr82pX0gCssYUhXHzwo
# ... (fill in all values)
```

### 3. Running the App
When running locally, use the environment variables:

```bash
# For development
flutter run --dart-define-from-file=.env.local

# Or set individual variables
flutter run \
  --dart-define=FIREBASE_WEB_API_KEY="YOUR_KEY" \
  --dart-define=FIREBASE_ANDROID_API_KEY="YOUR_KEY" \
  # ... etc
```

## For CI/CD Pipelines

Store your API keys as **secrets** in your CI/CD provider:

### GitHub Actions
```yaml
- name: Run Flutter App
  run: |
    flutter run \
      --dart-define=FIREBASE_WEB_API_KEY=${{ secrets.FIREBASE_WEB_API_KEY }} \
      --dart-define=FIREBASE_ANDROID_API_KEY=${{ secrets.FIREBASE_ANDROID_API_KEY }} \
      # ... etc
```

### Other Platforms
- **GitLab CI**: Use `CI/CD Variables`
- **Firebase Hosting**: Use Firebase project settings
- **Vercel**: Use environment variables in project settings
- **Netlify**: Use build environment variables

## Security Best Practices

✅ **DO:**
- Keep `.env.local` in `.gitignore` (already configured)
- Use different API keys for different environments
- Rotate API keys regularly
- Use Firebase security rules to restrict data access
- Enable API key restrictions in Firebase Console

❌ **DON'T:**
- Commit `.env.local` to version control
- Share API keys in messages or emails
- Use the same key for development and production
- Hardcode keys in source code
- Grant unnecessary permissions to service accounts

## File Structure
```
.
├── .env.example          ← Template (commit this)
├── .env.local            ← Your secrets (DO NOT commit)
├── lib/
│   ├── firebase_options.dart    ← Loads from environment
│   └── config/
│       └── firebase_config.dart ← Environment variable definitions
```

## Troubleshooting

### Keys not loading?
1. Verify `.env.local` exists in project root
2. Check file has proper formatting (no extra spaces)
3. Restart IDE/terminal
4. Use `--verbose` flag: `flutter run --verbose`

### Keys still hardcoded somewhere?
```bash
# Search for hardcoded keys
grep -r "AIzaSy" lib/
grep -r "firebase" lib/ --include="*.dart"
```

## Reference
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Flutter Environment Variables](https://flutter.dev/docs/development/add-to-app/android/project-setup)
