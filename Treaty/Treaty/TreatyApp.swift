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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Configuring Firebase Push Notifications...
// See my Full Push Notification Video..
// Link in Description...

// Intializng Firebase And CLoud Messaging...

class AppDelegate: NSObject,UIApplicationDelegate{
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        
        FirebaseApp.configure()
        
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
        
        // Get current user's unique ID
        let userID = Auth.auth().currentUser?.uid
        
        // Store token in Firestore For Sending Notifications From Server in Future...
        let db = Firestore.firestore()
        db.collection("Users").document(userID!).setData(dataDict, merge: true) { (error) in
            if let error = error {
                print("Error storing FCM token in Firestore: \(error)")
            } else {
                print("Successfully stored FCM token in Firestore")
            }
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


