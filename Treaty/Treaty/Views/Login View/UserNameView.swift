//
//  UserNameView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct UserNameView: View {
    @State var userName: String = ""
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_UID") var userUID: String = ""
    @State var isLoading: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack {
            TextField("Username", text: $userName)
                .textContentType(.nickname)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .border(1, colorScheme == .light ? Color.black : Color.white).opacity(0.5)
                .onAppear {
                    if !self.userName.hasPrefix("@") {
                        self.userName = "@" + self.userName
                    }
                }
                .onChange(of: userName, perform: { value in
                    if value.contains(where: { !$0.isLetter && !$0.isNumber }) {
                        self.userName = String(value.filter { $0.isLetter || $0.isNumber })
                    }
                })
            
            Button(action: addUsername){
                // MARK: Login Button
                Text("Sign up")
                    .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                    .hAlign(.center)
                    .fillView(colorScheme == .light ? Color.black : Color.white)
            }
            .disableWithOpacity(userName == "")
            .padding(.top,10)
        }
    }
    
    func addUsername(){
        isLoading = true
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userUID)
        userRef.updateData(["username": userName]) { (error) in
            if let error = error {
                self.isLoading = false
                self.showError = true
                self.errorMessage = error.localizedDescription
            } else {
                self.isLoading = false
                self.userNameStored = self.userName
                self.logStatus = true
            }
        }
  }

    
    // MARK: Displaying Errors VIA Alert
    func setError(_ error: Error)async{
        // MARK: UI Must be Updated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
}

struct UserNameView_Previews: PreviewProvider {
    static var previews: some View {
        UserNameView()
    }
}
