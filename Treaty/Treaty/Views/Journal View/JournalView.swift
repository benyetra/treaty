//
//  JournalView.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/2/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct JournalView: View {
    var basedOnUID: Bool = false
    var uid: String = ""
    @StateObject var entryModel: EntryViewModel = EntryViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Namespace var animation
    @ObservedObject var userWrapper: UserWrapper
    
    /// - Animation Properties
    @State var errorMessage: String = ""
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var currentDate: Date = Date()
    @State private var currentWeek: [Date] = []
    @State private var selectedDate: Date = Date()
    @State private var expandMenu: Bool = false
    @State private var dimContent: Bool = false
    @State private var isShowingDatePicker: Bool = false
    @AppStorage("filter") var filter: String?
    @AppStorage("user_UID") var userUID: String = ""

    var user: User
    
    init(userWrapper: UserWrapper) {
        self.userWrapper = userWrapper
        self.user = userWrapper.user
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                HeaderView()
            }
            CustomRefreshView(lottieFileName: "Loading", backgroundColor: Color(.clear), content:  {
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(spacing: 20){
                        
                        // Custom Date Picker....
                        CustomDatePicker(userWrapper: userWrapper)
                    }
                    .padding(.vertical)
                }
                // Safe Area View...
                .safeAreaInset(edge: .bottom) {
                    
                    HStack{
                        Button {
                            entryModel.addNewTask.toggle()
                        } label: {
                            Text("Add New Task")
                                .fontWeight(.bold)
                                .padding(.vertical)
                                .frame(maxWidth: .infinity)
                                .background(Color("Blue"),in: Capsule())
                        }
                        .sheet(isPresented: $entryModel.addNewTask) {
                        } content: {
                            NewEntry(userWrapper: userWrapper)
                                .environmentObject(entryModel)
                                .onAppear {
                                    MainView().fetchUserData()
                                }
                        }
                        Button {
                            entryModel.addNewBathroomRecord.toggle()
                        } label: {
                            Text("Bathroom Break")
                                .fontWeight(.bold)
                                .padding(.vertical)
                                .frame(maxWidth: .infinity)
                                .background(Color("Sand"),in: Capsule())
                        }
                        .sheet(isPresented: $entryModel.addNewBathroomRecord) {
                        } content: {
                            NewBathroomRecord(userWrapper: userWrapper)
                                .environmentObject(entryModel)
                                .onAppear {
                                    MainView().fetchUserData()
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top,10)
                    .padding(.bottom,10)
                    .foregroundColor(.white)
                    .background(.ultraThinMaterial)
                }
            }, onRefresh: {
                entryModel.filterTodayEntries(userUID: user.userUID, filter: self.filter ?? "both")
            })
        }
        .navigationTitle("Journal")
        .overlay {
            LoadingView(show: $isLoading)
        }
        .alert(errorMessage, isPresented: $showError) {
        }
    }
    
    @ViewBuilder
    func HeaderView()->some View{
        GeometryReader{
            let size = $0.size
            let offset = (size.height + 200.0) * 0.21
            
            HStack{
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .menuTitleView(CGSize(width: 70, height: 2),"Mine", offset, expandMenu){
                            self.filter = "currentUser"
                            entryModel.filterTodayEntries(userUID: userUID, filter: self.filter ?? "both")
                            animateMenu()
                        }.foregroundColor(self.filter == "currentUser" ? .orange : .primary)

                    
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .menuTitleView(CGSize(width: 45, height: 2),"Partner's", (offset * 2), expandMenu){
                            self.filter = "partnerUser"
                            entryModel.filterTodayEntries(userUID: userUID, filter: self.filter ?? "both")
                            animateMenu()
                        }.foregroundColor(self.filter == "partnerUser" ? .orange : .primary)
                    
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .menuTitleView(CGSize(width: 40, height: 2),"All", (offset * 3), expandMenu){
                            self.filter = "both"
                            entryModel.filterTodayEntries(userUID: userUID, filter: self.filter ?? "both")
                            animateMenu()
                        }.foregroundColor(self.filter == "both" ? .orange : .primary)
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
                NavigationLink(destination: AccountView(userWrapper: userWrapper)) {
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
        .frame(height: 20)
        .padding(.bottom,expandMenu ? 200 : 50)
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
                    .frame(width: 100,alignment: .leading)
                    .scaleEffect(condition ? 1 : 0.01, anchor: .topLeading)
                    .offset(y: condition ? -6 : 0)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onTap)
            }
            .offset(x: condition ? 40 : 0,y: condition ? offset : 0)
    }
}
