//
//  PetInformationView.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/19/23.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import Firebase
struct PetInformationView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var userWrapper: UserWrapper
    @Environment(\.colorScheme) private var colorScheme
    
    let dogBreeds = ["Affenpinscher", "Afghan Hound", "Aidi", "Airedale Terrier", "Akbash Dog", "Akita", "Alaskan Husky", "Alaskan Klee Kai", "Alaskan Malamute", "American Bulldog", "American Bully", "American Cocker Spaniel", "American Eskimo Dog", "American Foxhound", "American Hairless Terrier", "American Leopard Hound", "American Pit Bull Terrier", "American Staffordshire Terrier", "American Water Spaniel", "Anatolian Shepherd Dog", "Australian Cattle Dog", "Australian Kelpie", "Australian Shepherd", "Australian Terrier", "Barbet", "Basenji", "Basset Hound", "Beagle", "Bearded Collie", "Beauceron", "Bedlington Terrier", "Belgian Sheepdog-Malinois", "Belgian Sheepdog-Tervuren", "Bernese Mountain Dog", "Bichon Frise", "Black & Tan Coonhound", "Black Mouth Cur", "Black Russian Terrier", "Bloodhound", "Bluetick Coonhound", "Border Collie", "Border Terrier", "Borzoi", "Boston Terrier", "Bouvier Des Flandres", "Boykin Spaniel", "Boxer", "Briard", "Brittany", "Brussels Griffon", "Bull Terrier", "Bulldog", "Bullmastiff", "Cairn Terrier", "Canaan Dog", "Cane Corso", "Cardigan Welsh Corgi", "Carolina Dog", "Catahoula Leopard Dog", "Cavalier King Charles Spaniel", "Chesapeake Bay Retriever", "Chihuahua", "Chinese Crested", "Chinese Shar-Pei", "Chow Chow", "Clumber Spaniel", "Collie", "Coton de Tulear", "Curly Coated Retriever", "Dachshund, Miniature", "Dachshund, Standard", "Dalmatian", "Dandie Dinmont Terrier", "Danish-Swedish Farmdog", "Doberman Pinscher", "Dogo Argentino", "Dutch Shepherd", "English Bulldog", "English Cocker Spaniel", "English Coonhound", "English Foxhound", "English Setter", "English Shepherd", "English Springer Spaniel", "English Toy Spaniel", "Field Spaniel", "Finnish Spitz", "Flat Coated Retriever", "French Bulldog", "German Longhaired Pointer", "German Pinscher", "German Shepherd Dog", "German Shorthaired Pointer", "German Wirehaired Pointer", "Giant Schnauzer", "Glen of Imaal Terrier", "Golden Retriever", "Gordon Setter", "Great Dane", "Great Pyrenees", "Greater Swiss Mountain Dog", "Greyhound", "Harrier", "Havanese", "Ibizan Hound", "Irish Setter", "Irish Terrier", "Irish Water Spaniel", "Irish Wolfhound", "Italian Greyhound", "Jack Russell Terrier", "Japanese Chin", "Kangal", "Keeshond", "Kerry Blue Terrier", "Komondor", "Kuvasz", "Labrador Retriever", "Lakeland Terrier", "Lhasa Apso", "Maltese", "Manchester Terrier (Standard)", "Manchester Terrier (Toy)", "Mastiff", "Miniature Bull Terrier", "Miniature Pinscher", "Neapolitan Mastiff", "Nederlandse Kooikerhondje", "Newfoundland", "Norfolk Terrier", "Norrbottenspets", "Norwegian Elkhound", "Nova Scotia Duck Tolling Retriever", "Old English Sheepdog", "Olde English Bulldogge", "Otterhound", "Papillon", "Parson Russell Terrier", "Patterdale Terrier", "Pekingese", "Pembroke Welsh Corgi", "Perro de Presa Canario", "Peruvian Inca Orchid", "Petit Basset Griffon Vendeen", "Pharaoh Hound", "Plott Hound", "Pointer", "Polish Lowland Sheepdog", "Pomeranian", "Poodle Toy", "Poodle, Miniature", "Poodle, Standard", "Portuguese Water Dog", "Pug", "Puli", "Pumi", "Rat Terrier", "Redbone Coonhound", "Rhodesian Ridgeback", "Rottweiler", "Saint Bernard", "Saluki", "Samoyed", "Schapendoes", "Schipperke", "Schnauzer, Standard", "Scottish Deerhound", "Scottish Terrier", "Sealyham Terrier", "Shetland Sheepdog", "Shiba Inu", "Shih Tzu", "Siberian Husky", "Silky Terrier", "Skye Terrier", "Smooth Fox Terrier", "Spinone Italiano", "Staffordshire Bull Terrier", "Sussex Spaniel", "Tibetan Mastiff", "Tibetan Spaniel", "Tibetan Terrier", "Toy Fox Terrier", "Treeing Tennessee Brindle", "Treeing Walker Coonhound", "Vizsla", "Weimaraner", "Welsh Springer Spaniel", "Welsh Terrier", "West Highland White Terrier", "Wheaten Terrier, Soft-Coated", "Whippet", "Wire Fox Terrier", "Wirehaired Pointing Griffon", "Yorkshire Terrier"]
    @State private var selectedBreedIndex = 0
    @State private var selectedBreedName: String = ""
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var weight: Int = 0
    @State private var birthDate = Date()
    @State private var pet: PetModel?

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
                    Picker("Pet's Breed", selection: $selectedBreedName) {
                        ForEach(dogBreeds, id: \.self) { breed in
                            Text(breed)
                        }
                    }
                } header: {
                    Text("Pet's Breed")
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                }
                
                Section {
                    DatePicker("", selection: $birthDate)
                        .datePickerStyle(.graphical)
                } header: {
                    Text("Pet's Birth Date")
                        .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
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
                }
            }
        }
    }
    
    func save() {
        let uid = user.userUID
        
        let petData: [String: Any] = [
            "name": name,
            "breed": selectedBreedName,
            "birthDate": birthDate,
            "weight": weight
        ]
        
        let userRef = Firestore.firestore().collection("Users").document(uid)
        
        userRef.updateData([
            "pet": FieldValue.arrayUnion([petData])
        ]) { error in
            if let error = error {
                print("Error saving pet data: \(error.localizedDescription)")
            } else {
                dismiss()
            }
        }
    }
}
