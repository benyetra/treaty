//
//  BarterView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//
import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth

class UserWrapper: ObservableObject {
    @Published var user: User
    
    init(user: User) {
        self.user = user
    }
}

struct BarterView: View {
    @ObservedObject var userWrapper: UserWrapper
    
    init(userWrapper: UserWrapper) {
        self.userWrapper = userWrapper
    }
    
    var body: some View {
        if userWrapper.user.username.isEmpty {
            UserNameView()
        } else {
            Text("Hello World")
        }
    }
}



//struct BarterView_Previews: PreviewProvider {
//    static var previews: some View {
//        BarterView()
//    }
//}
