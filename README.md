# 💰 Smart Expense & Budget Tracker App

A production-ready Flutter application for tracking daily expenses, managing budgets, and visualizing financial data with beautiful charts — built with **Firebase Auth**, **Cloud Firestore**, and **Hive** offline storage.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| **Expense Management** | Add, edit, delete expenses with category, date & notes |
| **Budget Tracking** | Set monthly budget, track remaining, get alerts at 90% |
| **Analytics Dashboard** | Pie chart (category-wise), bar chart (monthly trends), weekly breakdown |
| **Firebase Auth** | Email/password login & registration |
| **Cloud Sync** | Sync expenses & budgets to Firestore |
| **Offline Support** | Full offline functionality with Hive local storage |
| **Dark/Light Mode** | Toggle between themes, preference persisted |
| **Search & Filter** | Search expenses by note/category, filter by category |

---

## 📱 Screens

1. **Splash Screen** — Animated branding with gradient background
2. **Login/Register** — Email/password auth with validation
3. **Home Dashboard** — Summary cards, budget progress, recent expenses
4. **Add/Edit Expense** — Category selector, date picker, amount input
5. **Expense List** — Searchable, filterable, swipe-to-delete
6. **Budget Settings** — Circular progress, currency selector, category breakdown
7. **Analytics** — Pie chart, bar chart, weekly spending bars

---

## 🏗️ Architecture

```
lib/
├── models/          # Expense, Budget, UserModel + Hive adapters
├── services/        # HiveService (local), FirebaseService (cloud)
├── providers/       # ExpenseProvider, BudgetProvider, AuthProvider, ThemeProvider
├── screens/         # 7 app screens
├── widgets/         # ExpenseCard, SummaryCard, CategoryIcon
├── utils/           # Constants (categories/colors), Theme (light/dark)
└── main.dart        # Entry point with Firebase + Hive init, MultiProvider
```

- **State Management**: Provider
- **Pattern**: Clean Architecture (UI → Provider → Service → Data)
- **Local Storage**: Hive
- **Cloud**: Firebase Auth + Cloud Firestore

---

## 🛠️ Tech Stack

| Dependency | Purpose |
|-----------|---------|
| `provider` | State management |
| `hive` / `hive_flutter` | Offline local storage |
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Email/password authentication |
| `cloud_firestore` | Cloud database sync |
| `fl_chart` | Pie charts & bar charts |
| `intl` | Date formatting |
| `google_fonts` | Poppins typography |
| `uuid` | Unique expense IDs |
| `path_provider` | File system paths |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

### Setup

```bash
# 1. Clone the repo
git clone <repo-url>
cd expense-tracker-app

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase (see FIREBASE_SETUP.md for detailed steps)
firebase login
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID

# 4. Run the app
flutter run
```

> See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for the complete 9-step Firebase configuration guide.

---

## ☁️ Firebase Setup (Quick)

1. Create project at [Firebase Console](https://console.firebase.google.com)
2. Enable **Email/Password** auth
3. Create **Firestore Database** (test mode)
4. Run `flutterfire configure --project=YOUR_PROJECT_ID`
5. App auto-generates `lib/firebase_options.dart`

### Firestore Structure

```
users/{userId}/
├── expenses/{expenseId}
│   ├── amount, category, date, note, isSynced
└── budgets/{month}
    ├── monthlyLimit, spentAmount, month
```

---

## 📊 Data Models

### Expense
| Field | Type | Description |
|-------|------|-------------|
| `id` | String | UUID |
| `amount` | double | Expense amount |
| `category` | String | Food, Travel, Bills, Shopping, etc. |
| `date` | DateTime | When the expense occurred |
| `note` | String | Optional description |
| `isSynced` | bool | Cloud sync status |

### Budget
| Field | Type | Description |
|-------|------|-------------|
| `monthlyLimit` | double | Budget cap for the month |
| `spentAmount` | double | Total spent so far |
| `month` | String | Format: `yyyy-MM` |

---

## 🎨 Design

- **Material 3** with custom color scheme
- **Google Fonts** (Poppins)
- **Gradient summary cards** with shadow effects
- **Animated splash screen** with scale + fade transitions
- **Responsive** mobile-first layout
- **Dark/Light mode** with persistent preference

---

## 📝 Git Commit History

1. `Initial project setup` — Flutter scaffold, dependencies, folder structure
2. `Expense module implemented` — Models, CRUD, list with search/filter
3. `Analytics dashboard added` — Pie chart, bar chart, weekly breakdown
4. `Cloud sync and Firebase integration` — Auth, Firestore sync, firebase_options

---

## 👤 Author

**23IT061** — Charusat University

---

## 📄 License

This project is for educational purposes.
