# Expense Tracker (Flutter + Firebase)

A simple, clean expense tracker app built with Flutter and Firebase, made as a
practical task submission.

## Features Implemented

**Core**
- Add, edit, and delete expenses (swipe-to-delete with confirmation)
- Category selection (Food, Transport, Shopping, Bills, Entertainment, Health, Education, Other)
- Data stored per-user in Cloud Firestore
- Current month's total spend shown on a summary card
- Full expense history list, newest first
- Filter by category and by date range
- Form validation (required title, positive numeric amount)
- Proper loading / empty / error states throughout

**Extras**
- Firebase Authentication (email/password sign up & sign in, plus a "Continue as guest" anonymous option)
- Search expenses by title/note
- Monthly category breakdown as a pie chart (Summary tab)
- Dark mode toggle (persisted locally with `shared_preferences`)

## Tech Stack

| Purpose            | Package |
|--------------------|---------|
| State management   | `provider` |
| Backend / database  | `firebase_core`, `cloud_firestore` |
| Auth                | `firebase_auth` |
| Charts              | `fl_chart` |
| Date/number format  | `intl` |
| Local prefs         | `shared_preferences` |

## Project Structure

```
lib/
  models/         # Expense data model
  services/       # AuthService, FirestoreService (talk to Firebase)
  providers/      # ChangeNotifier state: auth, expenses, theme
  screens/        # Login, Home (list + summary tabs), Add/Edit form
  widgets/        # Reusable UI: list item, filter bar, chart, states
  utils/          # Categories, theme, constants
```

The app follows a simple layered structure: **screens** consume **providers**,
providers call **services**, and services are the only layer that talks to
Firebase. This keeps UI code free of Firestore/Auth calls and makes it easy to
test or swap the backend later.

## Setup Instructions

The repository includes the Flutter platform folders, so no project generation
step is needed.

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase.** This checkout includes Android and web Firebase
   options in `lib/firebase_options.dart` and Android's
   `android/app/google-services.json`. To use your own Firebase project, create
   it at [console.firebase.google.com](https://console.firebase.google.com),
   enable the following providers, then run the FlutterFire CLI to generate
   project-specific options and replace the Android `google-services.json`:
   - **Authentication** → Email/Password provider, and Anonymous provider
   - **Firestore Database** (start in production mode)
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

3. **Deploy Firestore rules** (included as `firestore.rules`) so users can only
   read and write their own expenses:
   ```bash
   firebase deploy --only firestore:rules
   ```

4. **Run the app** or build a release APK:
   ```bash
   flutter run
   flutter build apk --release
   ```
   The APK is written to
   `build/app/outputs/flutter-apk/app-release.apk`.

## Data Model

Each expense document lives at `users/{uid}/expenses/{expenseId}`:

```json
{
  "title": "Groceries",
  "amount": 42.50,
  "category": "Food",
  "date": Timestamp,
  "note": "Weekly shop",
  "createdAt": Timestamp
}
```

## AI Tools Used

I used **Claude** (Anthropic) during development to:
- Scaffold the initial project architecture (models/services/providers/screens/widgets split)
- Generate boilerplate for Firebase Auth/Firestore service wrappers and the Provider-based state management
- Draft the UI widgets (filter bar, chart, list item, form validation logic)
- Write this README

I reviewed, tested, and adjusted the generated code myself, and can explain,
modify, or debug any part of it.

## Possible Future Improvements

- Pagination for very large expense histories
- Recurring expenses
- Export to CSV
- Budget limits with notifications
