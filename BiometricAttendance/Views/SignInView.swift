import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)
                }
                
                Section {
                    Button(action: signIn) {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!viewModel.isValid)
                }
                
                Section {
                    NavigationLink("Create Account", destination: SignUpView())
                }
            }
            .navigationTitle("Sign In")
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func signIn() {
        Task {
            do {
                try await authService.signIn(
                    email: viewModel.email,
                    password: viewModel.password
                )
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
}

class SignInViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    var isValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        User.isValidEmail(email)
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthenticationService())
} 