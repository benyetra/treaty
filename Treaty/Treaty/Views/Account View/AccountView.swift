//
//  AccountView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//


import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import GoogleSignIn
import FirebaseFirestoreSwift

class UserCredentials: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
}


struct AccountView: View {
    // MARK: My Profile Data
    @State private var myProfile: User?
    @State var partnerUsername: String = ""
    @State private var partnerUser: User?
    // MARK: User Defaults Data
    @ObservedObject var credentials = UserCredentials()
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("user_token") var userTokenStored: String = ""
    @AppStorage("partnerUsernameStored") var partnerUsernameStored: String = ""
    @AppStorage("partnerUID") var partnerUIDStored: String = ""
    @AppStorage("partnerTokenStored") var tokenStored: String = ""
    @AppStorage("log_status") var logStatus: Bool = false
    // MARK: View Properties
    @Environment(\.colorScheme) private var colorScheme
    @State var errorMessage: String = ""
    @State private var password = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var addPartnerSheet: Bool = false
    @State var pendingPartnerSheet: Bool = false
    @State var editAccount: Bool = false
    @State var isShowingPasswordAlert: Bool = false
    @StateObject private var viewModel = PartnerRequestViewModel()
    @ObservedObject var userWrapper: UserWrapper
    var user: User
    
    init(userWrapper: UserWrapper) {
        self.userWrapper = userWrapper
        self.user = userWrapper.user
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                if let myProfile{
                    ReusableProfileContent(user: myProfile, userWrapper: userWrapper)
                }else{
                    ProgressView()
                }
            }
            .navigationTitle("My Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Manage Partner") { addPartnerSheet.toggle() }
                        Button("Edit Profile") { editAccount.toggle()}
                        Button("Logout",action: logOutUser)
                        Button("Delete Account", role: .destructive, action: {
                            isShowingPasswordAlert.toggle()
                        })
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(colorScheme == .light ? Color.black : Color("Sand"))
                            .scaleEffect(1)
                    }
                }
            }
            .fullScreenCover(isPresented: $editAccount){
                EditProfileView()
            }
            .sheet(isPresented: $addPartnerSheet){
                AddPartnerView(userWrapper: userWrapper)
            }
            .sheet(isPresented: $pendingPartnerSheet){
                PartnerRequestView(viewModel: PartnerRequestViewModel())
            }
            .sheet(isPresented: $isShowingPasswordAlert) {
                ReauthenticateDeleteAccountView()
            }
            if viewModel.partnerRequests.isEmpty {
            } else {
                HStack {
                    Button("\(viewModel.partnerRequests.count) Pending Partner Request") {
                        pendingPartnerSheet.toggle()
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal,20)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color("Blue"))
                    }
                }
                .vAlign(.top)
            }
        }
        .overlay {
            LoadingView(show: $isLoading)
        }
        .alert(errorMessage, isPresented: $showError) {
        }
        .task {
            // This Modifer is like onAppear
            // So Fetching for the First Time Only
            if myProfile != nil{return}
            // MARK: Initial Fetch
            await fetchUserData()
        }
    }
    
    
    // MARK: Fetching User Data
    func fetchUserData()async{
        guard let userUID = Auth.auth().currentUser?.uid else{return}
        guard let user = try? await Firestore.firestore().collection("Users").document(userUID).getDocument(as: User.self) else{return}
        await MainActor.run(body: {
            myProfile = user
        })
    }
    
    // MARK: Logging User Out
    func logOutUser(){
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        Firestore.firestore().clearPersistence { (error) in
            if let error = error {
                print("Error clearing Firestore instance cache: \(error)")
            } else {
                print("Successfully cleared Firestore instance cache")
            }
        }
        withAnimation(.easeInOut){
            userUID = ""
            userNameStored = ""
            profileURL = nil
            userTokenStored = ""
            partnerUsernameStored = ""
            partnerUIDStored = ""
            tokenStored = ""
            logStatus = false
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
