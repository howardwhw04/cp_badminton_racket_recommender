# RacketBase

**Explainable, safety-aware racquet recommender for badminton enthusiasts.**

---

## 🏸 Problem & Solution

**The Problem:** Consumers often struggle to choose badminton racquets due to technical jargon and opaque "black box" recommendation scores. Mismatched gear—such as using a stiff shaft when you are a beginner or lack arm strength—can cause physical injury and hinder skill progression.

**The Solution:** RacketBase is a hybrid two-stage recommendation engine built directly into a mobile app:
1. **Knowledge-Based System (KBS):** A deterministic engine that hard-prunes unsafe options (e.g., locking out stiff shafts for beginners/low-strength players).
2. **Weighted Additive Content-Based Filtering (CBF):** Scores remaining safe options against the user's playstyle, physical attributes, and budget.

**Explainability:** To demystify the recommendations, RacketBase uses simulated **SHAP (Shapley Additive exPlanations)** attributions computed per recommendation. These are parsed via NLG (Natural Language Generation) into transparent, user-facing bulleted justifications so users know *exactly* why a racquet was recommended.

## ✨ Key Features

- **Onboarding/Calibration Wizard:** An interactive quiz to capture player metrics, playstyle, and budget preferences.
- **Explainable Recommendation System (ERS):** Smart recommendation engine providing top picks across budget tiers with SHAP-based natural-language justifications.
- **Side-by-Side Equipment Comparison:** Matrix view to easily compare racquet specs.
- **Peer-to-Peer Pre-Owned Marketplace:** A community platform for buying and selling racquets with secure verification.
- **User Profile Dashboard:** Manage preferences, view saved recommendations, and track marketplace listings.
- **Offline Resilience:** Cloud catalogue with a robust local fallback mechanism ensures recommendations still work without an active connection.

## 🏗️ Architecture Overview

The system architecture is a streamlined split between the mobile client and the cloud backend, achieving end-to-end response latency under 3 seconds (often sub-300ms in testing).

```text
[ Mobile App (Flutter/Dart) ]
        |
        +-- UI/UX Layer (Screens & Widgets)
        |
        +-- Recommendation Engine (lib/services/recommendation_service.dart)
        |      1. KBS Hard-Pruning (Safety Filter)
        |      2. CBF Weighted Scoring (Match Rating)
        |      3. SHAP NLG Parser (Explainability)
        |
      (TLS Transport)
        |
[ Cloud Backend (Supabase) ]
        |
        +-- Authentication (Password Hashing)
        +-- PostgreSQL Database (Rackets, Listings, Profiles)
        +-- Row-Level Security (RLS)
```

*Note: The recommendation logic (KBS -> CBF -> SHAP) is implemented natively in Dart for maximum performance and offline resilience, interacting directly with Supabase for data persistence.*

## 🛠️ Tech Stack

| Component | Technology | Description |
|-----------|------------|-------------|
| **Frontend / Mobile** | Flutter (Dart) | Cross-platform mobile framework (SDK `^3.12.2`) |
| **Backend / DB** | Supabase | Managed PostgreSQL, Auth, and Storage |
| **Security** | Postgres RLS, TLS | Row-Level Security policies and secure data transport |
| **State Management**| Provider | App-wide state management for user sessions and UI |

## 📋 Prerequisites

- **Flutter SDK:** Version `3.12.2` or higher.
- **Dart SDK:** Compatible with the Flutter version.
- **Supabase Project:** A configured Supabase backend (with tables for `rackets`, profiles, marketplace, etc.).

## 🚀 Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd badmimton_racket_recommender
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Environment Configuration:**
   - Copy the configuration template:
     ```bash
     cp lib/config/supabase_config.dart.example lib/config/supabase_config.dart
     ```
   - Open `lib/config/supabase_config.dart` and insert your Supabase project URL and Anon Key.
   - *Never commit real secrets or production keys to version control.*

## 🏃 Running the App

To run the application in development mode on an attached device or emulator:
```bash
flutter run
```

## 🧪 Testing

The project includes an automated test suite verifying both UI widgets and the core recommendation logic (KBS filtering, CBF fallback, and SHAP outputs). 

Currently, all **7/7 tests are passing**. To run the tests:
```bash
flutter test
```

## 📁 Project Structure

```text
lib/
├── config/       # Environment and Supabase configurations
├── models/       # Data models (Racket, UserProfile, MarketListing)
├── providers/    # State management (AppState)
├── screens/      # UI Views (Quiz, Recommendation, Marketplace, etc.)
├── services/     # Core logic (RecommendationService)
├── widgets/      # Reusable UI components (CustomInput, CustomButton)
└── main.dart     # Application entry point
```

## ⚠️ Known Limitations

- **Catalog Scope:** Currently limited to racquets from Yonex, Li-Ning, and Victor.
- **Geographic Scope:** Pricing and marketplace scope are localized to Malaysia (MYR).
