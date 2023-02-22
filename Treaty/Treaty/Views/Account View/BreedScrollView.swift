//
//  BreedScrollView.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/21/23.
//

import SwiftUI

struct BreedScrollView: View {
    // MARK: View Properties
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State var dogBreeds: [Breed] = []
    @State private var selectedBreedIndex: Int? = nil
    @State private var selectedBreedName: String = ""
    @State private var name: String = ""
    @State private var breed: String = ""
    @State var currentCharacter: Breed = .init(value: "")
    @Binding var selectBreed: String?
    
    let dogs = ["Affenpinscher", "Afghan Hound", "Aidi", "Airedale Terrier", "Akbash Dog", "Akita", "Alaskan Husky", "Alaskan Klee Kai", "Alaskan Malamute", "American Bulldog", "American Bully", "American Cocker Spaniel", "American Eskimo Dog", "American Foxhound", "American Hairless Terrier", "American Leopard Hound", "American Pit Bull Terrier", "American Staffordshire Terrier", "American Water Spaniel", "Anatolian Shepherd Dog", "Australian Cattle Dog", "Australian Kelpie", "Australian Shepherd", "Australian Terrier", "Barbet", "Basenji", "Basset Hound", "Beagle", "Bearded Collie", "Beauceron", "Bedlington Terrier", "Belgian Sheepdog-Malinois", "Belgian Sheepdog-Tervuren", "Bernedoodle", "Bernese Mountain Dog", "Bichon Frise", "Black & Tan Coonhound", "Black Mouth Cur", "Black Russian Terrier", "Bloodhound", "Bluetick Coonhound", "Border Collie", "Border Terrier", "Borzoi", "Boston Terrier", "Bouvier Des Flandres", "Boykin Spaniel", "Boxer", "Briard", "Brittany", "Brussels Griffon", "Bull Terrier", "Bulldog", "Bullmastiff", "Cairn Terrier", "Canaan Dog", "Cane Corso", "Cardigan Welsh Corgi", "Carolina Dog", "Catahoula Leopard Dog", "Cavalier King Charles Spaniel", "Chesapeake Bay Retriever", "Chihuahua", "Chinese Crested", "Chinese Shar-Pei", "Chow Chow", "Clumber Spaniel", "Collie", "Coton de Tulear", "Curly Coated Retriever", "Dachshund, Miniature", "Dachshund, Standard", "Dalmatian", "Dandie Dinmont Terrier", "Danish-Swedish Farmdog", "Doberman Pinscher", "Dogo Argentino", "Dutch Shepherd", "English Bulldog", "English Cocker Spaniel", "English Coonhound", "English Foxhound", "English Setter", "English Shepherd", "English Springer Spaniel", "English Toy Spaniel", "Field Spaniel", "Finnish Spitz", "Flat Coated Retriever", "French Bulldog", "German Longhaired Pointer", "German Pinscher", "German Shepherd Dog", "German Shorthaired Pointer", "German Wirehaired Pointer", "Giant Schnauzer", "Glen of Imaal Terrier", "Golden Retriever", "Gordon Setter", "Great Dane", "Great Pyrenees", "Greater Swiss Mountain Dog", "Greyhound", "Harrier", "Havanese", "Ibizan Hound", "Irish Setter", "Irish Terrier", "Irish Water Spaniel", "Irish Wolfhound", "Italian Greyhound", "Jack Russell Terrier", "Japanese Chin", "Kangal", "Keeshond", "Kerry Blue Terrier", "Komondor", "Kuvasz", "Labrador Retriever", "Lakeland Terrier", "Lhasa Apso", "Maltese", "Manchester Terrier (Standard)", "Manchester Terrier (Toy)", "Mastiff", "Miniature Bull Terrier", "Miniature Pinscher", "Neapolitan Mastiff", "Nederlandse Kooikerhondje", "Newfoundland", "Norfolk Terrier", "Norrbottenspets", "Norwegian Elkhound", "Nova Scotia Duck Tolling Retriever", "Old English Sheepdog", "Olde English Bulldogge", "Otterhound", "Papillon", "Parson Russell Terrier", "Patterdale Terrier", "Pekingese", "Pembroke Welsh Corgi", "Perro de Presa Canario", "Peruvian Inca Orchid", "Petit Basset Griffon Vendeen", "Pharaoh Hound", "Plott Hound", "Pointer", "Polish Lowland Sheepdog", "Pomeranian", "Poodle Toy", "Poodle, Miniature", "Poodle, Standard", "Portuguese Water Dog", "Pug", "Puli", "Pumi", "Rat Terrier", "Redbone Coonhound", "Rhodesian Ridgeback", "Rottweiler", "Saint Bernard", "Saluki", "Samoyed", "Schapendoes", "Schipperke", "Schnauzer, Standard", "Scottish Deerhound", "Scottish Terrier", "Sealyham Terrier", "Shetland Sheepdog", "Shiba Inu", "Shih Tzu", "Siberian Husky", "Silky Terrier", "Skye Terrier", "Smooth Fox Terrier", "Spinone Italiano", "Staffordshire Bull Terrier", "Sussex Spaniel", "Tibetan Mastiff", "Tibetan Spaniel", "Tibetan Terrier", "Toy Fox Terrier", "Treeing Tennessee Brindle", "Treeing Walker Coonhound", "Vizsla", "Weimaraner", "Welsh Springer Spaniel", "Welsh Terrier", "West Highland White Terrier", "Wheaten Terrier, Soft-Coated", "Whippet", "Wire Fox Terrier", "Wirehaired Pointing Griffon", "Yorkshire Terrier"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(dogs.sorted(), id: \.self) { dog in
                        if isFirstDogWithLetter(dog) {
                            Text(String(dog.prefix(1)))
                                .font(.system(size: 30, weight: .bold))
                                .padding(.leading, 16)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                            Divider()
                        }
                        HStack {
                            Text(dog)
                                .font(.system(size: 25))
                                .foregroundColor(selectedBreedName == dog ? .blue : .primary)
                                .onTapGesture {
                                    selectBreed(dog)
                                }
                                .padding(.leading, 16)
                                .padding(.trailing, 16)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if selectedBreedName == dog {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .padding(.trailing, 16)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Dog Breeds")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        print("save \(self.selectedBreedName)")
                        dismiss()
                    }
                    .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                    .disabled(self.selectedBreedName == "")
                }
            }
        }
    }
    
    private func isFirstDogWithLetter(_ dog: String) -> Bool {
        guard let firstDog = dogs.first(where: { $0.prefix(1) == dog.prefix(1) }) else {
            return false
        }
        return firstDog == dog
    }
    
    private func selectBreed(_ dog: String) {
        if let index = dogs.firstIndex(of: dog) {
            if index != selectedBreedIndex {
                selectedBreedIndex = index
                selectedBreedName = dog
                selectBreed = dog // set the selected breed to the binding variable
            } else {
                selectedBreedIndex = nil
                selectedBreedName = ""
                selectBreed = nil // reset the selected breed in the binding variable
            }
        }
    }
}

