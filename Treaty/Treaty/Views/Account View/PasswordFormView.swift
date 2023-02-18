//
//  PasswordFormView.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/17/23.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct PasswordFormView: View {
    //MARK: User Properties
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    //MARK: View Properties
    @Environment(\.dismiss) var dismiss
    
    // MARK: Displaying Alert
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Password")) {
                    SecureField("Enter current password", text: $currentPassword)
                        .textContentType(.password)
                }
                Section(header: Text("New Password")) {
                    SecureField("Enter new password", text: $newPassword)
                        .textContentType(.newPassword)
                    
                    SecureField("Confirm new password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel"){
                        dismiss()
                    }.foregroundColor(Color.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save"){
                        changePassword()
                    }
                    .disableWithOpacity(
                    (newPassword != confirmPassword) ||
                    ((newPassword != "" || currentPassword != "") && newPassword.count < 6) ||
                    ((confirmPassword != "" || currentPassword != "") && confirmPassword.count < 6) ||
                    (currentPassword != "" && newPassword == "" && confirmPassword == "")
                    )
                }
            }
            .alert(errorMessage, isPresented: $showError, actions: {
                Button("OK", role: .cancel) {
                    showError = false
                }
            })
        }
    }
    
    func changePassword() {
        if newPassword.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Please enter a new password and confirm it."
            showError = true
            return
        }
        
        if newPassword != confirmPassword {
            errorMessage = "Passwords don't match."
            showError = true
            return
        }
        
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: currentPassword)
        
        user?.reauthenticate(with: credential, completion: { _, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showError = true
                return
            }
            
            user?.updatePassword(to: newPassword, completion: { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    return
                }
                
                dismiss()
            })
        })
    }
}
