//
//  ReauthenticateDeleteAccountView.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/18/23.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ReauthenticateDeleteAccountView: View {
    @State var isLoading: Bool = false
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State private var password = ""
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("log_status") var logStatus: Bool = false


    var body: some View {
        VStack {
            VStack(spacing: 10){
                Text("Please add your password to delete your account")
                    .font(.largeTitle.bold())
                    .hAlign(.leading)
                    .padding(15)
                
                TextField("Password", text: $password)
                    .textContentType(.nickname)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .border(1, colorScheme == .light ? Color.black : Color.white).opacity(0.5)
                
                Button(action: {
                    reauthenticateUserAndDeleteAccount(password: password)
                }) {
                    VStack {
                        Text("Delete Account")
                            .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                            .hAlign(.center)
                            .fillView(colorScheme == .light ? Color.black : Color.white)
                    }
                    .padding(20)
                }
                .disableWithOpacity(password == "")
            }
            .padding(30)
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func reauthenticateUserAndDeleteAccount(password: String) {
        guard let user = Auth.auth().currentUser else {
            // Handle error if user is not available
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: user.email!, password: password)
        isLoading = true
        Task {
            do {
                try await user.reauthenticate(with: credential)
                // User has been re-authenticated, call the deleteAccount function
                await deleteAccount()
            } catch {
                // Handle any errors that occur during re-authentication
                await setError(error)
            }
        }
    }
    
    // MARK: Deleting User Entire Account
    func deleteAccount(){
        isLoading = true
        Task{
            do{
                guard let userUID = Auth.auth().currentUser?.uid else{return}
                
                // Step 1: Check if user has any Profile_Images associated with their userUID
                let reference = Storage.storage().reference().child("Profile_Images").child(userUID)
                do {
                    _ = try await reference.getMetadata()
                    // if no error is thrown, it means image exists and can be deleted
                    try await reference.delete()
                } catch {
                    // if error is thrown, it means image does not exist and can be skipped
                }
                // Step 2: Deleting Firestore User Document
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                
                // Final Step: Deleting Auth Account and Setting Log Status to False
                try await Auth.auth().currentUser?.delete()
                Firestore.firestore().clearPersistence { (error) in
                    if let error = error {
                        print("Error clearing Firestore instance cache: \(error)")
                    } else {
                        print("Successfully cleared Firestore instance cache")
                    }
                }
                
                logStatus = false
            }catch{
                await setError(error)
            }
        }
    }
    
    // MARK: Setting Error
    func setError(_ error: Error)async{
        // MARK: UI Must be run on Main Thread
        await MainActor.run(body: {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
        })
    }
}
