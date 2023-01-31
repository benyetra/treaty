//
//  TreatyApp.swift
//  Treaty
//
//  Created by Bennett Yetra on 1/18/23.
//

import SwiftUI
import Firebase
import FirebaseMessaging
import GoogleSignIn

@main
struct TreatyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var viewModel = PartnerRequestViewModel()
    
    var body: some Scene {
        WindowGroup {
            if viewModel.partnerRequests.isEmpty{
                ContentView()
            } else {
                PartnerRequestView(viewModel: viewModel)
            }
        }
    }
}


// Configuring Firebase Push Notifications...
// See my Full Push Notification Video..
// Link in Description...

// Intializng Firebase And Cloud Messaging...

class AppDelegate: NSObject,UIApplicationDelegate{
    @StateObject private var viewModel = PartnerRequestViewModel()

    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        
        FirebaseApp.configure()
        
        if let clientID = FirebaseApp.app()?.options.clientID{
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
        }
        
        // Setting Up Cloud Messaging...
        
        Messaging.messaging().delegate = self
        
        // Setting Up Notifications...
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        // Do Something With Message Data Here....
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }
        viewModel.fetchPartnerRequests()

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
    
    // In order to receive notifications you need implement thsese methods...
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }

}

// Cloud Messaging...
extension AppDelegate: MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        // Store this token to firebase and retrieve when to send message to someone....
        let dataDict:[String: String] = ["token": fcmToken ?? ""]
        
        if let currentUser = Auth.auth().currentUser {
            let userID = currentUser.uid
            let db = Firestore.firestore()
            db.collection("Users").document(userID).setData(dataDict, merge: true) { (error) in
                if let error = error {
                    print("Error storing FCM token in Firestore: \(error)")
                } else {
                    print("Successfully stored FCM token in Firestore")
                }
            }
        } else {
            print("No user is logged in")
        }
    }
}



// User Notifications...[AKA InApp Notifications...]

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // DO Something With MSG Data...
    
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    print(userInfo)

    completionHandler([[.banner,.badge, .sound]])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    if let messageID = userInfo[gcmMessageIDKey] {
      print("Message ID: \(messageID)")
    }

    // DO Something With MSG Data...
    print(userInfo)

    completionHandler()
  }
}


