import UIKit

import Fabric
import Crashlytics

import ProcedureKit
import ProcedureKitMobile
import ProcedureKitNetwork

import SwiftyBeaver

class AppController: UISplitViewController {
    /// Shared instance
	static let shared = AppController(nibName: nil, bundle: nil)

	lazy var fabric: Fabric = Fabric.with([Crashlytics.self])
	
	let procedureQueue = ProcedureQueue()

	deinit {
		#if DEBUG
			MemoryResourceTracking.decrementTotal()
		#endif
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nil, bundle: nil)
		debug()
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updateMaximumPrimaryColumnWidthBasedOnSize(to: view.bounds.size)
	}
	
	fileprivate func debug() {
		#if DEBUG
			MemoryResourceTracking.incrementTotal()
		#endif
	}
	
	func updateMaximumPrimaryColumnWidthBasedOnSize(to size: CGSize) {
		if size.width < UIScreen.main.bounds.width || size.width < size.height {
			maximumPrimaryColumnWidth = 480.0
		} else {
			maximumPrimaryColumnWidth = UISplitViewControllerAutomaticDimension
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		updateMaximumPrimaryColumnWidthBasedOnSize(to: size)
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
		
		splitViewController.minimumPrimaryColumnWidth = 80
		splitViewController.maximumPrimaryColumnWidth = 180
			
		self.configureBaseApplication()
	}
	
	open func configureBaseApplication() -> Void {
		Answers.logCustomEvent(withName: "configureBaseApplication", customAttributes: ["Category" : "App Launched", "configureBaseApplication" : 1])

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

	func startMemoryTest() {
		#if DEBUG
			MemoryResourceTracking.incrementTotal()
			MemoryResourceTracking.incrementTotal()
		#endif
	}
	
	func endMemoryTest() -> Int {
		#if DEBUG
			MemoryResourceTracking.decrementTotal()
			MemoryResourceTracking.decrementTotal()
			return MemoryResourceTracking.total
		#endif
	}
	
	fileprivate func configureApplicationMonitoringTools() -> Swift.Void {
		fabric.debug = true
	}
	
	let log = SwiftyBeaver.self
	fileprivate func configureLogging() -> Swift.Void {
		let console = ConsoleDestination()
		log.addDestination(console)
		
		ProcedureKit.LogManager.logger = { message, severity, file, function, line in
			switch severity {
			case .verbose:
				self.log.verbose(message, file, function, line: line)
			case .notice:
				self.log.debug(message, file, function, line: line)
			case .info:
				self.log.info(message, file, function, line: line)
			case .warning:
				self.log.warning(message, file, function, line: line)
			case .fatal:
				self.log.error(message, file, function, line: line)
			}
		}
		ProcedureKit.LogManager.severity = .info
	}	
}

extension AppController : UISplitViewControllerDelegate {
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
		guard let navigation = secondaryViewController as? UINavigationController else { return false }
		guard let detail = navigation.viewControllers.first as? EarthquakeTableViewController else { return false }
		
		return detail.earthquake == nil
	}
}
