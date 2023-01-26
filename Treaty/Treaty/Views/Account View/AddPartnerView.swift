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
                Button(action: {
                    searchForPartner()
                    if self.partnerUser != nil {
                        addPartnerToFirestore(partner: self.partnerUser!)
                        self.showAlert = true
                    } else {
                        self.showError = true
                        self.errorMessage = "Partner not found, please check username and try again."
                    }
                }) {
                    Text("Save")
                        .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                        .hAlign(.center)
                        .fillView(colorScheme == .light ? Color.black : Color.white)
                }
                
                .disabled(partnerUsername.isEmpty)
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
        }.padding(30)
    }
    
    func handleUpdateData(error: Error?) {
        if let error = error {
            print("Error adding partner: \(error)")
        } else {
            self.showSuccess = true
        }
    }
    
    func searchForPartner() {
        let usersRef = Firestore.firestore().collection("Users")
        let query = usersRef.whereField("username", isEqualTo: partnerUsername)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else if let querySnapshot = querySnapshot, let document = querySnapshot.documents.first, let usersPartner = try? Firestore.Decoder().decode(User.self, from: document.data()) {
                self.partnerUser = usersPartner
                print("partner found : \(self.partnerUser)")
            } else {
                print("Partner not found")
            
            }
        }
    }
    
    
    func addPartnerToFirestore(partner: User) {
        let currentUserUID = Auth.auth().currentUser?.uid
        let currentUserRef = Firestore.firestore().collection("Users").document(currentUserUID!)
        let partnerModel = PartnerModel(username: partner.username, userProfileURL: partner.userProfileURL)
        currentUserRef.updateData(["partners": partnerModel.username]) { (error) in
            if let error = error {
                print("Error adding partner: (error)")
            } else {
                self.showSuccess = true
            }
        }
    }
    
    func addPartner() {
          if let partnerUser = self.partnerUser {
              //call the function to add the selected partner user to the current user's "partners" list in Firestore
              addPartnerToFirestore(partner: partnerUser)
          } else {
              self.showError = true
              self.errorMessage = "Error: partnerUser is nil"
          }
      }

    func updatePartner() {
            // Add the selected partner user to the current user's "partners" list in Firestore
            let currentUserUID = Auth.auth().currentUser?.uid
            let currentUserRef = Firestore.firestore().collection("Users").document(currentUserUID!)

            if let partnerUser = partnerUser {
                let partner = PartnerModel(username: partnerUser.username, userProfileURL: partnerUser.userProfileURL)
                currentUserRef.updateData(["partners": partner]) { (error) in
                    if let error = error {
                        print("Error adding partner: (error)")
                        return
                    }
                    print("Partner added successfully!")
                }
            } else {
                // Handle the case where partnerUser is nil
            }
        }
    
    func savePartner() {
            addPartner()
            updatePartner()
        }
}
