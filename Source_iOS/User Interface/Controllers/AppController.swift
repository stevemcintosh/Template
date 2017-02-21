import UIKit

//import Fabric
//import Crashlytics

import ProcedureKit
import ProcedureKitMobile
import ProcedureKitNetwork

//import SwiftyBeaver

class AppController : BaseAppController {

	//	lazy var fabric: Fabric = Fabric.with([Crashlytics.self])
	let procedureQueue = ProcedureQueue()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		preferredDisplayMode = .allVisible
		delegate = self
		configure()
	}
	
	
	func configure() {
		self.configureBaseApplication()
	}
	
	open func configureBaseApplication() -> Void {
//		Answers.logCustomEvent(withName: "configureBaseApplication", customAttributes: ["Category" : "App Launched", "configureBaseApplication" : 1])

		UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
		
		configureLogging()
		configureApplicationMonitoringTools()
	}
	
	fileprivate func configureApplicationMonitoringTools() -> Swift.Void {
//		fabric.debug = true
	}
	
//	let log = SwiftyBeaver.self
	fileprivate func configureLogging() -> Swift.Void {
//		let console = ConsoleDestination()
//		log.addDestination(console)
//		
//		ProcedureKit.LogManager.logger = { [weak weakSelf = self] message, severity, file, function, line in
//			switch severity {
//			case .verbose:
//				weakSelf?.log.verbose(message, file, function, line: line)
//			case .notice:
//				weakSelf?.log.debug(message, file, function, line: line)
//			case .info:
//				weakSelf?.log.info(message, file, function, line: line)
//			case .warning:
//				weakSelf?.log.warning(message, file, function, line: line)
//			case .fatal:
//				weakSelf?.log.error(message, file, function, line: line)
//			}
//		}
//		ProcedureKit.LogManager.severity = .info
	}
	
	func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
		guard let navigation = secondaryViewController as? UINavigationController else { return false }
		guard let detail = navigation.viewControllers.first as? EarthquakeTableViewController else { return false }
		
		return detail.earthquake == nil
	}
	
	func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) {
		print()
	}

	func splitViewControllerPreferredInterfaceOrientationForPresentation(_ splitViewController: UISplitViewController) -> UIInterfaceOrientation {
		return UIInterfaceOrientation.portrait
	}

}

