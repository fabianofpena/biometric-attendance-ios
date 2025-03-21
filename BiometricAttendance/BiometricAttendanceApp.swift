import SwiftUI

@main
struct BiometricAttendanceApp: App {
    @StateObject private var authService = AuthenticationService()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    HomeView()
                } else {
                    SignInView()
                }
            }
            .environmentObject(authService)
        }
    }
} 