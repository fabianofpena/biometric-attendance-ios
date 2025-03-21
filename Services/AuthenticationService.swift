import Foundation
import LocalAuthentication
import CoreLocation

enum AuthenticationError: Error {
    case invalidCredentials
    case biometricsNotAvailable
    case biometricsNotRegistered
    case biometricsNotMatched
    case locationNotAuthorized
    case notInOfficeLocation
    case networkError
    case alreadyCheckedIn
    case alreadyCheckedOut
}

class AuthenticationService: ObservableObject {
    private let locationManager = CLLocationManager()
    private let context = LAContext()
    private let officeLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // Example coordinates
    private let maximumDistance: CLLocationDistance = 100 // 100 meters radius
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    func signUp(email: String, name: String, password: String) async throws -> User {
        guard User.isValidEmail(email) else {
            throw AuthenticationError.invalidCredentials
        }
        
        // In a real app, this would make an API call
        let user = User(email: email, name: name)
        self.currentUser = user
        return user
    }
    
    func signIn(email: String, password: String) async throws {
        // In a real app, this would validate against an API
        guard User.isValidEmail(email) else {
            throw AuthenticationError.invalidCredentials
        }
        
        isAuthenticated = true
    }
    
    func authenticateWithBiometrics() async throws {
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw AuthenticationError.biometricsNotAvailable
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Authenticate for attendance") { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: AuthenticationError.biometricsNotMatched)
                }
            }
        }
    }
    
    func verifyLocation() async throws {
        guard let location = locationManager.location else {
            throw AuthenticationError.locationNotAuthorized
        }
        
        let officeRegion = CLLocation(latitude: officeLocation.latitude,
                                    longitude: officeLocation.longitude)
        
        let distance = location.distance(from: officeRegion)
        
        guard distance <= maximumDistance else {
            throw AuthenticationError.notInOfficeLocation
        }
    }
    
    func checkIn() async throws {
        guard let user = currentUser else {
            throw AuthenticationError.invalidCredentials
        }
        
        if user.lastCheckIn?.isToday == true {
            throw AuthenticationError.alreadyCheckedIn
        }
        
        try await authenticateWithBiometrics()
        try await verifyLocation()
        
        // Update check-in time
        currentUser?.lastCheckIn = Date()
    }
    
    func checkOut() async throws {
        guard let user = currentUser else {
            throw AuthenticationError.invalidCredentials
        }
        
        if user.lastCheckOut?.isToday == true {
            throw AuthenticationError.alreadyCheckedOut
        }
        
        try await authenticateWithBiometrics()
        try await verifyLocation()
        
        // Update check-out time
        currentUser?.lastCheckOut = Date()
    }
}

private extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
} 