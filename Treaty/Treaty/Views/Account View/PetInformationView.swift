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
    @State private var allBreeds: [String] = []
    @State private var breeds: [Breed] = []
    @State private var selectedBreedIndex = 0
    @State var isLoading: Bool = false
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
        allBreeds[selectedBreedIndex]
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
                    if allBreeds.isEmpty {
                        LoadingView(show: $isLoading)
                    } else {
                        Picker("Pet's Breed", selection: $selectedBreedIndex) {
                            ForEach(0..<allBreeds.count) { index in
                                Text(allBreeds[index])
                            }
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
        .onAppear {
            fetchBreeds()
        }
    }
    
    func save() {
        let uid = user.userUID
        
        let petData: [String: Any] = [
            "name": name,
            "breed": breed,
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
    
    func fetchBreeds() {
        isLoading = true
        guard let url = URL(string: "https://api.thedogapi.com/v1/breeds?limit=10&page=0") else {
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Breed].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching breeds: \(error.localizedDescription)")
                case .finished:
                    break
                }
                isLoading = false
            }, receiveValue: { [weak self] breeds in
                self?.breeds = breeds
            })
            .store(in: &cancellables)
    }
}

struct BreedsResponse: Codable {
    let message: [String: [String]]
    let status: String
    
}
