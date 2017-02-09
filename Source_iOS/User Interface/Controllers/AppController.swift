import UIKit

//import Fabric
//import Crashlytics

import ProcedureKit
import ProcedureKitMobile
import ProcedureKitNetwork

import SwiftyBeaver

class AppController: UISplitViewController {
    /// Shared instance
	static let shared = AppController(nibName: nil, bundle: nil)

//	lazy var fabric: Fabric = Fabric.with([Crashlytics.self])
	
	let procedureQueue = ProcedureQueue()

	deinit {
		MemoryResourceTracking.decrementTotal()
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
		MemoryResourceTracking.incrementTotal()
		configure()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		preferredDisplayMode = .allVisible
		delegate = self
	}
	
	func configure() {
		let storyboard = UIStoryboard(name: "SignedIn", bundle: nil)
		guard let splitViewController = storyboard.instantiateInitialViewController() as? AppController else {
			fatalError("Unable to load the split view controller.")
		}
		
		guard let appDelegate = (UIApplication.shared.delegate) as? AppDelegate else { return }
		appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
		appDelegate.window?.rootViewController = splitViewController
		appDelegate.window?.makeKeyAndVisible()
		
		self.configureBaseApplication()
	}
	
	open func configureBaseApplication() -> Void {
//		Answers.logCustomEvent(withName: "configureBaseApplication", customAttributes: ["Category" : "App Launched", "configureBaseApplication" : 1])

		UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
		
		configureLogging()
		configureApplicationMonitoringTools()
	}
	
	fileprivate func createInfoAlert() -> AlertProcedure {
		let alert = AlertProcedure(presentAlertFrom: self)
		alert.add(actionWithTitle: "Sweet") { alert, action in
			alert.log.info(message: "Running the handler!")
		}
		alert.title = "Hello World"
		alert.message = "This is a message in an alert"
		return alert
	}

	
	fileprivate func configureApplicationMonitoringTools() -> Swift.Void {
//		fabric.debug = true
	}
	
//	let log = SwiftyBeaver.self
	fileprivate func configureLogging() -> Swift.Void {
//		let console = ConsoleDestination()
//		log.addDestination(console)
//		
//		ProcedureKit.LogManager.logger = { message, severity, file, function, line in
//			switch severity {
//			case .verbose:
//				self.log.verbose(message, file, function, line: line)
//			case .notice:
//				self.log.debug(message, file, function, line: line)
//			case .info:
//				self.log.info(message, file, function, line: line)
//			case .warning:
//				self.log.warning(message, file, function, line: line)
//			case .fatal:
//				self.log.error(message, file, function, line: line)
//			}
//		}
//		ProcedureKit.LogManager.severity = .info
	}
}

extension AppController: UISplitViewControllerDelegate {
	func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
		guard let navigation = secondaryViewController as? UINavigationController else { return false }
		guard let detail = navigation.viewControllers.first as? EarthquakeTableViewController else { return false }
		
		return detail.earthquake == nil
	}
}
