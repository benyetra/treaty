//
//  PetInformationView.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/19/23.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import FirebaseStorage
import Firebase
import PhotosUI

struct PetInformationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var userWrapper: UserWrapper
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedBreedIndex = 0
    @State private var selectedBreedName: String = ""
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var weight: Int = 0
    @State private var birthDate = Date()
    @State private var pet: PetModel?
    @State private var showImagePicker: Bool = false
    @State var petProfilePicData: Data?
    @State var photoItem: PhotosPickerItem?
    @State private var showBreedScrollView: Bool = false
    @AppStorage("parnterLinked") var partnerLinked: Bool = false
    @State var selectBreed: String?
    @State var isLoading: Bool = false

    var user: User
    
    init(userWrapper: UserWrapper) {
        self.userWrapper = userWrapper
        self.user = userWrapper.user
    }
    
    var body: some View {
        NavigationView{
            List{
                Section {
                    HStack {
                        TextField("Pet's Name", text: $name)
                            .textContentType(.nickname)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                } header: {
                    Text("Pet's Name")
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                }
                
                Section {
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            VStack {
                                ZStack {
                                    if let petProfilePicData, let image = UIImage(data: petProfilePicData) {
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
                                Text("Tap to add a picture")
                                    .font(.footnote)
                                    .foregroundColor(Color.gray)
                                    .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.height * 0.5)
                            .offset(y: -geometry.size.height * 0.25)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 55)
                    .padding(.horizontal, 40)
                } header: {
                    Text("Pet's Picture")
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                }
                
                Section {
                    Button(action: {
                        showBreedScrollView.toggle()
                    }, label: {
                        Text(selectedBreedName.isEmpty ? "Breed" : selectedBreedName)
                            .foregroundColor(selectedBreedName.isEmpty ? Color.gray : .primary)
                    })
                    .sheet(isPresented: $showBreedScrollView, onDismiss: {
                        selectedBreedName = selectBreed ?? "" // update the selected breed name after dismissing the sheet
                    }, content: {
                        BreedScrollView(selectBreed: $selectBreed) // pass the binding variable to the sheet
                    })
                }
                
                Section {
                    DatePicker("", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                } header: {
                    Text("Pet's Birth Date")
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                }
                .onAppear {
                    let calendar = Calendar.current
                    let dateComponents = calendar.dateComponents([.year, .month, .day], from: birthDate)
                    birthDate = calendar.date(from: dateComponents)!
                }
                
                Section {
                    Picker("Pet's Current Weight", selection: $weight) {
                        ForEach(1...200, id: \.self) { pounds in
                            Text("\(pounds) lbs")
                        }
                    }
                    .pickerStyle(.wheel)
                } header: {
                    Text("Pet's Current Weight")
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                }
            }
            .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
            .onChange(of: photoItem) { newValue in
                // MARK: Extracting UIImage From PhotoItem
                if let newValue{
                    Task{
                        do{
                            guard let imageData = try await newValue.loadTransferable(type: Data.self) else{return}
                            // MARK: UI Must Be Updated on Main Thread
                            await MainActor.run(body: {
                                petProfilePicData = imageData
                            })
                            
                        }catch{}
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Pet Information")
            .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
            .navigationBarTitleDisplayMode(.inline)
            // MARK: Disabling Dismiss on Swipe
            .interactiveDismissDisabled()
            // MARK: Action Buttons
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel"){
                        dismiss()
                    }.foregroundColor(Color.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save"){
                        save()
                        isLoading = true
                    }
                    .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                    .disableWithOpacity(name == "" || self.selectedBreedName.isEmpty || weight == 0 || petProfilePicData == nil)
                }
            }
            .overlay {
                LoadingView(show: $isLoading)
            }
        }
    }
    
    func save() {
        Task {
            do {
                guard let userUID = Auth.auth().currentUser?.uid else {
                    return
                }
                
                guard let imageData = petProfilePicData else {
                    return
                }
                
                let storageRef = Storage.storage().reference().child("Pet_Images").child(userUID)
                let _ = try await storageRef.putDataAsync(imageData)
                
                // Step 3: Downloading Photo URL
                let downloadURL = try await storageRef.downloadURL()
                let birthTimestamp = Timestamp(date: birthDate)
                let petData: [String: Any] = [
                    "name": name,
                    "breed": selectedBreedName,
                    "birthDate": birthTimestamp,
                    "weight": weight,
                    "petPicURL": downloadURL.absoluteString
                ]
                
                let userRef = Firestore.firestore().collection("Users").document(userUID)
                
                userRef.updateData([
                    "pet": FieldValue.arrayUnion([petData])
                ]) { error in
                    if let error = error {
                        // Handle error
                        print(error.localizedDescription)
                    } else {
                        // Check if pet is linked to partner
                        if partnerLinked == true {
                            let partnerRef = Firestore.firestore().collection("Users").document(userWrapper.partner!.partnerUID)
                            partnerRef.updateData([
                                "pet": FieldValue.arrayUnion([petData])
                            ])
                        }
                        dismiss()
                    }
                }
            } catch {
                // Handle error
                print(error.localizedDescription)
            }
        }
    }
}
