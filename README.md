# Gravity Rewards App

A Flutter-based loyalty rewards app for Gravity Indoor Trampoline Park, allowing customers to earn and redeem points for various rewards.

## Features

- **User Authentication**: Email/password and Google Sign-In
- **Dashboard**: View points balance and available rewards
- **Points Accumulation**: Earn points for jumps, purchases, and visits
- **QR Code Integration**: Scan QR codes to earn points on return visits
- **Rewards Shop**: Browse and redeem rewards with earned points
- **Activity History**: Track points earned and rewards redeemed
- **Profile Management**: Update personal information and view account details
- **Notifications**: Receive alerts for new rewards and point thresholds

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Authentication, Firestore)
- **State Management**: Provider
- **Notifications**: flutter_local_notifications
- **QR Code Scanner**: qr_code_scanner

## Setup Instructions

1. **Clone the repository**:
   ```
   git clone <repository-url>
   cd gravity_rewards_app
   ```

2. **Install dependencies**:
   ```
   flutter pub get
   ```

3. **Firebase Setup**:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password and Google Sign-In)
   - Create a Firestore database
   - Download and add the Firebase configuration files:
     - For Android: `google-services.json` to `android/app/`
     - For iOS: `GoogleService-Info.plist` to `ios/Runner/`

4. **Run the app**:
   ```
   flutter run
   ```

## Project Structure

- **lib/constants**: App constants, theme, and styling
- **lib/models**: Data models for user, activities, and rewards
- **lib/providers**: State management with Provider
- **lib/screens**: UI screens for different app features
- **lib/services**: Firebase and business logic services
- **lib/widgets**: Reusable UI components
- **lib/utils**: Helper functions and utilities

## Demo Accounts

For testing, use these demo accounts:

- **Email**: demo@example.com
- **Password**: password123

## Contributing

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
