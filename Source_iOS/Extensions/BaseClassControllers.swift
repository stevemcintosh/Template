import UIKit

class BaseAppController : UISplitViewController, UISplitViewControllerDelegate {
	deinit {
		MemoryResourceTracking.decrementTotal()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		MemoryResourceTracking.incrementTotal()
	}
}

class TableViewController: UITableViewController {
	deinit {
		MemoryResourceTracking.decrementTotal()
	}
		
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		MemoryResourceTracking.incrementTotal()
	}
}

class TableViewCell: UITableViewCell {
	deinit {
		MemoryResourceTracking.decrementTotal()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		MemoryResourceTracking.incrementTotal()
	}
}
