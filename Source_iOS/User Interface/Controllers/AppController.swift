import UIKit
import ProcedureKit
//import Fabric
//import Crashlytics
//import SwiftyBeaver

class AppController : BaseAppController {

	let procedureQueue = ProcedureQueue()

	//	lazy var fabric: Fabric = Fabric.with([Crashlytics.self])
	static var appController: AppController? {
		willSet {
			self.appController = newValue
		}
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		preferredDisplayMode = .allVisible
		delegate = self
		AppController.appController = self
		configure()
	}
	
	
	func configure() {
		UIApplication.shared.keyWindow?.rootViewController = AppController.appController
		let operation = BlockProcedure {
			DispatchQueue.default.async { [weak weakSelf = self] in
				weakSelf?.configureBaseApplication()
			}
		}
		operation.add(observer: BlockObserver(didFinish: { _, errors in
			DispatchQueue.default.async {
				operation.finish(withErrors: errors)
			}
		}))
		procedureQueue.addOperation(operation)
	}
	
	open func configureBaseApplication() {
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

