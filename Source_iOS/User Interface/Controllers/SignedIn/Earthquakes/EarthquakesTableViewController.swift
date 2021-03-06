import UIKit
import CoreData

import ProcedureKit

protocol EarthquakesTableViewControllerDelegate: class  {
	func updateUI()
	func navigationBarAnimation(state: EarthquakesTableViewController.AnimationState)
	func refreshControl(state: EarthquakesTableViewController.AnimationState)
	func getTableView() -> UITableView
//	func updateEarthquakeInfoWithUserLocation()
}

class EarthquakesTableViewController: TableViewController {
	
	enum AnimationState {
		case start
		case stop
	}
	
	fileprivate struct Constants {
		static let ShowEarthQuake = "showEarthquake"
	}
	
	// MARK: Properties
	var viewCoordinator: EarthquakesTableViewCoordinator?
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.estimatedRowHeight = 85
		self.tableView.rowHeight = UITableView.automaticDimension
		self.tableView.estimatedSectionHeaderHeight = 30
		
		viewCoordinator = EarthquakesTableViewCoordinator()
		viewCoordinator?.procedureQueue = self.procedureQueue
		viewCoordinator?.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		viewCoordinator?.startFetchingEarthquakes()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewCoordinator?.stopFetchingEarthquakes()
	}
	
	@IBOutlet weak var refresh: UIRefreshControl!
	
	func refreshControl(state: EarthquakesTableViewController.AnimationState) {
		switch state {
		case .start:
			self.refresh.beginRefreshing()
		case .stop:
			self.refresh.endRefreshing()
		}
	}
	
	@IBAction func startRefreshing() {
		viewCoordinator?.getEarthquakes(showRefreshControl: true, reloadTable: false)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Constants.ShowEarthQuake {
			guard let detailVC = segue.destination.contentViewController as? EarthquakeBaseController else { return }
			
			detailVC.procedureQueue = self.procedureQueue
			if let indexPath = tableView.indexPathForSelectedRow {
				guard let earthquake = viewCoordinator?.earthquakeInfo(at: indexPath) else { return }
				detailVC.earthquake = earthquake
				self.splitViewController?.preferredDisplayMode = .allVisible
			}
		}
	}
}

extension EarthquakesTableViewController { // UITableViewDataSource methods
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if let headerCell = self.tableView.dequeueReusableCell(withIdentifier: "sectionHeaderCell") as? EarthquakeSectionHeaderView {
			headerCell.textLabel?.text = viewCoordinator?.titleForHeaderInSection(section: section)
			headerCell.textLabel?.textColor = UIColor.almostWhite
			headerCell.textLabel?.backgroundColor = UIColor.cerulean
			headerCell.contentView.backgroundColor = UIColor.cerulean
			return headerCell
		}
		return nil
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewCoordinator?.numberofSections ?? 0
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let numberOfRows = viewCoordinator?.numberOfRowsInSection(section) ?? 0
		return numberOfRows
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "earthquakeCell", for: indexPath) as! EarthquakeTableViewCell
		
		if let earthquake = viewCoordinator?.earthquakeInfo(at: indexPath), earthquake.identifier != "" {
			cell.configure(earthquake: earthquake)
			return cell
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let blockProcedure = BlockProcedure {
			DispatchQueue.main.async { [weak weakSelf = self] in
				weakSelf?.performSegue(withIdentifier: Constants.ShowEarthQuake, sender: nil)
				tableView.deselectRow(at: indexPath, animated: true)
			}
		}
		
		blockProcedure.add(observer: BlockObserver(didFinish: { _, errors in
			DispatchQueue.main.async {
				blockProcedure.finish(withErrors: errors)
			}
		}))
		blockProcedure.add(observer: NetworkObserver(controller: NetworkActivityController.shared))
		procedureQueue.addOperation(blockProcedure)
	}
	
}

extension EarthquakesTableViewController: UITableViewDragDelegate {
	func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
		return [UIDragItem.init(itemProvider: NSItemProvider())]
	}
}

extension EarthquakesTableViewController: UITableViewDropDelegate {
	func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
	}
}

extension EarthquakesTableViewController: EarthquakesTableViewControllerDelegate {
	func getTableView() -> UITableView {
		return self.tableView
	}
	
	func updateUI() {
		DispatchQueue.main.async { [weak self] in
			self?.tableView.reloadData()
		}
	}
	
	func navigationBarAnimation(state: AnimationState) {
		switch state {
		case .start:
			self.navigationController?.startAnimating()
		case .stop:
			self.navigationController?.stopAnimating()
		}
	}
}
