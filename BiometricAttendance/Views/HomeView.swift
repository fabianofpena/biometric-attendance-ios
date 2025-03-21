import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let user = authService.currentUser {
                    userInfo(user)
                }
                
                Spacer()
                
                attendanceButtons
                
                Spacer()
            }
            .padding()
            .navigationTitle("Attendance")
            .alert("Attendance", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private func userInfo(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome, \(user.name)")
                .font(.title2)
                .bold()
            
            if let lastCheckIn = user.lastCheckIn {
                Text("Last Check-in: \(timeFormatter.string(from: lastCheckIn))")
                    .foregroundColor(.secondary)
            }
            
            if let lastCheckOut = user.lastCheckOut {
                Text("Last Check-out: \(timeFormatter.string(from: lastCheckOut))")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var attendanceButtons: some View {
        HStack(spacing: 20) {
            Button(action: checkIn) {
                VStack {
                    Image(systemName: "arrow.forward.circle.fill")
                        .font(.system(size: 50))
                    Text("Check In")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.2))
                .cornerRadius(10)
            }
            
            Button(action: checkOut) {
                VStack {
                    Image(systemName: "arrow.backward.circle.fill")
                        .font(.system(size: 50))
                    Text("Check Out")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.2))
                .cornerRadius(10)
            }
        }
    }
    
    private func checkIn() {
        performAttendanceAction { try await authService.checkIn() }
    }
    
    private func checkOut() {
        performAttendanceAction { try await authService.checkOut() }
    }
    
    private func performAttendanceAction(_ action: @escaping () async throws -> Void) {
        isLoading = true
        
        Task {
            do {
                try await action()
                alertMessage = "Success!"
                showingAlert = true
            } catch AuthenticationError.biometricsNotAvailable {
                alertMessage = "Biometric authentication is not available on this device."
            } catch AuthenticationError.biometricsNotMatched {
                alertMessage = "Biometric authentication failed."
            } catch AuthenticationError.locationNotAuthorized {
                alertMessage = "Location access is required for attendance."
            } catch AuthenticationError.notInOfficeLocation {
                alertMessage = "You must be in the office to mark attendance."
            } catch AuthenticationError.alreadyCheckedIn {
                alertMessage = "You have already checked in today."
            } catch AuthenticationError.alreadyCheckedOut {
                alertMessage = "You have already checked out today."
            } catch {
                alertMessage = error.localizedDescription
            }
            
            showingAlert = true
            isLoading = false
        }
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    HomeView()
        .environmentObject(AuthenticationService())
} 