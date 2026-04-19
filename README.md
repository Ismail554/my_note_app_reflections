# Reflections

A beautiful Note-taking Flutter application built with Clean Architecture.

## 🚀 Tech Stack

- **State Management:** [GetX](https://pub.dev/packages/get)
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router)
- **Architecture:** Clean Architecture & Clean Code principles
- **Backend / Database:** Firebase & Cloud Firestore

## 📂 Architecture Overview

This project heavily emphasizes **Clean Code** and adheres to **Clean Architecture** principles, ensuring separation of concerns, testability, and long-term maintainability. The codebase is organized into three main layers:

- **Presentation Layer:** Contains UI components (Widgets, Pages) and State Management (GetX controllers). It handles user interactions and updates the view.
- **Domain Layer:** The core of the application containing Enterprise Business Rules (Entities), Application Business Rules (Use Cases), and Repository Interfaces. This layer is completely independent of other layers.
- **Data Layer:** Implements the Domain repositories. Contains Data Sources (Firebase Firestore), Data Models (converting JSON to Entities), and handles all external data communications.

## 🛠️ Getting Started

### Prerequisites

- Flutter SDK (`^3.11.0` or higher)
- Firebase project configured for your application.

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd my_notes
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment:**
   Set up your Firebase configuration (`google-services.json` / `GoogleService-Info.plist`) and the `.env` file for your secure keys.

4. **Run the app:**
   ```bash
   flutter run
   ```

## 📝 License

This project is licensed under the MIT License.
