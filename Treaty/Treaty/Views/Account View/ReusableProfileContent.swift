//
//  ReusableProfileContent.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestoreSwift
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct ReusableProfileContent: View {
    var user: User
    @ObservedObject var userWrapper: UserWrapper
    @AppStorage("partnerUsernameStored") var partnerUsernameStored: String = ""
    @State var partnerUsername: String = ""
    @State private var partnerToken: String = ""
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        CustomRefreshView(lottieFileName: "Loading", backgroundColor: Color(.clear), content:  {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack{
                    HStack(spacing: 12){
                        WebImage(url: user.userProfileURL).placeholder{
                            // MARK: Placeholder Imgae
                            Image("NullProfile")
                                .resizable()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("@\(user.username)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            if partnerUsername != "" {
                                Text("Partner: @\(partnerUsername)")
                            } else {
                                Text("Add your partner in the account menu")
                            }
                        }
                        .onAppear {
                            getPartnerData()
                        }
                        .hAlign(.leading)
                    }
                    
                    Text("Pet Information")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                        .hAlign(.leading)
                        .padding(.vertical,15)
                    
                }
                .padding(15)
            }
        }, onRefresh: {
            fetchUserData()
        })
    }
    
    func fetchUserData() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("Users").document(uid)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                let username = data["username"] as? String ?? ""
                let userUID = data["userUID"] as? String ?? ""
                let userEmail = data["userEmail"] as? String ?? ""
                let userProfileURL = data["userProfileURL"] as? String ?? ""
                let userToken = data["token"] as? String ?? ""
                let credits = data["credits"] as? Int ?? 50
                if let url = URL(string: userProfileURL) {
                    self.userWrapper.user = User(id: "", username: username, userUID: userUID, userEmail: userEmail, userProfileURL: url, token: userToken, credits: credits)
                } else {
                    let defaultURL = URL(string: "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png")!
                    self.userWrapper.user = User(id: "", username: username, userUID: userUID, userEmail: userEmail, userProfileURL: defaultURL, token: userToken, credits: credits)
                }
                if let partnerUID = data["partners"] as? String {
                    db.collection("Users").document(partnerUID).getDocument { (partnerDocument, error) in
                        if let partnerDocument = partnerDocument, partnerDocument.exists, let partnerData = partnerDocument.data(), let partnerUsername = partnerData["username"] as? String, let partnerProfileURL = partnerData["userProfileURL"] as? String, let partnerURL = URL(string: partnerProfileURL),
                           let partnerToken = partnerData["token"] as? String,
                           let partnerCredits = partnerData["credits"] as? Int
                        {
                            self.userWrapper.partner = PartnerModel(username: partnerUsername, userProfileURL: partnerURL, token: partnerToken, credits: partnerCredits, partnerUID: partnerUID)
                            self.partnerUsernameStored = partnerUsername
                        } else {
                            let defaultPartnerURL = URL(string: "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png")!
                            self.userWrapper.partner = PartnerModel(username: "", userProfileURL: defaultPartnerURL, token: "", credits: 50, partnerUID: partnerUID)
                        }
                    }
                } else {
                    self.userWrapper.partner = nil
                }
            } else {
                print("Document does not exist")
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
}

