//
//  NotificationService.swift
//  NotificationService
//
//  Created by ak on 2020/4/14.
//  Copyright © 2020 ak. All rights reserved.
//

import UserNotifications
class NotificationService: UNNotificationServiceExtension {
  
  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?
  
  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
    
    if let info = bestAttemptContent?.userInfo, let aps = info["aps"] as? [String: Any], let str = aps["transfer"] as? String, let cnt = Double(str), cnt > 0 {
      //need to play voice
      let name = ApnsHelper.makeMp3FromExt(cnt)
      let sound = UNNotificationSound(named: UNNotificationSoundName(name))
      bestAttemptContent?.sound = sound
    }
    
    if let bestAttemptContent = bestAttemptContent {
      // Modify the notification content here...
      bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
      
      contentHandler(bestAttemptContent)
    }
  }
  
  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }
}
