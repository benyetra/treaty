//
//  LoginView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    // MARK: View Properties
    @StateObject var loginModel: LoginViewModel = .init()
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    // MARK: User Defaults
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("log_status") var logStatus: Bool = false
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10){
                Text("Lets Sign you in")
                    .font(.largeTitle.bold())
                    .hAlign(.leading)
                
                Text("Welcome Back,\nYou have been missed")
                    .font(.title3)
                    .hAlign(.leading)
                
                VStack(spacing: 12){
                    TextField("Email", text: $emailID)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .border(1, .gray.opacity(0.5))
                        .padding(.top,25)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                        .border(1, .gray.opacity(0.5))
                    
                    Button("Reset password?", action: resetPassword)
                        .font(.callout)
                        .fontWeight(.medium)
                        .tint(.black)
                        .hAlign(.trailing)
                    
                    Button(action: loginUser){
                        // MARK: Login Button
                        Text("Sign in")
                            .foregroundColor(.white)
                            .hAlign(.center)
                            .fillView(.black)
                    }
                    .padding(.top,10)
                }
                .padding(.leading,-60)
                .frame(maxWidth: .infinity)
                .alert(loginModel.errorMessage, isPresented: $loginModel.showError) {}
                
                HStack(spacing: 8){
                    // MARK: Custom Apple Sign in Button
                    CustomButton()
                        .overlay {
                            SignInWithAppleButton { (request) in
                                loginModel.nonce = randomNonceString()
                                request.requestedScopes = [.email,.fullName]
                                request.nonce = sha256(loginModel.nonce)
                                
                            } onCompletion: { (result) in
                                switch result{
                                case .success(let user):
                                    print("success")
                                    guard let credential = user.credential as? ASAuthorizationAppleIDCredential else{
                                        print("error with firebase")
                                        return
                                    }
                                    loginModel.appleAuthenticate(credential: credential)
                                case.failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                            .signInWithAppleButtonStyle(.white)
                            .frame(height: 55)
                            .blendMode(.overlay)
                        }
                        .clipped()
                    
                    // MARK: Custom Google Sign in Button
                    CustomButton(isGoogle: true)
                        .overlay {
                            // MARK: We Have Native Google Sign in Button
                            // It's Simple to Integrate Now
                            GoogleSignInButton{
                                Task{
                                    do{
                                        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.rootController())
                                        
                                        loginModel.logGoogleUser(user: result.user)
                                        
                                    }catch{
                                        print(error.localizedDescription)
                                    }
                                }
                            }
                            .blendMode(.overlay)
                        }
                        .clipped()
                }
                .padding(.leading,-60)
                .frame(maxWidth: .infinity)
            }
            .padding(.leading,60)
            .padding(.vertical,15)
            // MARK: Register Button
            HStack{
                Text("Don't have an account?")
                    .foregroundColor(.gray)
                
                Button("Register Now"){
                    createAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        // MARK: Register View VIA Sheets
        .fullScreenCover(isPresented: $createAccount) {
            RegisterView()
        }
        // MARK: Displaying Alert
        .alert(loginModel.errorMessage, isPresented: $loginModel.showError) {
        }
    }
    
    
    func loginUser(){
        isLoading = true
        closeKeyboard()
        Task{
            do{
                // With the help of Swift Concurrency Auth can be done with Single Line
                try await Auth.auth().signIn(withEmail: emailID, password: password)
                print("User Found")
                try await fetchUser()
            }catch{
                await setError(error)
            }
        }
    }
    
    // MARK: If User if Found then Fetching User Data From Firestore
    func fetchUser()async throws{
        guard let userID = Auth.auth().currentUser?.uid else{return}
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        // MARK: UI Updating Must be Run On Main Thread
        await MainActor.run(body: {
            // Setting UserDefaults data and Changing App's Auth Status
            userUID = userID
            userNameStored = user.username
            profileURL = user.userProfileURL
            logStatus = true
        })
    }
    
    func resetPassword(){
        Task{
            do{
                // With the help of Swift Concurrency Auth can be done with Single Line
                try await Auth.auth().sendPasswordReset(withEmail: emailID)
                print("Link Sent")
            }catch{
                await setError(error)
            }
        }
    }
    
    // MARK: Displaying Errors VIA Alert
    func setError(_ error: Error)async{
        // MARK: UI Must be Updated on Main Thread
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
    
    @ViewBuilder
    func CustomButton(isGoogle: Bool = false)->some View{
        HStack{
            Group{
                if isGoogle{
                    Image("Google")
                        .resizable()
                        .renderingMode(.template)
                }else{
                    Image(systemName: "applelogo")
                        .resizable()
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .frame(height: 45)
            
            Text("\(isGoogle ? "Google" : "Apple") Sign in")
                .font(.callout)
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal,15)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
