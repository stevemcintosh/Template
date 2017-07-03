import UIKit

import ProcedureKit
import ProcedureKitMobile
import ProcedureKitNetwork

class BaseAppController : UISplitViewController, UISplitViewControllerDelegate {
	deinit {
		MemoryResourceTracking.decrementTotal(String(describing: self))
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		MemoryResourceTracking.incrementTotal(String(describing: self))
	}
}

class ViewController: UIViewController {
	deinit {
		MemoryResourceTracking.decrementTotal(String(describing: self))
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		MemoryResourceTracking.incrementTotal(String(describing: self))
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.prefersLargeTitles = false
		self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
		self.navigationController?.navigationItem.searchController = UISearchController(searchResultsController: self)
	}
}

class TableViewController: UITableViewController {
	
	var procedureQueue = ProcedureQueue()
	
	deinit {
		MemoryResourceTracking.decrementTotal(String(describing: self))
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		MemoryResourceTracking.incrementTotal(String(describing: self))
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.prefersLargeTitles = false
		self.navigationController?.navigationItem.largeTitleDisplayMode = .automatic
		self.navigationController?.navigationItem.searchController = UISearchController(searchResultsController: self)
	}
}

class TableViewCell: UITableViewCell {
	deinit {
		MemoryResourceTracking.decrementTotal(String(describing: self))
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		MemoryResourceTracking.incrementTotal(String(describing: self))
	}
}

