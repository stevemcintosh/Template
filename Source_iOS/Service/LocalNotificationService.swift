import Foundation
import UserNotifications

class LocalNotificationService {
    static let notificationDelegate = CustomNotificationDelegate()

    static func request() {

        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        center.getNotificationSettings { settings in
            print("settings = \(settings)")
            // TODO[ank] - check notification settings
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            center.requestAuthorization(options: options) { (granted, error) in
                print("granted: \(granted) error: \(error.printableDescription)")
            }
        }
    }

    static func sendTest() {
        let center = UNUserNotificationCenter.current()
        let identifier = UUID().uuidString
        let content = UNMutableNotificationContent()
        content.title = "Title"
        content.subtitle = "Subtitle"
        content.body = "Alert!"
        content.sound = UNNotificationSound.default()

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        center.add(request) { error in
            print("finished \(error.printableDescription)")
        }
    }
}

extension Optional where Wrapped == Error {
    var printableDescription: String {
        return self?.localizedDescription ?? "nil"
    }
}

class CustomNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Play sound and show alert to the user
        completionHandler([.alert,.sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            print("Snooze")
        case "Delete":
            print("Delete")
        default:
            print("Unknown action")
        }
        completionHandler()
    }
}
