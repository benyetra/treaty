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
                        self.searchForPartner()
                        showAlert.toggle()
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
                        self.savePartner()
                        self.showSuccess = true
                    }), secondaryButton: .cancel())
                }
            }
            .onAppear {
                self.getPartnerData()
            }
            .padding(30)
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
    
    func getPartnerData() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {
            print("nil")
            return
        }
        db.collection("Users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let partnerUID = document["partners"] as? String ?? ""
                if partnerUID.isEmpty {
                    print("Partner UID not found in user document")
                    return
                }
                db.collection("Users").document(partnerUID).getDocument { (partnerDocument, error) in
                    if let partnerDocument = partnerDocument, partnerDocument.exists {
                        self.partnerUsername = partnerDocument["username"] as? String ?? ""
                    } else {
                        print("Error getting partner data: \(error)")
                    }
                }
            } else {
                print("Error getting user data: \(error)")
            }
        }
    }



    
    func addOrUpdatePartner(partner: User) {
            let currentUserUID = Auth.auth().currentUser?.uid
            let currentUserRef = Firestore.firestore().collection("Users").document(currentUserUID!)
            currentUserRef.updateData(["partners": partner.userUID]) { (error) in
                if let error = error {
                    print("Error adding/updating partner: \(error)")
                } else {
                    // Also update the partner's document with the current user as their partner
                    let partnerRef = Firestore.firestore().collection("Users").document(partner.userUID)
                    partnerRef.updateData(["partners": currentUserUID]) { (error) in
                        if let error = error {
                            print("Error adding/updating partner: \(error)")
                        } else {
                            self.showSuccess = true
                        }
                    }
                }
            }
        }

    func addPartner() {
        if let partnerUser = self.partnerUser {
            // call the function to add the selected partner user to the current user's "partners" list in Firestore
            addOrUpdatePartner(partner: partnerUser)
        } else {
            self.showError = true
            self.errorMessage = "Error: partnerUser is nil"
        }
    }

    func updatePartner() {
        // Add the selected partner user to the current user's "partners" list in Firestore
        if let partnerUser = partnerUser {
            addOrUpdatePartner(partner: partnerUser)
        } else {
            // Handle the case where partnerUser is nil
            print("partnerUser is nil")
        }
    }

    
    func savePartner() {
            addPartner()
            updatePartner()
        }
}
