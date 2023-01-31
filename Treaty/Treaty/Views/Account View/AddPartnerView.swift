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
    @State var partnerUsername: String = ""
    @State private var partnerToken: String = ""
    @State private var partnerUser: User?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State private var showAlert = false
    @State private var successMessage = "Partner saved successfully!"
    @State var showSuccess = false
    @State var titleText = "want to be "
    @State var bodyText = "Open the app to accept or decline the partnership request!"
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var userWrapper: UserWrapper

    var user: User
    init(userWrapper: UserWrapper) {
        self.userWrapper = userWrapper
        self.user = userWrapper.user
    }
    
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
                if let partnerToken = usersPartner.token {
                    self.partnerToken = partnerToken
                    print("partner found : \(self.partnerUser)")
                } else {
                    print("Partner token not found")
                }
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
                        self.partnerToken = partnerDocument["token"] as? String ?? ""
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
        let senderUserUID = Auth.auth().currentUser?.uid
        let currentUserRef = Firestore.firestore().collection("Users").document(senderUserUID!)
        currentUserRef.updateData(["partners": partner.userUID]) { (error) in
            if let error = error {
                print("Error adding/updating partner: \(error)")
            } else {
                // Also update the partner's document with the current user as their partner
                let partnerRef = Firestore.firestore().collection("Users").document(partner.userUID)
                partnerRef.updateData(["partners": senderUserUID]) { (error) in
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
    
    func sendPartnerRequest() {
        if let partnerUser = self.partnerUser, let currentUser = Auth.auth().currentUser {
            let requestData: [String: Any] = [
                "senderUsername": user.username,
                "receiverUsername": partnerUser.username,
                "senderUID": currentUser.uid,
                "receiverUID": partnerUser.userUID
            ]
            let db = Firestore.firestore()
            db.collection("PartnerRequests").addDocument(data: requestData) { (error) in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    print("Error sending partner request: (error)")
                    return
                }
                self.successMessage = "Partner request sent successfully! \nSwipe down to dismiss"
                self.showSuccess = true
                self.titleText = "Hey \(partnerUser.username),  \(titleText) \(user.username)'s partner?"
                sendPushNotification(to: partnerToken, title: titleText, body: bodyText)
                print("Partner request sent successfully")
            }
        }
    }
    
    func savePartner() {
        searchForPartner()
        sendPartnerRequest()
    }
    
    func sendPushNotification(to token: String, title: String, body: String) {
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAtmf3cpE:APA91bGYuNqm0U9i_TM6UNuze11Vwk813RNQs8LZvGYKMl9QcYgSxGy-EUeccJs1_3GSRiJKwq39xNH0Ji3CN2nQ7WiPgrdnhMIBIs6M2GBaCnJl2gEmsOdyCnlco4bU9GwK4OBF6obA", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        let data: [String: Any] = [
            "to": token,
            "notification": [
                "title": (title),
                "body": body
            ],
            "priority": "high"
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: data, options: [])
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error sending push notification: \(error)")
            } else if let response = response as? HTTPURLResponse {
                print("Push notification sent with response: \(response)")
            }
        }.resume()
    }
}
