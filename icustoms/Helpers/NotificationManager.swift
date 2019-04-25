//
//  NotificationManager.swift
//  icustoms
//
//  Created by Dmitry Kuzin on 15/04/2019.
//  Copyright © 2019 Dmitry Kuzin. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseMessaging

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let `default` = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    func registerPushNotifications() {
        notificationCenter.delegate = self
        setupFirebase()
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] (granted, error) in
            guard granted else { return }
            self?.getNotificationSettings()
        }
    }
    
    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    private func setupFirebase() {
        Messaging.messaging().delegate = self
    }
    
}

extension NotificationManager: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if fcmToken != UserDefaults.standard.string(forKey: "device_token") {
            if Database.default.currentUser() != nil {
                if let oldToken = UserDefaults.standard.string(forKey: "device_token") {
                    API.default.deleteDeviceToken(oldToken)
                }
                API.default.setDeviceToken(fcmToken)
            }
        }
        UserDefaults.standard.set(fcmToken, forKey: "device_token")
        print(fcmToken)
    }
    
}
