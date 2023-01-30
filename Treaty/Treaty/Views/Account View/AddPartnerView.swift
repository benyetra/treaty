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
    @State var titleText = "Want to be my Partner?"
    @State var bodyText = "Open the app to accept or decline the partnership request!"
    @State var deviceToken = "cao_U2pQaknmohy5B6B7iu:APA91bHGVsIq2P776B1R8Syi8m6_6O_Rz6ZdnfkEF7nRGfeUAtcorrSyeqkQo6-8Flj1IPI50sgycSKaNtys0AJ7bF8neQMhB0U4tCv3rFwWiucUgjqZfmPSsXZHU1bB2cdVd15ewDFZ"
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
        
        NavigationView{
            
            List{
                
                Section {
                    TextField("", text: $titleText)
                } header: {
                    Text("Message Title")
                }
                
                Section {
                    TextField("", text: $bodyText)
                } header: {
                    Text("Message Body")
                }
                
                Section {
                    TextField("", text: $deviceToken)
                } header: {
                    Text("Device Token")
                }
                
                Button {
                    sendMessageToDevice()
                } label: {
                    Text("Send Push Notification")
                }


            }
            .listStyle(.insetGrouped)
            .navigationTitle("Push Notification")
        }
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
    
    func sendPartnerRequest() {
        if let partnerUser = self.partnerUser, let currentUser = Auth.auth().currentUser {
            let request = [
                "from": currentUser.uid,
                "username": currentUser.displayName ?? ""
            ]
            let db = Firestore.firestore()
            db.collection("Users").document(partnerUser.userUID).collection("PartnerRequests").document(currentUser.uid).setData(request) { (error) in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    print("Error sending request: \(error)")
                } else {
                    self.successMessage = "Partner request sent successfully!"
                    self.showSuccess = true
                    print("Request sent successfully")
                    // send APNS notification to partnerUser
                }
            }
        }
    }
    
    
    
    func savePartner() {
        searchForPartner()
        sendPartnerRequest()
        sendMessageToDevice()
    }
    
    func sendPushNotification(toToken token: String, title: String, body: String) {
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAtmf3cpE:APA91bGYuNqm0U9i_TM6UNuze11Vwk813RNQs8LZvGYKMl9QcYgSxGy-EUeccJs1_3GSRiJKwq39xNH0Ji3CN2nQ7WiPgrdnhMIBIs6M2GBaCnJl2gEmsOdyCnlco4bU9GwK4OBF6obA", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        let payload = [
            "to": token,
            "notification": [
                "title": title,
                "body": body
            ]
        ] as [String : Any]
        request.httpBody = try! JSONSerialization.data(withJSONObject: payload)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending push notification: (error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("Push notification sent, status code: (response.statusCode)")
            }
        }.resume()
    }
    
    func sendMessageToDevice(){
        
        // Simple Logic
        // Using Firebase API to send Push Notification to another device using token
        // Without having server....
        
        // Converting That to URL Request Format....
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else{
            return
        }
        
        let json: [String: Any] = [
            
            "to": deviceToken,
            "notification": [
                
                "title": titleText,
                "body": bodyText
            ],
            "data": [
                
                // Data to be Sent....
                // Dont pass empty or remove the block..
                "user_name": "byetrz"
            ]
        ]
        
        
        // Use Your Firebase Server Key !!!
        let serverKey = "AAAAtmf3cpE:APA91bGYuNqm0U9i_TM6UNuze11Vwk813RNQs8LZvGYKMl9QcYgSxGy-EUeccJs1_3GSRiJKwq39xNH0Ji3CN2nQ7WiPgrdnhMIBIs6M2GBaCnJl2gEmsOdyCnlco4bU9GwK4OBF6obA"
        
        // URL Request...
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // COnverting json Dict to JSON...
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        // Setting COntent Type and Authoritzation...
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Authorization key will be Your Server Key...
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        
        // Passing request using URL session...
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) { _, _, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            // Else Success
            // Clearing Fields..
            // Or Your Action when message sends...
            print("Success")
            DispatchQueue.main.async {[self] in
                titleText = ""
                bodyText = ""
                deviceToken = ""
            }
        }
        .resume()
    }
}
