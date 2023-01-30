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
    @AppStorage("log_status") var logStatus: Bool = false
    // MARK: View Properties
    @Environment(\.colorScheme) private var colorScheme
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var addPartnerSheet: Bool = false

    var body: some View {
        NavigationStack{
            VStack{
                if let myProfile{
                    ReusableProfileContent(user: myProfile)
                        .refreshable {
                            // MARK: Refresh User Data
                            self.myProfile = nil
                            await fetchUserData()
                        }
                }else{
                    ProgressView()
                }
            }
            .navigationTitle("My Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // MARK: Two Action's
                        // 1. Logout
                        // 2. Delete Account
                        
                        Button("Add Partner") { addPartnerSheet.toggle() }
                        Button("Logout",action: logOutUser)
                        Button("Delete Account",role: .destructive,action: deleteAccount)
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.init(degrees: 90))
                            .tint(colorScheme == .light ? Color.black : Color("Sand"))
                            .scaleEffect(0.8)
                    }
                }
            }
            .sheet(isPresented: $addPartnerSheet){
                AddPartnerView()
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
        withAnimation(.easeInOut){
            userUID = ""
            userName = ""
            profileURL = nil
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
