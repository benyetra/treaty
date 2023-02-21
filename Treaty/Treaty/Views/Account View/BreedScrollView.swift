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
    @State var characters: [CharacterModel] = []
    @State var scrollerHeight: CGFloat = 0
    @State var indicatorOffset: CGFloat = 0
    // MARK: View's Start Offset After The Navigation Bar
    @State var startOffset: CGFloat = 0
    @State var hideIndicatorLabel: Bool = true
    
    // MARK: ScrollView EndDeclaration Properties
    // Your Own Timing
    @State var timeOut: CGFloat = 0.3
    let dogBreeds = ["Affenpinscher", "Afghan Hound", "Aidi", "Airedale Terrier", "Akbash Dog", "Akita", "Alaskan Husky", "Alaskan Klee Kai", "Alaskan Malamute", "American Bulldog", "American Bully", "American Cocker Spaniel", "American Eskimo Dog", "American Foxhound", "American Hairless Terrier", "American Leopard Hound", "American Pit Bull Terrier", "American Staffordshire Terrier", "American Water Spaniel", "Anatolian Shepherd Dog", "Australian Cattle Dog", "Australian Kelpie", "Australian Shepherd", "Australian Terrier", "Barbet", "Basenji", "Basset Hound", "Beagle", "Bearded Collie", "Beauceron", "Bedlington Terrier", "Belgian Sheepdog-Malinois", "Belgian Sheepdog-Tervuren", "Bernedoodle", "Bernese Mountain Dog", "Bichon Frise", "Black & Tan Coonhound", "Black Mouth Cur", "Black Russian Terrier", "Bloodhound", "Bluetick Coonhound", "Border Collie", "Border Terrier", "Borzoi", "Boston Terrier", "Bouvier Des Flandres", "Boykin Spaniel", "Boxer", "Briard", "Brittany", "Brussels Griffon", "Bull Terrier", "Bulldog", "Bullmastiff", "Cairn Terrier", "Canaan Dog", "Cane Corso", "Cardigan Welsh Corgi", "Carolina Dog", "Catahoula Leopard Dog", "Cavalier King Charles Spaniel", "Chesapeake Bay Retriever", "Chihuahua", "Chinese Crested", "Chinese Shar-Pei", "Chow Chow", "Clumber Spaniel", "Collie", "Coton de Tulear", "Curly Coated Retriever", "Dachshund, Miniature", "Dachshund, Standard", "Dalmatian", "Dandie Dinmont Terrier", "Danish-Swedish Farmdog", "Doberman Pinscher", "Dogo Argentino", "Dutch Shepherd", "English Bulldog", "English Cocker Spaniel", "English Coonhound", "English Foxhound", "English Setter", "English Shepherd", "English Springer Spaniel", "English Toy Spaniel", "Field Spaniel", "Finnish Spitz", "Flat Coated Retriever", "French Bulldog", "German Longhaired Pointer", "German Pinscher", "German Shepherd Dog", "German Shorthaired Pointer", "German Wirehaired Pointer", "Giant Schnauzer", "Glen of Imaal Terrier", "Golden Retriever", "Gordon Setter", "Great Dane", "Great Pyrenees", "Greater Swiss Mountain Dog", "Greyhound", "Harrier", "Havanese", "Ibizan Hound", "Irish Setter", "Irish Terrier", "Irish Water Spaniel", "Irish Wolfhound", "Italian Greyhound", "Jack Russell Terrier", "Japanese Chin", "Kangal", "Keeshond", "Kerry Blue Terrier", "Komondor", "Kuvasz", "Labrador Retriever", "Lakeland Terrier", "Lhasa Apso", "Maltese", "Manchester Terrier (Standard)", "Manchester Terrier (Toy)", "Mastiff", "Miniature Bull Terrier", "Miniature Pinscher", "Neapolitan Mastiff", "Nederlandse Kooikerhondje", "Newfoundland", "Norfolk Terrier", "Norrbottenspets", "Norwegian Elkhound", "Nova Scotia Duck Tolling Retriever", "Old English Sheepdog", "Olde English Bulldogge", "Otterhound", "Papillon", "Parson Russell Terrier", "Patterdale Terrier", "Pekingese", "Pembroke Welsh Corgi", "Perro de Presa Canario", "Peruvian Inca Orchid", "Petit Basset Griffon Vendeen", "Pharaoh Hound", "Plott Hound", "Pointer", "Polish Lowland Sheepdog", "Pomeranian", "Poodle Toy", "Poodle, Miniature", "Poodle, Standard", "Portuguese Water Dog", "Pug", "Puli", "Pumi", "Rat Terrier", "Redbone Coonhound", "Rhodesian Ridgeback", "Rottweiler", "Saint Bernard", "Saluki", "Samoyed", "Schapendoes", "Schipperke", "Schnauzer, Standard", "Scottish Deerhound", "Scottish Terrier", "Sealyham Terrier", "Shetland Sheepdog", "Shiba Inu", "Shih Tzu", "Siberian Husky", "Silky Terrier", "Skye Terrier", "Smooth Fox Terrier", "Spinone Italiano", "Staffordshire Bull Terrier", "Sussex Spaniel", "Tibetan Mastiff", "Tibetan Spaniel", "Tibetan Terrier", "Toy Fox Terrier", "Treeing Tennessee Brindle", "Treeing Walker Coonhound", "Vizsla", "Weimaraner", "Welsh Springer Spaniel", "Welsh Terrier", "West Highland White Terrier", "Wheaten Terrier, Soft-Coated", "Whippet", "Wire Fox Terrier", "Wirehaired Pointing Griffon", "Yorkshire Terrier"]
    @State private var selectedBreedIndex = 0
    @State private var selectedBreedName: String = ""
    @State private var name: String = ""
    @State private var breed: String = ""
    
    @State var currentCharacter: CharacterModel = .init(value: "")
    var body: some View {
        NavigationView{
            GeometryReader{
                let size = $0.size
                
                ScrollViewReader(content: { proxy in
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 0){
                            // MARK: Sample Contacts View
                            ForEach(characters){character in
                                ContactsForCharacter(character: character)
                                    .id(character.index)
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel"){
                                    dismiss()
                                }.foregroundColor(Color.red)
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Save"){
                                    print("saved")
                                }
                                .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
//                                .disabled(self.selectedUsers.isEmpty || self.selectedType == "")
                            }
                        }
                        .padding(.top,15)
                        .padding(.trailing,20)
                        .offsets { rect in
                            // MARK: When Ever Scrolling Does
                            // Resetting Timeout
                            if hideIndicatorLabel && rect.minY < 0{
                                timeOut = 0
                                hideIndicatorLabel = false
                            }
                            
                            // MARK: Finding Scroll Indicator height
                            let rectHeight = rect.height
                            let viewHeight = size.height + (startOffset / 2)
                            
                            let scrollerHeight = (viewHeight / rectHeight) * viewHeight
                            self.scrollerHeight = scrollerHeight
                            
                            // MARK: Finding Scroll Indicator Offset
                            let progress = rect.minY / (rectHeight - size.height)
                            // MARK: Simply Multiply With View Height
                            // Eliminating Scroller Height
                            self.indicatorOffset = -progress * (size.height - scrollerHeight)
                        }
                    }
                })
                .frame(maxWidth: .infinity,maxHeight: .infinity)
                .overlay(alignment: .topTrailing, content: {
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 2, height: scrollerHeight)
                        .overlay(alignment: .trailing, content: {
                            // MARK: Bubble Image
                            Image(systemName: "bubble.middle.bottom.fill")
                                .resizable()
                                .renderingMode(.template)
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.ultraThinMaterial)
                                .frame(width: 45, height: 45)
                                .rotationEffect(.init(degrees: -90))
                                .overlay(content: {
                                    Text(currentCharacter.value)
                                        .fontWeight(.black)
                                        .foregroundColor(.white)
                                        .offset(x: -3)
                                })
                                .environment(\.colorScheme, .dark)
                                .offset(x: hideIndicatorLabel || currentCharacter.value == "" ? 65 : 0)
                                .animation(.interactiveSpring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.6), value: hideIndicatorLabel || currentCharacter.value == "")
                        })
                        .padding(.trailing,5)
                        .offset(y: indicatorOffset)
                })
                .coordinateSpace(name: "SCROLLER")
            }
            .navigationTitle("Breed's")
            .offsets { rect in
                if startOffset != rect.minY{
                    startOffset = rect.minY
                }
            }
        }
        .onAppear {
            characters = fetchCharacters()
        }
        // MARK: I'm Going to Implement a Custom ScrollView End Declaration with the help of the Timer And Offset Values
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()) { _ in
            if timeOut < 0.3{
                timeOut += 0.01
            }else{
                // MARK: Scrolling is Finished
                // It Will Fire Many Times So Use Some Conditions Here
                if !hideIndicatorLabel{
                    print("Scrolling is Finished")
                    hideIndicatorLabel = true
                }
            }
        }
    }
    
    // MARK: Contact Row For Each Alphabet
    @ViewBuilder
    func ContactsForCharacter(character: CharacterModel)->some View{
        VStack(alignment: .leading, spacing: 15) {
            Text(character.value)
                .font(.largeTitle.bold())
            
            ForEach(1...4,id: \.self){_ in
                HStack(spacing: 10){
                    Circle()
                        .fill(character.color)
                        .frame(width: 45, height: 45)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(character.color.opacity(0.6))
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(character.color.opacity(0.4))
                            .frame(height: 20)
                            .padding(.trailing,80)
                    }
                }
            }
        }
        .offsets(completion: { rect in
            // MARK: Verifying Which section is at the Top (Near NavBar)
            // Updating Character Rect When ever it's Updated
            if characters.indices.contains(character.index){
                characters[character.index].rect = rect
            }
            
            // Since Every Character moves up and goes beyond Zero (It will be like A,B,C,D)
            // So We're taking the last character
            if let last = characters.last(where: { char in
                char.rect.minY < 0
            }),last.id != currentCharacter.id{
                currentCharacter = last
                print(currentCharacter.value)
            }
        })
        .padding(15)
    }
    
    // MARK: Fetching Characters
    func fetchCharacters()->[CharacterModel]{
        let alphabets: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        var characters: [CharacterModel] = []
        
        characters = alphabets.compactMap({ character -> CharacterModel? in
            return CharacterModel(value: String(character))
        })
        
        // MARK: Sample Color's
        let colors: [Color] = [.red,.yellow,.pink,.orange,.cyan,.indigo,.purple,.blue]
        
        // MARK: Setting Index And Random Color
        for index in characters.indices{
            characters[index].index = index
            characters[index].color = colors.randomElement()!
        }
        
        return characters
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: Offset Reader
extension View{
    @ViewBuilder
    func offsets(completion: @escaping (CGRect)->())->some View{
        self
            .overlay {
                GeometryReader{
                    let rect = $0.frame(in: .named("SCROLLER"))
                    Color.clear
                        .preference(key: OffsetsKey.self, value: rect)
                        .onPreferenceChange(OffsetsKey.self) { value in
                            completion(value)
                        }
                }
            }
    }
}

// MARK: Offset Key
struct OffsetsKey:PreferenceKey{
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
