//
//  RegisterView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

// MARK: Register View
struct RegisterView: View{
    // MARK: User Details
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userProfilePicData: Data?
    // MARK: View Properties
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    // MARK: UserDefaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    var body: some View{
        VStack(spacing: 10){
            Text("Lets Register\nAccount")
                .font(.largeTitle.bold())
                .hAlign(.leading)
            
            Text("Hello user, have a wonderful journey")
                .font(.title3)
                .hAlign(.leading)
            
            // MARK: For Smaller Size Optimization
            ViewThatFits {
                ScrollView(.vertical, showsIndicators: false) {
                    HelperView()
                }
                
                HelperView()
            }
            
            // MARK: Register Button
            HStack{
                Text("Already Have an account?")
                    .foregroundColor(.gray)
                
                Button("Login Now"){
                    dismiss()
                }
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .light ? Color.black : Color.white)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            // MARK: Extracting UIImage From PhotoItem
            if let newValue{
                Task{
                    do{
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else{return}
                        // MARK: UI Must Be Updated on Main Thread
                        await MainActor.run(body: {
                            userProfilePicData = imageData
                        })
                        
                    }catch{}
                }
            }
        }
        // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    @ViewBuilder
    func HelperView()->some View{
        VStack(spacing: 12){
            ZStack{
                if let userProfilePicData, let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image("NullProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(colorScheme == .light ? Color.black : Color.white, lineWidth: 2))
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top,25)
            
            TextField("Username", text: $userName)
                .textContentType(.nickname)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .border(1, colorScheme == .light ? Color.black : Color.white).opacity(0.5)
                .onAppear {
                    if !self.userName.hasPrefix("@") {
                        self.userName = "@" + self.userName
                    }
                }
                .onChange(of: userName, perform: { value in
                    if value.contains(where: { !$0.isLetter && !$0.isNumber }) {
                        self.userName = String(value.filter { $0.isLetter || $0.isNumber })
                    }
                })
            
            TextField("Email", text: $emailID)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .border(1, colorScheme == .light ? Color.black : Color.white).opacity(0.5)

            SecureField("Password", text: $password)
                .textContentType(.password)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .border(1, colorScheme == .light ? Color.black : Color.white).opacity(0.5)

            Button(action: registerUser){
                // MARK: Login Button
                Text("Sign up")
                    .foregroundColor(colorScheme == .light ? Color.white : Color.black)
                    .hAlign(.center)
                    .fillView(colorScheme == .light ? Color.black : Color.white)
            }
            .disableWithOpacity(userName == "" || emailID == "" || password == "" || userProfilePicData == nil)
            .padding(.top,10)
        }
    }
    
    func registerUser(){
        isLoading = true
        closeKeyboard()
        Task{
            do{
                // Step 1: Creating Firebase Account
                try await Auth.auth().createUser(withEmail: emailID, password: password)
                // Step 2: Uploading Profile Photo Into Firebase Storage
                guard let userUID = Auth.auth().currentUser?.uid else{return}
                guard let imageData = userProfilePicData else{return}
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                // Step 3: Downloading Photo URL
                let downloadURL = try await storageRef.downloadURL()
                // Step 4: Creating a User Firestore Object
                let user = User(id: "",username: userName, userUID: userUID, userEmail: emailID, userProfileURL: downloadURL, token: "", credits: 50)
                // Step 5: Saving User Doc into Firestore Database
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user, completion: { error in
                    if error == nil{
                        // MARK: Print Saved Successfully
                        print("Saved Successfully")
                        userNameStored = userName
                        self.userUID = userUID
                        profileURL = downloadURL
                        logStatus = true
                    }
                })
            }catch{
                // MARK: Deleting Created Account In Case of Failure
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
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

