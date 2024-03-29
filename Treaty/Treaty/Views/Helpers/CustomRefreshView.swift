//
//  CustomRefreshView.swift
//  Treaty
//
//  Created by Bennett Yetra on 2/1/23.
//

import SwiftUI
import Lottie

// MARK: Custom View Builder
struct CustomRefreshView<Content: View>: View {
    var backgroundColor: Color
    var content: Content
    var showsIndicator: Bool
    var lottieFileName: String
    // MARK: Async Call Back
    var onRefresh: ()async->()
    init(showsIndicator: Bool = false,lottieFileName: String,backgroundColor: Color,@ViewBuilder content: @escaping ()->Content,onRefresh: @escaping ()async->()){
        self.showsIndicator = showsIndicator
        self.lottieFileName = lottieFileName
        self.backgroundColor = backgroundColor
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    @StateObject var scrollDelegate: ScrollViewModel = .init()
    var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicator) {
            VStack(spacing: 0){
                ResizbaleLottieView(fileName: lottieFileName, isPlaying: $scrollDelegate.isRefreshing)
                    .scaleEffect(scrollDelegate.isEligible ? 1 : 0.001)
                    .animation(.easeInOut(duration: 0.2), value: scrollDelegate.isEligible)
                    .overlay(content: {
                        // MARK: Arrow And Text
                        VStack(spacing: 12){
                            Image(systemName: "arrow.down")
                                .font(.caption.bold())
                                .foregroundColor(Color("Blue"))
                                .rotationEffect(.init(degrees: scrollDelegate.progress * 180))
                                .padding(8)
                                .background(.primary,in: Circle())
                            
                            Text("Pull To Refresh")
                                .font(.caption.bold())
                                .foregroundColor(.primary)
                        }
                        .opacity(scrollDelegate.isEligible ? 0 : 1)
                        .animation(.easeInOut(duration: 0.25), value: scrollDelegate.isEligible)
                    })
                    .frame(height: 150 * scrollDelegate.progress)
                    .opacity(scrollDelegate.progress)
                    .offset(y: scrollDelegate.isEligible ? -(scrollDelegate.contentOffset < 0 ? 0 : scrollDelegate.contentOffset) : -(scrollDelegate.scrollOffset < 0 ? 0 : scrollDelegate.scrollOffset))
                
                content
            }
            .offset(coordinateSpace: "SCROLL") { offset in
                // MARK: Storing Content Offset
                scrollDelegate.contentOffset = offset
                
                // MARK: Stopping The Progress When Its Elgible For Refresh
                if !scrollDelegate.isEligible{
                    var progress = offset / 150
                    progress = (progress < 0 ? 0 : progress)
                    progress = (progress > 1 ? 1 : progress)
                    scrollDelegate.scrollOffset = offset
                    scrollDelegate.progress = progress
                }
                
                if scrollDelegate.isEligible && !scrollDelegate.isRefreshing{
                    scrollDelegate.isRefreshing = true
                    // MARK: Haptic Feedback
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        }
        .coordinateSpace(name: "SCROLL")
        .onAppear(perform: scrollDelegate.addGesture)
        .onDisappear(perform: scrollDelegate.removeGesture)
        .onChange(of: scrollDelegate.isRefreshing) { newValue in
            // MARK: Calling Async Method
            if newValue{
                Task{
                    await onRefresh()
                    // MARK: After Refresh Done Resetting Properties
                    withAnimation(.easeInOut(duration: 0.25)){
                        scrollDelegate.progress = 0
                        scrollDelegate.isEligible = false
                        scrollDelegate.isRefreshing = false
                        scrollDelegate.scrollOffset = 0
                    }
                }
            }
        }
        .background(backgroundColor)
    }
}

// MARK: For Simultanous Pan Gesture
class ScrollViewModel: NSObject,ObservableObject,UIGestureRecognizerDelegate{
    // MARK: Properties
    @Published var isEligible: Bool = false
    @Published var isRefreshing: Bool = false
    // MARK: Offsets and Progress
    @Published var scrollOffset: CGFloat = 0
    @Published var contentOffset: CGFloat = 0
    @Published var progress: CGFloat = 0
    let gestureID: String = UUID().uuidString
    
    // MARK: Since We need to Know when the user Left the Screen to Start Refresh
    // Adding Pan Gesture To UI Main Application Window
    // With Simultaneous Gesture Desture
    // Thus it Wont disturb SwiftUI Scroll's And Gesture's
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: Adding Gesture
    func addGesture(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onGestureChange(gesture:)))
        panGesture.delegate = self
        panGesture.name = gestureID
        rootController().view.addGestureRecognizer(panGesture)
    }
    
    // MARK: Removing When Leaving The View
    func removeGesture(){
        rootController().view.gestureRecognizers?.removeAll(where: { gesture in
            gesture.name == gestureID
        })
    }
    
    // MARK: Finding Root Controller
    func rootController()->UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else{
            return .init()
        }
        
        return root
    }
    
    @objc
    func onGestureChange(gesture: UIPanGestureRecognizer){
        if gesture.state == .cancelled || gesture.state == .ended{
            print("User Released Touch")
            // MARK: Your Max Duration Goes Here
            if !isRefreshing{
                if scrollOffset > 50{
                    isEligible = true
                }else{
                    isEligible = false
                }
            }
        }
    }
}

// MARK: Offset Modifier
extension View{
    @ViewBuilder
    func offset(coordinateSpace: String,offset: @escaping (CGFloat)->())->some View{
        self
            .overlay {
                GeometryReader{proxy in
                    let minY = proxy.frame(in: .named(coordinateSpace)).minY
                    
                    Color.clear
                        .preference(key: OffsetKey.self, value: minY)
                        .onPreferenceChange(OffsetKey.self) { value in
                            offset(value)
                        }
                }
            }
    }
}

// MARK: Offset Preference Key
struct OffsetKey: PreferenceKey{
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: Custom Resizbale Lottie View
struct ResizbaleLottieView: UIViewRepresentable{
    var fileName: String
    @Binding var isPlaying: Bool
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        addLottieView(view: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.subviews.forEach { view in
            // MARK: Finding View with Tag 1009
            if view.tag == 1009,let lottieView = view as? LottieAnimationView{
                if isPlaying{
                    lottieView.play()
                }else{
                    lottieView.pause()
                }
            }
        }
    }
    
    // MARK: Adding Lottie View
    func addLottieView(view to: UIView){
        let lottieView = LottieAnimationView(name: fileName, bundle: .main)
        lottieView.backgroundColor = .clear
        // MARK: For Finding It in Subview and Used for Animating
        lottieView.tag = 1009
        lottieView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            lottieView.widthAnchor.constraint(equalTo: to.widthAnchor),
            lottieView.heightAnchor.constraint(equalTo: to.heightAnchor),
        ]
        
        to.addSubview(lottieView)
        to.addConstraints(constraints)
    }
}

