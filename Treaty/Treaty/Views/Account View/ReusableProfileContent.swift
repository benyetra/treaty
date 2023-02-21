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
    @AppStorage("partnerUID") var partnerUIDStored: String = ""
    @AppStorage("parnterLinked") var partnerLinked: Bool = false
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @AppStorage("user_profile_url") var profileURL: URL?
    @State var partnerUsername: String = ""
    @State private var partnerToken: String = ""
    @State private var showLightbox = false
    @State private var showPetView = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        CustomRefreshView(lottieFileName: "Loading", backgroundColor: Color(.clear), content:  {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack{
                    HStack(spacing: 12){
                        WebImage(url: profileURL).placeholder{
                            // MARK: Placeholder Image
                            Image("NullProfile")
                                .resizable()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            WebImage(url: userWrapper.partner?.userProfileURL).placeholder{
                                // MARK: Placeholder Image
                                Image("NullProfile")
                                    .resizable()
                            }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(colorScheme == .light ? Color("Blue") : Color("Sand"), lineWidth: 1))
                                .position(x: 85, y: 85)
                        )
                        .onTapGesture {
                            self.showLightbox = true
                        }
                        .sheet(isPresented: $showLightbox) {
                            VStack {
                                Text("Profile Pictures")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .padding(10)
                                VStack {
                                    Text("@\(user.username)")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    WebImage(url: self.profileURL)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                if let partnerProfileURL = self.userWrapper.partner?.userProfileURL {
                                    VStack {
                                        Text("@\(partnerUsername)")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                        WebImage(url: partnerProfileURL)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                }
                            }
                            .onTapGesture {
                                self.showLightbox = false
                            }
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("@\(userNameStored)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            if partnerUsername != "" {
                                Text("Partner: @\(partnerUsername)")
                            } else {
                                Text("Add your partner in the account menu")
                            }
                        }
                        .padding(.top, 10)
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
                    
                    // Add a button here to allow users to add a new pet
                    Button(action: {
                        self.showPetView.toggle()
                    }, label: {
                        Text("Add Pet +")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("Blue"))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(Color(.white))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color("Blue"), lineWidth: 1))
                    })
                    .fullScreenCover(isPresented: $showPetView) {
                        PetInformationView(userWrapper: userWrapper)
                    }
                    if let pet = self.userWrapper.user.pet {
                        HStack {
                            WebImage(url: userWrapper.pet?.profileImageURL).placeholder{
                                // MARK: Placeholder Image
                                Image("NullProfile")
                                    .resizable()
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .onTapGesture {
                                self.showLightbox = true
                            }
                            .sheet(isPresented: $showLightbox) {
                                VStack {
                                    Text("Dog Picture")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .padding(10)
                                    VStack {
                                        Text(userWrapper.pet?.name ?? "")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                        WebImage(url: self.userWrapper.pet?.profileImageURL)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    }
                                }
                                .onTapGesture {
                                    self.showLightbox = false
                                }
                            }
                            Text("Your Pet: \(pet.name), Breed:\(pet.breed), Weight: \(pet.weight), Birthdate: \(pet.birthDate)")
                                .font(.headline)
                                .foregroundColor(colorScheme == .light ? Color.gray : Color.white)
                                .padding(.top, 10)
                        }
                    } else {
                        Text("No pet information found.")
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .light ? Color.gray : Color.white)
                            .padding(.top, 10)
                    }
                }
                .padding(15)
            }
        }, onRefresh: {
            fetchUserData()
        }).onAppear(perform: fetchUserData)
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
                
                // Fetch user pet data
                if let petArray = data["pet"] as? [[String: Any]], let petData = petArray.first,
                   let petName = petData["name"] as? String,
                   let petBirthDate = petData["birthDate"] as? Timestamp,
                   let petBreed = petData["breed"] as? String,
                   let petWeight = petData["weight"] as? Int,
                   let petProfileURLString = petData["petPicURL"] as? String,
                   let petProfileURL = URL(string: petProfileURLString) {
                    let petModel = PetModel(name: petName, birthDate: petBirthDate.dateValue(), breed: petBreed, profileImageURL: petProfileURL, weight: petWeight)
                    self.userWrapper.pet = petModel
                }
                
                if let url = URL(string: userProfileURL) {
                    self.userWrapper.user = User(id: "", username: username, userUID: userUID, userEmail: userEmail, userProfileURL: url, token: userToken, credits: credits)
                    self.profileURL = url
                    self.userNameStored = username
                } else {
                    let defaultURL = URL(string: "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png")!
                    self.userWrapper.user = User(id: "", username: username, userUID: userUID, userEmail: userEmail, userProfileURL: defaultURL, token: userToken, credits: credits)
                    self.profileURL = defaultURL
                    self.userNameStored = username
                }
                
                if let partnerUID = data["partners"] as? String {
                    db.collection("Users").document(partnerUID).getDocument { (partnerDocument, error) in
                        if let partnerDocument = partnerDocument, partnerDocument.exists, let partnerData = partnerDocument.data(), let partnerUsername = partnerData["username"] as? String, let partnerProfileURL = partnerData["userProfileURL"] as? String, let partnerURL = URL(string: partnerProfileURL),
                           let partnerToken = partnerData["token"] as? String,
                           let partnerCredits = partnerData["credits"] as? Int {
                            // Fetch partner pet data
                            if let partnerPetArray = partnerData["pet"] as? [[String: Any]], let partnerPetData = partnerPetArray.first,
                               let partnerPetName = partnerPetData["name"] as? String,
                               let partnerPetBirthDate = partnerPetData["birthDate"] as? Timestamp,
                               let partnerPetBreed = partnerPetData["breed"] as? String,
                               let partnerPetWeight = partnerPetData["weight"] as? Int,
                               let partnerPetPicURLString = partnerPetData["petPicURL"] as? String,
                               let partnerPetPicURL = URL(string: partnerPetPicURLString) {
                                let partnerPet = PetModel(name: partnerPetName, birthDate: partnerPetBirthDate.dateValue(), breed: partnerPetBreed, profileImageURL: partnerPetPicURL, weight: partnerPetWeight)
                                self.userWrapper.partner?.pet = partnerPet
                            }
                        }
                    }
                } else {
                    self.userWrapper.partner?.pet = nil
                }
                // Fetching current user's pet data
                if let petData = data["pet"] as? [[String: Any]], let currentPetData = petData.first,
                   let petName = currentPetData["name"] as? String,
                   let petBirthDate = currentPetData["birthDate"] as? Timestamp,
                   let petBreed = currentPetData["breed"] as? String,
                   let petWeight = currentPetData["weight"] as? Int,
                   let petPicURLString = currentPetData["petPicURL"] as? String,
                   let petPicURL = URL(string: petPicURLString) {
                    let pet = PetModel(name: petName, birthDate: petBirthDate.dateValue(), breed: petBreed, profileImageURL: petPicURL, weight: petWeight)
                    self.userWrapper.user.pet = pet
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

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
