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
    
    let dogBreeds = ["Affenpinscher", "Afghan Hound", "Aidi", "Airedale Terrier", "Akbash Dog", "Akita", "Alaskan Husky", "Alaskan Klee Kai", "Alaskan Malamute", "American Bulldog", "American Bully", "American Cocker Spaniel", "American Eskimo Dog", "American Foxhound", "American Hairless Terrier", "American Leopard Hound", "American Pit Bull Terrier", "American Staffordshire Terrier", "American Water Spaniel", "Anatolian Shepherd Dog", "Australian Cattle Dog", "Australian Kelpie", "Australian Shepherd", "Australian Terrier", "Barbet", "Basenji", "Basset Hound", "Beagle", "Bearded Collie", "Beauceron", "Bedlington Terrier", "Belgian Sheepdog-Malinois", "Belgian Sheepdog-Tervuren", "Bernedoodle", "Bernese Mountain Dog", "Bichon Frise", "Black & Tan Coonhound", "Black Mouth Cur", "Black Russian Terrier", "Bloodhound", "Bluetick Coonhound", "Border Collie", "Border Terrier", "Borzoi", "Boston Terrier", "Bouvier Des Flandres", "Boykin Spaniel", "Boxer", "Briard", "Brittany", "Brussels Griffon", "Bull Terrier", "Bulldog", "Bullmastiff", "Cairn Terrier", "Canaan Dog", "Cane Corso", "Cardigan Welsh Corgi", "Carolina Dog", "Catahoula Leopard Dog", "Cavalier King Charles Spaniel", "Chesapeake Bay Retriever", "Chihuahua", "Chinese Crested", "Chinese Shar-Pei", "Chow Chow", "Clumber Spaniel", "Collie", "Coton de Tulear", "Curly Coated Retriever", "Dachshund, Miniature", "Dachshund, Standard", "Dalmatian", "Dandie Dinmont Terrier", "Danish-Swedish Farmdog", "Doberman Pinscher", "Dogo Argentino", "Dutch Shepherd", "English Bulldog", "English Cocker Spaniel", "English Coonhound", "English Foxhound", "English Setter", "English Shepherd", "English Springer Spaniel", "English Toy Spaniel", "Field Spaniel", "Finnish Spitz", "Flat Coated Retriever", "French Bulldog", "German Longhaired Pointer", "German Pinscher", "German Shepherd Dog", "German Shorthaired Pointer", "German Wirehaired Pointer", "Giant Schnauzer", "Glen of Imaal Terrier", "Golden Retriever", "Gordon Setter", "Great Dane", "Great Pyrenees", "Greater Swiss Mountain Dog", "Greyhound", "Harrier", "Havanese", "Ibizan Hound", "Irish Setter", "Irish Terrier", "Irish Water Spaniel", "Irish Wolfhound", "Italian Greyhound", "Jack Russell Terrier", "Japanese Chin", "Kangal", "Keeshond", "Kerry Blue Terrier", "Komondor", "Kuvasz", "Labrador Retriever", "Lakeland Terrier", "Lhasa Apso", "Maltese", "Manchester Terrier (Standard)", "Manchester Terrier (Toy)", "Mastiff", "Miniature Bull Terrier", "Miniature Pinscher", "Neapolitan Mastiff", "Nederlandse Kooikerhondje", "Newfoundland", "Norfolk Terrier", "Norrbottenspets", "Norwegian Elkhound", "Nova Scotia Duck Tolling Retriever", "Old English Sheepdog", "Olde English Bulldogge", "Otterhound", "Papillon", "Parson Russell Terrier", "Patterdale Terrier", "Pekingese", "Pembroke Welsh Corgi", "Perro de Presa Canario", "Peruvian Inca Orchid", "Petit Basset Griffon Vendeen", "Pharaoh Hound", "Plott Hound", "Pointer", "Polish Lowland Sheepdog", "Pomeranian", "Poodle Toy", "Poodle, Miniature", "Poodle, Standard", "Portuguese Water Dog", "Pug", "Puli", "Pumi", "Rat Terrier", "Redbone Coonhound", "Rhodesian Ridgeback", "Rottweiler", "Saint Bernard", "Saluki", "Samoyed", "Schapendoes", "Schipperke", "Schnauzer, Standard", "Scottish Deerhound", "Scottish Terrier", "Sealyham Terrier", "Shetland Sheepdog", "Shiba Inu", "Shih Tzu", "Siberian Husky", "Silky Terrier", "Skye Terrier", "Smooth Fox Terrier", "Spinone Italiano", "Staffordshire Bull Terrier", "Sussex Spaniel", "Tibetan Mastiff", "Tibetan Spaniel", "Tibetan Terrier", "Toy Fox Terrier", "Treeing Tennessee Brindle", "Treeing Walker Coonhound", "Vizsla", "Weimaraner", "Welsh Springer Spaniel", "Welsh Terrier", "West Highland White Terrier", "Wheaten Terrier, Soft-Coated", "Whippet", "Wire Fox Terrier", "Wirehaired Pointing Griffon", "Yorkshire Terrier"]
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

    
    var user: User
    
    init(userWrapper: UserWrapper) {
        self.userWrapper = userWrapper
        self.user = userWrapper.user
    }
    
    var selectedBreed: String {
        dogBreeds[selectedBreedIndex]
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
                    Button {
                        showBreedScrollView.toggle()
                    } label: {
                        Text("Dog Breed")
                            .foregroundColor(Color("Blue"))
                            .fontWeight(.bold)
                            .padding(.vertical)
                            .frame(maxWidth: .infinity)
                            .background(Color("Sand"),in: Capsule())
                    }
                    .fullScreenCover(isPresented: $showBreedScrollView) {
                    } content: {
                        BreedScrollView()
                    }
                } header: {
                    Text("Pet's Breed")
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
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
                    }
                    .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                    .disableWithOpacity(name == "" || selectedBreedName == "" || birthDate == nil || weight == 0 || petProfilePicData == nil)
                }
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
