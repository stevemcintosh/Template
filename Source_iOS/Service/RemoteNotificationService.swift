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
					strongSelf.processLaunchOptions()
                }
			} else {
				strongSelf.processLaunchOptions()
			}
        }
    }
	
    private func processLaunchOptions() {
        guard let launchOptions = self.launchOptions,
            let launchOptionsRemoteNotificationObject = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification],
            let remoteNotificationParcel = launchOptionsRemoteNotificationObject as? [String : Any] else { return }
        print(remoteNotificationParcel["aps"]! as Any)
    }

}

extension RemoteNotificationService: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print()
    }
    
}
