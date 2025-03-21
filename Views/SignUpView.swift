import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $viewModel.name)
                        .textContentType(.name)
                        .autocapitalization(.words)
                    
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textContentType(.newPassword)
                }
                
                Section {
                    Button(action: signUp) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .navigationTitle("Sign Up")
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func signUp() {
        Task {
            do {
                _ = try await authService.signUp(
                    email: viewModel.email,
                    name: viewModel.name,
                    password: viewModel.password
                )
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
}

class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var name = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    var isValid: Bool {
        !email.isEmpty &&
        !name.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        User.isValidEmail(email) &&
        password.count >= 8
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthenticationService())
} 