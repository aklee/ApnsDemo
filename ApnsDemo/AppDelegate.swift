//
//  AppDelegate.swift
//  ApnsDemo
//
//  Created by ak on 2020/4/14.
//  Copyright © 2020 ak. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    NSLog("tmp: \(NSTemporaryDirectory())")
    registerRemoteNotification()
    //根据需求播放语音：
//    let name = ApnsHelper.makeMp3(55)
//    postLocalNotification(name)
    return true
  }
  
  func registerRemoteNotification() {
    if #available(iOS 10.0, *) {
      let center: UNUserNotificationCenter = UNUserNotificationCenter.current()
      center.delegate = self
      center.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted: Bool, error: Error?) in
        if (granted) {
          NSLog("注册通知成功")
        } else {
          NSLog("注册通知失败")
        }
      })
      UIApplication.shared.registerForRemoteNotifications()
      return
    }
    if #available(iOS 8.0, *) {
      let userSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
      UIApplication.shared.registerUserNotificationSettings(userSettings)
      UIApplication.shared.registerForRemoteNotifications()
    }
  } 
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    var token = ""
    for byte in deviceToken {
      token += String(format: "%02X", byte)
    }
    NSLog("token: %@\n", token)
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    NSLog("token Error: %@", error.localizedDescription)
  }
  
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    NSLog("willPresentNotification: %@", notification.request.content.userInfo)
    completionHandler([.badge, .sound, .alert])
  }
  
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    NSLog("didReceive NotificationResponse: %@", response.notification.request.content.userInfo)
    completionHandler()
  }
  
  ///收到静默通知。iOS 10以下收到APNs推送并点击时触发、APP在前台时收到APNs推送
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    NSLog("didReceive RemoteNotification: %@", userInfo)
    completionHandler(UIBackgroundFetchResult.newData)
  }
  
  @available(iOS 10.0, *)
  func postLocalNotification(_ soundName: String) {
    let content = UNMutableNotificationContent()
    let sound = UNNotificationSound(named: UNNotificationSoundName(soundName))
    content.sound = sound
    content.title = "test"
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
    let req = UNNotificationRequest.init(identifier: "identifier", content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(req) { err in
      if let err = err {
        NSLog("postLocalNotification error: \(err)")
      }
    }
    
  }
}
