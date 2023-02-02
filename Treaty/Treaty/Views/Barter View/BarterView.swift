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

    init(user: User) {
        self.user = user
        self.partner = nil
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
    @AppStorage("partnerUsernameStored") var partnerUsernameStored: String = ""

    var user: User
    
    init(userWrapper: UserWrapper) {
        self.userWrapper = userWrapper
        self.user = userWrapper.user
    }
    
    var body: some View {
        CustomRefreshView(lottieFileName: "Loading", backgroundColor: Color("Blue"), content:  {
            if userWrapper.user.username.isEmpty {
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
                                    TransactionCardView(transactionType)
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
        })
    }

    /// - Header View
    @ViewBuilder
    func HeaderView()->some View{
            GeometryReader{
                let size = $0.size
                let offset = (size.height + 200.0) * 0.21
                
                HStack{
                    VStack(alignment: .leading, spacing: 4) {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .menuTitleView(CGSize(width: 15, height: 2),"Gave", offset, expandMenu){
                                print("Tapped Gave")
                            }
                        
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .menuTitleView(CGSize(width: 35, height: 2),"Earned", (offset * 2), expandMenu){
                                print("Tapped Earned")
                            }
                        
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .menuTitleView(CGSize(width: 20, height: 2),"All", (offset * 3), expandMenu){
                                print("Tapped All")
                            }
                    }
                    .hAlign(.leading)
                    .overlay(content: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.white)
                            .scaleEffect(expandMenu ? 1 : 0.001)
                            .rotationEffect(.init(degrees: expandMenu ? 0 : -180))
                            .hAlign(.topLeading)
                    })
                    .overlay(content: {
                        Rectangle()
                            .foregroundColor(.clear)
                            .contentShape(Rectangle())
                            .onTapGesture(perform: animateMenu)
                    })
                    .frame(maxWidth: .infinity,alignment: .leading)
                    
                    Button {
                        
                    } label: {
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
        
        /// - Animating Menu
        func animateMenu(){
            if expandMenu{
                /// - Closing With Little Speed
                withAnimation(.easeInOut(duration: 0.25)){
                    dimContent = false
                }
                
                /// - Dimming Content Little Later
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    withAnimation(.easeInOut(duration: 0.2)){
                        expandMenu = false
                    }
                }
            }else{
                withAnimation(.easeInOut(duration: 0.35)){
                    expandMenu = true
                }
                
                /// - Dimming Content Little Later
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15){
                    withAnimation(.easeInOut(duration: 0.3)){
                        dimContent = true
                    }
                }
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
                } else {
                    let defaultURL = URL(string: "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png")!
                    self.userWrapper.user = User(id: "", username: username, userUID: userUID, userEmail: userEmail, userProfileURL: defaultURL, token: userToken, credits: credits)
                }
                if let partnerUID = data["partners"] as? String {
                    db.collection("Users").document(partnerUID).getDocument { (partnerDocument, error) in
                        if let partnerDocument = partnerDocument, partnerDocument.exists, let partnerData = partnerDocument.data(), let partnerUsername = partnerData["username"] as? String, let partnerProfileURL = partnerData["userProfileURL"] as? String, let partnerURL = URL(string: partnerProfileURL),
                           let partnerToken = partnerData["token"] as? String,
                           let partnerCredits = partnerData["credits"] as? Int
                        {
                            self.userWrapper.partner = PartnerModel(username: partnerUsername, userProfileURL: partnerURL, token: partnerToken, credits: partnerCredits, partnerUID: partnerUID)
                            self.partnerUsernameStored = partnerUsername
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
                        Image("treat")
                            .resizable()
                            .frame(width: 40, height: 40)
                
                        Text("\(user.credits)")
                            .font(.custom(ubuntu, size: 40, relativeTo: .largeTitle))
                            .fontWeight(.medium)
                            .foregroundColor(Color("Blue"))
                    }
                    Text("-25 today")
                        .font(.custom(ubuntu, size: 12, relativeTo: .caption))
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                        .font(.title)
                        .scaleEffect(0.9)
                        .foregroundColor(.white)
                        .frame(width: 55, height: 55)
                        .background(Color("Blue"))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 5, x: 10, y: 10)
                }
            }
            .padding(15)
            .background(colorScheme == .light ? Color.white : Color("Sand"))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 10, x: 5, y: 5)
            .padding(.horizontal,15)
//            .padding(.top,10)
        }
        
        /// - Transaction Card View
        @ViewBuilder
        func TransactionCardView(_ transaction: TransactionType)->some View{
            HStack(spacing: 12){
                Image(transaction.productIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.product)
                        .font(.custom(ubuntu, size: 16, relativeTo: .body))
                    Text("Earned")
                        .font(.custom(ubuntu, size: 12, relativeTo: .caption))
                        .foregroundColor(.gray)
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
