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
    @State private var showAlert = false
    @State private var successMessage = "Username saved successfully!"
    @State var showSuccess = false
    @State var userName: String = ""
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_UID") var userUID: String = ""
    @State var isLoading: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userWrapper: UserWrapper

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
                VStack {
                    Button(action: {
                        self.showAlert = true
                    }) {
                        Text("Save")
                            .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                            .hAlign(.center)
                            .fillView(colorScheme == .light ? Color.black : Color.white)
                    }
                    .disableWithOpacity(userName == "")
                    .padding(20)
                    if showSuccess {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .padding()
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Confirmation"), message: Text("Are you sure you want to save this username?"), primaryButton: .default(Text("Save"), action: {
                        self.addUsername()
                        self.showSuccess = true
                        self.userWrapper.user.username = self.userName
                    }), secondaryButton: .cancel())
                }
                NavigationLink(destination: BarterView(userWrapper: userWrapper), isActive: $showSuccess) {
                    EmptyView()
                }
            }
        }
        .padding(30)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.dismiss()
                }
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
    
    func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    }
}


struct UserNameView_Previews: PreviewProvider {
    static var previews: some View {
        UserNameView()
    }
}
