//
//  EditProfileView.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/2/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI
import SDWebImageSwiftUI

struct EditProfileView: View {
    //MARK: User Properties
    var docRef: DocumentReference!
    @State var emailID: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userProfilePicData: Data?

    //MARK: View Properties
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State var showImagePicker: Bool = false
    @State var photoItem: PhotosPickerItem?
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    @State private var selection: String?
    @State private var isTextFieldEnabled: Bool = false

    // MARK: User Defaults
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing:10) {
                Text("Edit your profile")
                    .font(.largeTitle.bold())
                    .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                    .hAlign(.leading)
                
                Text("Update your profile information")
                    .font(.title3)
                    .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                    .hAlign(.leading)
                
                //MARK: Optimize Size
                ViewThatFits {
                    ScrollView(.vertical, showsIndicators: false) {
                        HelperView()
                    }
                    HelperView()
                }
                //MARK: Cancel Button
                HStack {
                    Text("Want to revisit this later?")
                        .foregroundColor(.gray)
                    Button("Cancel") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
                .font(.callout)
                .vAlign(.bottom)
            }
        }
        .vAlign(.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            //MARK: Extracting UIImage From PhotoItem
            Task {
                do {
                    guard let imageData = try await newValue?.loadTransferable(type: Data.self) else {return}
                    //MARK: UI Must Be Updated on Main Thread
                    await MainActor.run(body: {
                        userProfilePicData = imageData
                    })
                }catch{}
            }
        }
        // MARK: Displaying Alert
        .alert(errorMessage, isPresented: $showError, actions: {})
    }
    
    @ViewBuilder
    func HelperView() -> some View {
        VStack(spacing:12) {
            ZStack {
                if let userProfilePicData, let image = UIImage(data: userProfilePicData) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image("NullProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(colorScheme == .light ? Color("Blue") : Color("Sand"), lineWidth: 1))
                }
            }
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top, 25)
            
            // MARK: Displaying Alert
            .alert(errorMessage, isPresented: $showError, actions: {})
            
            Text("Edit Profile Picture")
                .font(.title3)
                .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                .hAlign(.center)
            
            Text("Tap on the image to change it")
                .font(.subheadline)
                .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                .hAlign(.center)
                .padding(-10)
            
            Spacer(minLength: 5)
            
            TextField("Username", text: $userName)
                .foregroundColor(colorScheme == .light ? Color.gray : Color.white)
                .textContentType(.nickname)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .border(1, colorScheme == .light ? Color.black : Color.white.opacity(0.5))
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
            
            TextField("Email", text:$emailID)
                .foregroundColor(colorScheme == .light ? Color.gray : Color.white)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .border(1, colorScheme == .light ? Color.black : Color.white.opacity(0.5))
            
                Button(action: {
                    updateUserInfo { (error) in
                        if let error = error {
                            // Handle the error
                            self.errorMessage = error.localizedDescription
                            self.showError = true
                        }
                    }
                }) {
                    Text("Save Changes")
                        .foregroundColor(colorScheme == .light ? Color("Sand") : Color("Blue"))
                        .hAlign(.center)
                        .fillView(colorScheme == .light ? Color("Blue") : Color("Sand"))
                        .hAlign(.center)
                }
                .disableWithOpacity(userName == "" || emailID == "")
                .padding(.top,10)
            }
        .onAppear {
            getUserData()
        }
    }
    
    func updateUserInfo(completion: @escaping (Error?) -> Void) {
        isLoading = true
        closeKeyboard()
        // Get Firestore instance
        let db = Firestore.firestore()
        
        // Get user's uid, if it exists
        if let uid = Auth.auth().currentUser?.uid {
            guard let imageData = userProfilePicData else {
                completion(nil)
                return
            }
            let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
            storageRef.putData(imageData) { (metadata, error) in
                if let error = error {
                    completion(error)
                } else {
                    // Downloading Photo URL
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            completion(error)
                        } else {
                            // Update user's data in Firebase Firestore
                            db.collection("Users").document(uid).updateData([
                                "userEmail": self.emailID,
                                "username": self.userName.lowercased()
                            ]) { (error) in
                                if let error = error {
                                    // Show error message
                                    self.errorMessage = error.localizedDescription
                                    self.showError = true
                                    completion(error)
                                } else {
                                    // Update user's data in UserDefaults
                                    self.userNameStored = self.userName.lowercased()
                                    self.logStatus = true
                                    // Dismiss view
                                    self.dismiss()
                                    completion(nil)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            // Handle error: uid is nil
            self.errorMessage = "Error: Could not retrieve user's uid"
            self.showError = true
            completion(nil)
        }
    }
    
    func getUserData() {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser?.uid
        db.collection("Users").document(uid!).getDocument { (document, error) in
            if let document = document, document.exists {
                self.emailID = document["userEmail"] as? String ?? ""
                self.userName = document["username"] as? String ?? ""
                self.userProfilePicData = document["userProfileURL"] as? Data
            } else {
                print("Error getting user data: \(error)")
            }
        }
    }
}

