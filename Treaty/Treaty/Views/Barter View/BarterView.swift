//
//  BarterView.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//
import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI

class UserWrapper: ObservableObject {
    @Published var user: User
    @Published var partner: PartnerModel?
    @Published var pet: PetModel?

    init(user: User) {
        self.user = user
        self.partner = nil
        self.pet = nil
    }
}

let ubuntu = "Ubuntu"
struct BarterView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var userWrapper: UserWrapper
    /// - Animation Properties
    @State private var expandMenu: Bool = false
    @State private var dimContent: Bool = false
    @State private var isLoading = false
    @State private var isSheetViewPresented: Bool = false
    @State private var showNoPartnerAlert: Bool = false
    @State var selectedTransaction: TransactionType = TransactionType(amountSpent: 0, product: "", productIcon: "")
    @StateObject var entryModel: EntryViewModel = EntryViewModel()
    @AppStorage("partnerUsernameStored") var partnerUsernameStored: String = ""
    @AppStorage("partnerUID") var partnerUIDStored: String = ""
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("parnterLinked") var partnerLinked: Bool = false
    
    var user: User
    
    init(userWrapper: UserWrapper) {
        self.userWrapper = userWrapper
        self.user = userWrapper.user
        self.selectedTransaction = types.first!
    }
    
    var body: some View {
        CustomRefreshView(lottieFileName: "Loading", backgroundColor: Color("Blue"), content:  {
            if userNameStored == "" {
                UserNameView()
            } else {
                VStack(spacing: 0){
                    HeaderView()
                    
                    VStack(spacing: 10){
                        Text("My Treat Jar")
                            .font(.custom(ubuntu, size: 30, relativeTo: .title))
                            .foregroundColor(expandMenu ? Color("Blue") : .white)
                            .contentTransition(.interpolate)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .padding(.horizontal,15)
                            .padding(.top,10)
                        
                        CardView()
                        /// - Making it Above the ScrollView
                            .zIndex(1)
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 12){
                                ForEach(types){transactionType in
                                    TransactionCardView(transactionType, selectedTransaction: $selectedTransaction)
                                }
                            }
                            .padding(.top,40)
                            .padding([.horizontal,.bottom],15)
                        }
                        .padding(.top,-20)
                        .zIndex(0)
                    }
                    /// - Moving View Up By Negative Padding
                    .padding(.top,expandMenu ? 10 : -130)
                    /// - Dimming Content
                    .overlay {
                        Rectangle()
                            .fill(.black)
                            .opacity(dimContent ? 0.45 : 0)
                            .ignoresSafeArea()
                    }
                    if isLoading {
                        ActivityIndicator($isLoading, style: .large)
                            .foregroundColor(.gray)
                            .ignoresSafeArea()
                    }
                }
                .frame(maxHeight: .infinity,alignment: .top)
                .background {
                    (colorScheme == .light ? Color("BG") : Color.black)
                        .ignoresSafeArea()
                }
            }
        }, onRefresh: {
            fetchUserData()
        }).onAppear(perform: fetchUserData)
    }
    
    /// - Header View
    @ViewBuilder
    func HeaderView()->some View{
        GeometryReader{
            let size = $0.size
            let offset = (size.height + 200.0) * 0.21
            
            HStack{
                WebImage(url: user.userProfileURL).placeholder{
                    // MARK: Placeholder Imgae
                    Image("NullProfile")
                        .resizable()
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            }
            .padding(10)
        }
        .frame(height: 60)
        .padding(.bottom,expandMenu ? 200 : 130)
        .background {
            Color("Blue")
                .ignoresSafeArea()
        }
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
                if let url = URL(string: userProfileURL) {
                    self.userWrapper.user = User(id: "", username: username, userUID: userUID, userEmail: userEmail, userProfileURL: url, token: userToken, credits: credits)
                    self.userNameStored = username
                } else {
                    let defaultURL = URL(string: "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png")!
                    self.userWrapper.user = User(id: "", username: username, userUID: userUID, userEmail: userEmail, userProfileURL: defaultURL, token: userToken, credits: credits)
                    self.userNameStored = username
                }
                if let partnerUID = data["partners"] as? String {
                    db.collection("Users").document(partnerUID).getDocument { (partnerDocument, error) in
                        if let partnerDocument = partnerDocument, partnerDocument.exists, let partnerData = partnerDocument.data(), let partnerUsername = partnerData["username"] as? String, let partnerProfileURL = partnerData["userProfileURL"] as? String, let partnerURL = URL(string: partnerProfileURL),
                           let partnerToken = partnerData["token"] as? String,
                           let partnerCredits = partnerData["credits"] as? Int
                        {
                            self.userWrapper.partner = PartnerModel(username: partnerUsername, userProfileURL: partnerURL, token: partnerToken, credits: partnerCredits, partnerUID: partnerUID)
                            self.partnerUsernameStored = partnerUsername
                            self.partnerUIDStored = partnerUID
                            self.partnerLinked = true // set partnerLinked to true
                        } else {
                            let defaultPartnerURL = URL(string: "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png")!
                            self.userWrapper.partner = PartnerModel(username: "", userProfileURL: defaultPartnerURL, token: "", credits: 50, partnerUID: partnerUID)
                        }
                    }
                } else {
                    self.userWrapper.partner = nil
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    /// - CardView
    @ViewBuilder
    func CardView()->some View{
        HStack{
            VStack(alignment: .leading, spacing: 10) {
                Text("Total")
                    .font(.custom(ubuntu, size: 16, relativeTo: .body))
                    .foregroundColor(colorScheme == .light ? Color.black : Color("Blue"))
                HStack {
                    Text("\(user.credits)")
                        .font(.custom(ubuntu, size: 40, relativeTo: .largeTitle))
                        .fontWeight(.medium)
                        .foregroundColor(user.credits < 0 ? .red : Color("Blue"))
                    Image("treat")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
            }
            .frame(maxWidth: .infinity,alignment: .leading)
        }
        .padding(15)
        .background(colorScheme == .light ? Color.white : Color("Sand"))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 5, y: 5)
        .padding(.horizontal,15)
    }
    
    /// - Transaction Card View
    @ViewBuilder
    func TransactionCardView(_ transaction: TransactionType, selectedTransaction: Binding<TransactionType>)->some View{
        HStack(spacing: 12){
            Image(transaction.productIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.product)
                    .font(.custom(ubuntu, size: 16, relativeTo: .body))
            }
            .frame(maxWidth: .infinity,alignment: .leading)
            HStack {
                Text("\(transaction.amountSpent)")
                    .font(.custom(ubuntu, size: 18, relativeTo: .title3))
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .light ? Color("Blue") : Color("Sand"))
                Image("treat")
                    .resizable()
                    .frame(width: 18, height: 18)
            }
        }
        .padding(10)
        .background(colorScheme == .light ? Color.white : Color("Blue"))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 5, y: 5)
        .onTapGesture {
            if self.partnerUIDStored.isEmpty {
                self.showNoPartnerAlert.toggle()
            } else {
                self.$selectedTransaction.wrappedValue = transaction
                self.isSheetViewPresented.toggle()
            }
        }
        .sheet(isPresented: $isSheetViewPresented, onDismiss: {
            self.isSheetViewPresented = false
        }) {
            PartnerTradeView(userWrapper: userWrapper, selectedTransaction: self.$selectedTransaction).environmentObject(entryModel)
        }
        .alert(isPresented: $showNoPartnerAlert) {
            Alert(title: Text("No Partner Linked"), message: Text("Please set a partner in the Profile menu"), dismissButton: .default(Text("Thanks!")))
        }
    }
}

     
    /// - Custom Extension to avoid Redundant Codes
    extension View{
        @ViewBuilder
        fileprivate func menuTitleView(_ size: CGSize,_ title: String,_ offset: CGFloat,_ condition: Bool,onTap: @escaping ()->())->some View{
            self
            /// - Hiding the line, when expanded
                .foregroundColor(condition ? .clear : .white)
                .contentTransition(.interpolate)
                .frame(width: size.width, height: size.height)
                .background(alignment: .topLeading) {
                    Text(title)
                        .font(.custom(ubuntu, size: 25, relativeTo: .title))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 100,alignment: .leading)
                        .scaleEffect(condition ? 1 : 0.01, anchor: .topLeading)
                        .offset(y: condition ? -6 : 0)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: onTap)
                }
                .offset(x: condition ? 40 : 0,y: condition ? offset : 0)
        }
    }
