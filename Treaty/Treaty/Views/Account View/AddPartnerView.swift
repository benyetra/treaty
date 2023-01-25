//
//  AddPartnerView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/24/23.
//

import SwiftUI
import FirebaseFirestoreSwift
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct AddPartnerView: View {
    @State private var partnerUsername: String = ""
    @State private var partnerUser: User?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State private var showAlert = false
    @State private var successMessage = "Partner saved successfully!"
    @State var showSuccess = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack {
            VStack(spacing: 10){
                Text("Lets add your Partner!")
                    .font(.largeTitle.bold())
                    .hAlign(.leading)
                    .padding(15)
                
                TextField("Partner's Username", text: $partnerUsername)
                    .textContentType(.nickname)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .border(1, colorScheme == .light ? Color.black : Color.white).opacity(0.5)
                    .onAppear {
                        if !self.partnerUsername.hasPrefix("@") {
                            self.partnerUsername = "@" + self.partnerUsername
                        }
                    }
                    .onChange(of: partnerUsername, perform: { value in
                        var filteredValue = value
                        if value.contains(where: { !$0.isLetter && !$0.isNumber }) {
                            filteredValue = String(value.filter { $0.isLetter || $0.isNumber })
                        }
                        self.partnerUsername = filteredValue
                    })
                VStack {
                    Button(action: {
                        self.searchForPartner()
                        if self.partnerUser == nil {
                            self.showError = true
                            self.errorMessage = "Partner not found, please check username and try again."
                        } else {
                            self.showAlert = true
                        }
                    }) {
                        Text("Save")
                            .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                            .hAlign(.center)
                            .fillView(colorScheme == .light ? Color.black : Color.white)
                    }
                    .disableWithOpacity(partnerUsername == "")
                    .padding(20)
                    if showSuccess {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .padding()
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Confirmation"), message: Text("Are you sure you want to save this partner?"), primaryButton: .default(Text("Save"), action: {
                        self.addPartner()
                        self.showSuccess = true
                    }), secondaryButton: .cancel())
                }
            }
        }
        .padding(30)
    }
    
    func searchForPartner() {
            // Get all users from Firestore
            let usersRef = Firestore.firestore().collection("Users")
            usersRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting users: \(error)")
                    return
                }
                // Iterate through all users to find the one with the matching username
                for document in querySnapshot!.documents {
                    if  document.data().keys.contains("username") && document.data().keys.contains("userProfileURL") && document.data().keys.contains("userUID") && document.data().keys.contains("userEmail") && document.data().keys.contains("id") && document.data().keys.contains("partner") {
                        let usersPartner = try! Firestore.Decoder().decode(User.self, from: document.data())
                        if usersPartner.username == self.partnerUsername {
                            self.partnerUser = usersPartner
                            break
                        }
                    }
                }
            }
        }

    func addPartner() {
        guard let partnerUser = self.partnerUser else {
            print("Error: partnerUser is nil")
            return
        }
        // Add the selected partner user to the current user's "partners" list in Firestore
        let currentUserUID = Auth.auth().currentUser?.uid
        let currentUserRef = Firestore.firestore().collection("Users").document(currentUserUID!)
        let partner = PartnerModel(username: partnerUser.username, userProfileURL: partnerUser.userProfileURL)
        currentUserRef.updateData(["partner": partner]) { (error) in
            if let error = error {
                print("Error adding partner: \(error)")
                return
            }
            print("Partner added successfully!")
        }
    }

}
