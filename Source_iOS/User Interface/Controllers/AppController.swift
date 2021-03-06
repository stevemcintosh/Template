import UIKit
import ProcedureKit
//import Fabric
//import Crashlytics
//import SwiftyBeaver

class AppController : BaseAppController {

    let procedureQueue = ProcedureQueue()

    //    lazy var fabric: Fabric = Fabric.with([Crashlytics.self])
    static var appController: AppController? {
        willSet {
            self.appController = newValue
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        preferredDisplayMode = .allVisible
		preferredPrimaryColumnWidthFraction = 0.45
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
//        Answers.logCustomEvent(withName: "configureBaseApplication", customAttributes: ["Category" : "App Launched", "configureBaseApplication" : 1])
		
		DispatchQueue.main.async {
			UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
		}
        
        configureLogging()
        configureApplicationMonitoringTools()
    }
    
    fileprivate func configureApplicationMonitoringTools() -> Swift.Void {
//        fabric.debug = true
    }
    
//    let log = SwiftyBeaver.self
    fileprivate func configureLogging() -> Swift.Void {
//        let console = ConsoleDestination()
//        log.addDestination(console)
//        
//        ProcedureKit.LogManager.logger = { [weak weakSelf = self] message, severity, file, function, line in
//            switch severity {
//            case .verbose:
//                weakSelf?.log.verbose(message, file, function, line: line)
//            case .notice:
//                weakSelf?.log.debug(message, file, function, line: line)
//            case .info:
//                weakSelf?.log.info(message, file, function, line: line)
//            case .warning:
//                weakSelf?.log.warning(message, file, function, line: line)
//            case .fatal:
//                weakSelf?.log.error(message, file, function, line: line)
//            }
//        }
//        ProcedureKit.LogManager.severity = .info
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let navigation = secondaryViewController as? UINavigationController else { return false }
        guard let detail = navigation.viewControllers.first as? EarthquakeBaseController else { return false }
        
        return detail.earthquake == nil
    }
	
    
	func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        print()
    }

    func splitViewControllerPreferredInterfaceOrientationForPresentation(_ splitViewController: UISplitViewController) -> UIInterfaceOrientation {
        return UIInterfaceOrientation.landscapeLeft
    }

}

