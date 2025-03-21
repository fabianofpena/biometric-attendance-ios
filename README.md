# BiometricAttendance

A modern iOS application for managing employee attendance using biometric authentication and location services.

## Features

- User authentication (Sign up/Sign in)
- Email validation
- Biometric authentication (Face ID/Touch ID)
- Location-based attendance
- Check-in/Check-out functionality
- Offline support
- Secure data storage

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- iPhone with Face ID or Touch ID capability
- Location Services enabled

## Installation

1. Clone this repository
2. Open `BiometricAttendance.xcodeproj` in Xcode
3. Build and run the project

## Architecture

The app follows MVVM (Model-View-ViewModel) architecture pattern and uses:
- SwiftUI for UI
- Combine for reactive programming
- CoreData for local storage
- LocalAuthentication framework for biometric authentication
- CoreLocation for location services

## Security

- All sensitive data is stored securely using Keychain
- Biometric data never leaves the device
- Network communications are encrypted using TLS
- Location data is only accessed when needed with user permission

## Testing

The app includes:
- Unit tests for business logic
- UI tests for critical user flows
- Network mocking for offline testing 