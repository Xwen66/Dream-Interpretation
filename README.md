# Dream Interpretation

Dream Interpretation is an iOS app that helps users record, analyze, and gain insights from their dreams using AI-powered interpretation and lucid dreaming guidance. The app provides a secure, private dream journal with actionable insights and positive psychology.

## Features
- **Secure Authentication:** Sign up and log in with email/password (Firebase Auth).
- **Dream Journal:** Record detailed dream entries with mood tagging and custom titles.
- **AI-Powered Interpretation:** Instantly receive dream analysis and symbol breakdowns using advanced AI (Novita AI API, Jungian psychology inspired).
- **Lucid Dreaming Guidance:** Get personalized tips and science-backed techniques for lucid dreaming based on your dream content.
- **Dream History:** Browse, search, and manage your dream entries and drafts.
- **Local Storage:** Dreams are stored securely on-device, per user.
- **Modern SwiftUI Interface:** Clean, intuitive, and responsive design.

## Screenshots
<!-- Add screenshots of the app here -->

## Getting Started
### Prerequisites
- Xcode 14 or later
- CocoaPods (if not using Swift Package Manager)
- A Firebase project (for Auth)
- Novita AI API key (for dream interpretation)

### Setup Instructions
1. **Clone the repository:**
   ```sh
   git clone <repo-url>
   cd Dream-Interpretation
   ```
2. **Open in Xcode:**
   Open `DreamInterpretation.xcodeproj` in Xcode.
3. **Firebase Setup:**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
   - Enable Email/Password authentication.
   - Download your `GoogleService-Info.plist` and place it in the `DreamInterpretation/` directory.
4. **API Key Configuration:**
   - Obtain a Novita AI API key from [Novita AI](https://novita.ai/).
   - Replace the placeholder API key in `Models.swift` with your own.
5. **Build and Run:**
   - Select a simulator or device and run the app from Xcode.

## Usage
1. **Sign Up / Log In:** Create an account or log in securely.
2. **Record a Dream:** Tap "Record New Dream" and describe your dream in detail. Tag your mood and save as draft or interpret instantly.
3. **Interpretation:** Receive a detailed, positive, and actionable dream analysis, including symbol meanings and lucid dreaming tips.
4. **Dream History:** Browse, search, and manage your past dreams and drafts.
5. **Profile & Logout:** View your profile and sign out securely.

## Technologies Used
- **SwiftUI** – Modern UI framework for iOS
- **Firebase Auth** – Secure authentication
- **Local JSON Storage** – On-device dream storage per user
- **Novita AI API** – AI-powered dream interpretation

## Credits
- Developed by [Your Name]
- Powered by [Novita AI](https://novita.ai/) and [Firebase](https://firebase.google.com/)

## License
This project is open source and available under the MIT License.