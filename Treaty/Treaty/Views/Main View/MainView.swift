//
//  MainView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct MainView: View {
    @ObservedObject var userWrapper = UserWrapper(user: User(username: "", userUID: "", userEmail: "", userProfileURL: URL(string: "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png")!))
        @Environment(\.colorScheme) private var colorScheme

    init() {
        fetchUserData()
    }
    
    var body: some View {
        TabView{
            BarterView(userWrapper: userWrapper)
                .tabItem {
                    Image(systemName: "dollarsign.arrow.circlepath")
                    Text("Barter")
                }
                .environmentObject(userWrapper)

            
            JournalView(userWrapper: userWrapper)
                .tabItem {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    Text("Journal")
                }
                .environmentObject(userWrapper)

            AccountView()
                .tabItem {
                    Image(systemName: "figure.2.arms.open")
                    Text("Profile")
                }
                .environmentObject(userWrapper)
        }
        .tint(colorScheme == .light ? Color.black : Color.white)
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
                if let url = URL(string: userProfileURL) {
                    self.userWrapper.user = User(username: username, userUID: userUID, userEmail: userEmail, userProfileURL: url)
                } else {
                    let defaultURL = URL(string: "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png")!
                    self.userWrapper.user = User(username: username, userUID: userUID, userEmail: userEmail, userProfileURL: defaultURL)
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

