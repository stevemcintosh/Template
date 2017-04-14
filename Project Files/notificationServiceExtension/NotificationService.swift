//
//  NotificationService.swift
//  notificationServiceExtension
//
//  Created by stephenmcintosh on 1/3/17.
//  Copyright © 2017 Stephen McIntosh. All rights reserved.
//

import UserNotifications
import OLExtension

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
		
		OLExtension.notificationService().didReceive(request) { (content) in
		}
			
//			.didReceiveNotificationRequest:request withContentHandler:contentHandler
		if let attachment = request.content.attachments.first {
			if attachment.url.startAccessingSecurityScopedResource() {
				_ = attachment.url.path
				attachment.url.stopAccessingSecurityScopedResource()
			}
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
