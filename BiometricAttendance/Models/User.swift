import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var email: String
    var name: String
    var hasRegisteredBiometrics: Bool
    var lastCheckIn: Date?
    var lastCheckOut: Date?
    
    init(id: UUID = UUID(), email: String, name: String) {
        self.id = id
        self.email = email
        self.name = name
        self.hasRegisteredBiometrics = false
    }
}

// MARK: - Validation
extension User {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
} 