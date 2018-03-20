	import UIKit
import UserNotifications

public class RemoteNotificationService: NSObject {

    private var center: UNUserNotificationCenter! = nil
    private var launchOptions: [UIApplicationLaunchOptionsKey: Any]?

    convenience init(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        self.init()
        self.center = UNUserNotificationCenter.current()
        self.launchOptions = launchOptions
        self.center.delegate = self
		
        register()
		
		self.processLaunchOptions()
    }

	convenience init(notification: [String : Any]) {
		self.init()
		self.center = UNUserNotificationCenter.current()
		self.center.delegate = self
		register()
		self.handleNotification(notification: notification)
	}
	
	override init() {
        super.init()
    }
    
    func register() {
        self.center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] (success, error) in
			guard let strongSelf = self else { self?.processLaunchOptions(); return }
			if error != nil { strongSelf.processLaunchOptions(); return }
            if success {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
			}
        }
    }
	
    private func processLaunchOptions() {
        guard let launchOptions = self.launchOptions,
            let launchOptionsRemoteNotificationObject = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification],
            let remoteNotificationParcel = launchOptionsRemoteNotificationObject as? [String : Any] else { return }

		guard let notification = remoteNotificationParcel["aps"] as? [String : Any] else { return }
		guard let _ = notification["content-available"] as? Bool else {
			self.handleNotification(notification: notification)

			let remoteNotificationExtras = remoteNotificationParcel.filter({ $0.key != "aps" })
			self.handleNotificationExtras(notification: remoteNotificationExtras)
			return
		}
    }

	public func handleNotification(notification: [String : Any]) {

		for (key, value) in notification {
			switch key {
			case "alert":
				guard let message = value as? [String : String] else { continue }
				guard let messageBody = message["body"] else { return }
				Speech.say(phrase: messageBody, after: 5.0)
			case "sound":
				guard let soundResourceString = value as? String else { continue }
				Sound.play(named: soundResourceString)
			case "badge":
				guard let _ = value as? Int else { continue }
				// maybe call an endpoint api to get number of unread notifications and set the badge count to this unread value, otherwise set to 0
				UIApplication.shared.applicationIconBadgeNumber = 0
			case "category":
				print(value)
			default: continue
			}
		}
	}
	
	public func handleNotificationExtras(notification: [String : Any], playSound: Bool = true) {
	}
}

extension RemoteNotificationService: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		let notificationRequestContent = response.notification.request.content
		self.processNotificationContent(notificationRequestContent)
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notificationRequestContent = notification.request.content
		self.processNotificationContent(notificationRequestContent)
		completionHandler([.alert, .badge, .sound])
    }
	
	private func processNotificationContent(_ content: UNNotificationContent) {
		guard let userInfo = content.userInfo as? [String : Any] else { return }
		if let aps = userInfo["aps"] as? [String : Any] {
			self.handleNotification(notification: aps)
		}
		self.handleNotificationExtras(notification: userInfo.filter( { $0.key != "aps" }))
	}
}
