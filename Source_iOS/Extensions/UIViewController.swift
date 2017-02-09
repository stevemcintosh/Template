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
	deinit {
		MemoryResourceTracking.decrementTotal()
	}
	
	init() {
		super.init(nibName: nil, bundle: nil)
		MemoryResourceTracking.incrementTotal()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}	
}
