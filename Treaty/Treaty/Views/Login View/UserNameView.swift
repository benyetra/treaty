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
    @State var showSuccess = false
    @State var successMessage = ""
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
            VStack(spacing: 10){
                Text("Lets set your \nUsername!")
                    .font(.largeTitle.bold())
                    .hAlign(.leading)
                    .padding(15)

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
                            var filteredValue = value
                            if value.contains(where: { !$0.isLetter && !$0.isNumber }) {
                                filteredValue = String(value.filter { $0.isLetter || $0.isNumber })
                            }
                            self.userName = filteredValue
                        })
                
                Button(action: addUsername){
                    // MARK: Login Button
                    Text("Save")
                        .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                        .hAlign(.center)
                        .fillView(colorScheme == .light ? Color.black : Color.white)
                    if showSuccess {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .padding()
                    }
                }
                .disableWithOpacity(userName == "")
                .padding(20)
            }
            .padding(30)
        }
    }
    
    func addUsername(){
        isLoading = true
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userUID)
        userRef.updateData(["username": userName]) { (error) in
            if let error = error {
                self.isLoading = false
                self.showError = true
                self.errorMessage = error.localizedDescription
            }else{
                self.isLoading = false
                self.showSuccess = true
                self.successMessage = "Username added successfully!"
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
