import UIKit
import ProcedureKit

extension UIViewController {
	var contentViewController: UIViewController {
		if let navigationController = self as? UINavigationController {
			return navigationController.visibleViewController ?? self
		} else {
			return self
		}
	}
}

class ViewController: UIViewController {
	typealias CheckBlockType = (UIViewController) -> Void
	var check: CheckBlockType? = nil
	
	deinit {
		#if DEBUG
			MemoryResourceTracking.decrementTotal()
		#endif
	}
	
	init() {
		#if DEBUG
			MemoryResourceTracking.incrementTotal()
		#endif
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}	
}
