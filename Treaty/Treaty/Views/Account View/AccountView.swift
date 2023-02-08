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
    @AppStorage("user_name") var userName: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("user_token") var userTokenStored: String = ""
    @AppStorage("partnerUsernameStored") var partnerUsernameStored: String = ""
    @AppStorage("partnerUID") var partnerUIDStored: String = ""
    @AppStorage("partnerTokenStored") var tokenStored: String = ""
    @AppStorage("log_status") var logStatus: Bool = false
    // MARK: View Properties
    @Environment(\.colorScheme) private var colorScheme
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var addPartnerSheet: Bool = false
    @State var pendingPartnerSheet: Bool = false
    @State var editAccount: Bool = false
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
                        Button("Delete Account",role: .destructive,action: deleteAccount)
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
            userName = ""
            profileURL = nil
            userTokenStored = ""
            partnerUsernameStored = ""
            partnerUIDStored = ""
            tokenStored = ""
            logStatus = false
        }
    }
    
    // MARK: Deleting User Entire Account
    func deleteAccount(){
        isLoading = true
        Task{
            do{
                guard let userUID = Auth.auth().currentUser?.uid else{return}

                // Step 1: Check if user has any Profile_Images associated with their userUID
                let reference = Storage.storage().reference().child("Profile_Images").child(userUID)
                do {
                    _ = try await reference.getMetadata()
                    // if no error is thrown, it means image exists and can be deleted
                    try await reference.delete()
                } catch {
                    // if error is thrown, it means image does not exist and can be skipped
                }
                // Step 2: Deleting Firestore User Document
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                
                // Final Step: Deleting Auth Account and Setting Log Status to False
                try await Auth.auth().currentUser?.delete()
                Firestore.firestore().clearPersistence { (error) in
                    if let error = error {
                        print("Error clearing Firestore instance cache: \(error)")
                    } else {
                        print("Successfully cleared Firestore instance cache")
                    }
                }

                logStatus = false
            }catch{
                await setError(error)
            }
        }
    }

    
    // MARK: Setting Error
    func setError(_ error: Error)async{
        // MARK: UI Must be run on Main Thread
        await MainActor.run(body: {
            isLoading = false
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
