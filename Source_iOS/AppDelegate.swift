import UIKit
import UserNotifications

/*
		not running -----<<<----------------------------------------|
			|														|
		   \|/	--didFinishLaunchingWithOptions						|
			|														|->>>--[Foreground]---------
		  in-active -----<<<--applicationWillEnterBackground--------|- code running but not receiving UI events, may have come from background, so yr app wasn't
			|														|     killed, maybe undo what you did in DidEnterBackground, as you will become Active soon.
			|														|
		   /|\	- applicationWillResignActive (pause UI here)		|
			|		(eg this may be called if a phone call happens	|
		  active													|- code running, receiving & processing UI events
																	|-<<<---[Foreground]----------
																	|
																	|->>>---[Background]----------
		 background -----<<<-applicationDidEnterBackground----------| - runnning code for a very limited time (< 30 secs), no UI events, get ready to be killed,
			|														|     but it may not happen, depends on systems resources, etc
			|														|-<<<---[Background]----------
		   /|\														|
			|														|
		   \|/														|
		suspensed-------->>>----------------------------------------| - code not running, maybe killed at any time by iOS
*/

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	// MARK: - Properties -

	/// The main window for the application.
	var window: UIWindow?
	
	// MARK: - UIApplicationDelegate -
		
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		// launch process has begun, but restore state has not started.
		// storyboard has been loaded, but app is in in-active state
		// launch options will tell you how the app has been launched, eg by the system, openURL, etc
		// The presence of the launch keys gives you the opportunity to plan for that behavior. 
		// In the case of a URL to open, you might want to prevent state restoration if the URL represents a document that the user wanted to open.
		// In some cases, the user launches your app with a Home screen quick action. 
		// To ensure you handle this launch case correctly, read the discussion in the application(_:performActionFor:completionHandler:) method.
		
		return true
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		/* Tells the delegate that the launch process is almost done and the app is almost ready to run.
		Use this method (and the corresponding application(_:willFinishLaunchingWithOptions:) method) to complete your app’s initialization and make any final tweaks. This method is called after state restoration has occurred but before your app’s window and other UI have been presented. At some point after this method returns, the system calls another of your app delegate’s methods to move the app to the active (foreground) state or the background state.
		This method represents your last chance to process any keys in the launchOptions dictionary. If you did not evaluate the keys in your application(_:willFinishLaunchingWithOptions:) method, you should look at them in this method and provide an appropriate response.
		Objects that are not the app delegate can access the same launchOptions dictionary values by observing the notification named UIApplicationDidFinishLaunching and accessing the notification’s userInfo dictionary. That notification is sent shortly after this method returns.
		*/
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.makeKeyAndVisible()

		self.guideUserJourney()
		return true
	}
	
	private func guideUserJourney() {
		// guard let token = KeyChain.apiToken, let email = KeyChain.email else {
		 self.showUserLoginOnboarding()
		// return
		// }
//		self.showSignedIn()
	}
	
	private func showUserLoginOnboarding() {
		let storyboard = UIStoryboard(name: "LoginOnboarding", bundle: nil)
		guard let _ = storyboard.instantiateInitialViewController() as? LoginOnboardingController else {
			fatalError("Unable to load the Login controller.")
		}
	}
	
	private func showSignedIn() {
		let storyboard = UIStoryboard(name: "SignedIn", bundle: nil)
		guard let _ = storyboard.instantiateInitialViewController() as? AppController else {
			fatalError("Unable to load the SignedIn controller.")
		}
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
	}

	func applicationWillResignActive(_ application: UIApplication) {
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
    }

	func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
	}
	
	func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
	}

	func applicationWillTerminate(_ application: UIApplication) {
	}
	
	func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
	}
	
	func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
	}

	func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
	}
	
	func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
		return true
	}
	
	func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
		return true
	}
	
	@nonobjc func application(_ application: UIApplication, didRegister notificationSettings: UNNotificationSettings) {
//		UserNotificationCondition.didRegisterUserNotificationSettings(notificationSettings)
//
//		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound]) { (granted, error) in
//			if granted {
//
//			}
//		}
	}
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//		RemoteNotificationCondition.registeredForRemoteNotifications(deviceToken)
	}
	
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//		RemoteNotificationCondition.didFailToRegisterForRemoteNotifications(error as NSError)
	}
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//		RemoteNotificationCondition.didReceiveNotificationToken(deviceToken)
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		return true
	}
	
	func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
	}

	func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
	}

	func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
	}
	
	func application(_ application: UIApplication, didChangeStatusBarFrame oldStatusBarFrame: CGRect) {
	}
	
	func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
		return true
	}
	
	func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
	}
	
	func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
	}
	
	func applicationSignificantTimeChange(_ application: UIApplication) {
	}

	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.allButUpsideDown
	}
	
	func application(_ application: UIApplication, didChangeStatusBarOrientation oldStatusBarOrientation: UIInterfaceOrientation) {
	}
	
	func application(_ application: UIApplication, willChangeStatusBarOrientation newStatusBarOrientation: UIInterfaceOrientation, duration: TimeInterval) {
	}

	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
		return true
	}

	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		/* Called when the user selects a Home screen quick action for your app, except when you’ve intercepted the interaction in a launch method.
		Implement this method to respond to the user’s selection of a Home screen quick action for your app; call the completion handler, with an appropriate Boolean value, when finished.
		It’s your responsibility to ensure the system calls this method conditionally, depending on whether or not one of your app launch methods (application(_:willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions:)) has already handled a quick action invocation. The system calls a launch method (before calling this method) when a user selects a quick action for your app and your app launches instead of activating.

		The requested quick action might employ code paths different than those used otherwise when your app launches. For example, say your app normally launches to display view A, but your app was launched in response to a quick action that needs view B. To handle such cases, check, on launch, whether your app is being launched via a quick action. Perform this check in your application(_:willFinishLaunchingWithOptions:) or application(_:didFinishLaunchingWithOptions:) method by checking for the shortcutItem launch option key. The UIApplicationShortcutItem object is available as the value of the launch option key.
		If you find that your app was indeed launched using a quick action, perform the requested quick action within the launch method and return a value of false from that method. When you return a value of false, the system does not call the application:performActionForShortcutItem:completionHandler: method.
		*/
	}
	
	func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
		return nil
	}
	
	func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool {
		return true
	}
	
	func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Void) {
	}
	
	func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
	}
}
