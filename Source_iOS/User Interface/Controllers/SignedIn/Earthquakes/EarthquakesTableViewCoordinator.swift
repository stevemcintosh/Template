//
//  EarthquakesTableViewCoordinator.swift
//  Template
//
//  Created by stephenmcintosh on 22/6/17.
//  Copyright © 2017 Stephen McIntosh. All rights reserved.
//

import Foundation
import CoreData
import UIKit

import ProcedureKit

class EarthquakesTableViewCoordinator: BaseTableViewCoordinator {
	weak var delegate: EarthquakesTableViewControllerDelegate?
	var procedureQueue: ProcedureQueue?
	
	static let UpdateEarthquakeInfoWithUserLocationName = "UpdateEarthquakeInfoWithUserLocation"

	fileprivate var fetchTimer: Timer?
	
	override init() {
		super.init()
		self.context = EarthquakeModelContext().context
		self.fetch();
	}
	
	@objc func updateEarthquakes() {
		getEarthquakes(showRefreshControl: false, reloadTable: true)
	}
	
	func startFetchingEarthquakes(every time: TimeInterval = 600) {
		stopFetchingEarthquakes()
		getEarthquakes(showRefreshControl: false, reloadTable: true)
		fetchTimer = Timer.scheduledTimer(timeInterval: time,
		                                  target: self,
		                                  selector: #selector(self.updateEarthquakes),
		                                  userInfo: nil,
		                                  repeats: true)
	}
	
	func stopFetchingEarthquakes() {
		fetchTimer?.invalidate()
		fetchTimer = nil
	}
	
	func loadEarthquakeModel(completionHandler: @escaping () -> Void) {
		let procedure = LoadEarthquakeModel { [weak self] context in
			self?.context = context
			completionHandler()
		}
		procedureQueue?.add(operation: procedure)
	}
	
	func earthquakeInfo(at indexPath: IndexPath) -> Earthquake? {
		if let earthquake = fetchedResultsController?.object(at: indexPath) as? Earthquake {
			return earthquake
		}
		return nil
	}
	
	 @objc func getEarthquakes(showRefreshControl: Bool = false, reloadTable: Bool = false) {
		if showRefreshControl { self.delegate?.refreshControl(state: .start) }
		self.delegate?.navigationBarAnimation(state: .start)
		
		self.loadEarthquakeModel {
			if let context = self.context {
				let getEarthquakesGroupProcedure = GetLatestEarthquakes(context: context) { [weak self] in
					guard let strongSelf = self else { return }
					strongSelf.fetch()

					DispatchQueue.main.async {
						if showRefreshControl { strongSelf.delegate?.refreshControl(state: .stop) }
						strongSelf.delegate?.navigationBarAnimation(state: .stop)
						if reloadTable { strongSelf.delegate?.updateUI() }
					}
				}
				getEarthquakesGroupProcedure.userIntent = .initiated
				self.procedureQueue?.add(operation: getEarthquakesGroupProcedure)
			} else {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
					if showRefreshControl { self?.delegate?.refreshControl(state: .stop) }
					self?.delegate?.navigationBarAnimation(state: .stop)
				}
			}
		}
	}
	
	private func fetch() {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: Earthquake.entityName)
		request.sortDescriptors = [NSSortDescriptor(key: "sectionIdentifier", ascending: false), NSSortDescriptor(key: "timestamp", ascending: false)]
		request.fetchBatchSize = 20
		request.fetchOffset = 0
		
		let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context!, sectionNameKeyPath: "sectionIdentifier", cacheName: nil)
		self.fetchedResultsController = controller
		self.fetchedResultsController?.delegate = self
		self.performFetch()
	}
	
	func titleForHeaderInSection(section: Int) -> String? {
		guard let sectionInfo = fetchedResultsController?.sections else { return "" }
		
		guard let objectsInSection = sectionInfo[section].objects as? [Earthquake] else { return sectionInfo[section].name }
		let sortedObjects = objectsInSection.sorted(by: { $0.timestamp > $1.timestamp })
		guard var (_, sectionHeadingStr) = Earthquake.ddMMYYYFromDate(date: (sortedObjects.first?.sectionIdentifier)!) as? (Date, String) else { return sectionInfo[section].name }
		guard let sectionHeadingDate = sortedObjects.first?.timestamp else { return sectionHeadingStr }
		
		if NSCalendar.current.isDateInToday(sectionHeadingDate) {
			sectionHeadingStr = "Today"
		} else if NSCalendar.current.isDateInYesterday(sectionHeadingDate) {
			sectionHeadingStr = "Yesterday"
		}
		return sectionHeadingStr
	}
}

extension EarthquakesTableViewCoordinator: NSFetchedResultsControllerDelegate {
	
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		self.delegate?.getTableView().beginUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
		switch type {
		case .insert: self.delegate?.getTableView().insertSections(IndexSet(integer: sectionIndex), with: .fade)
		case .delete: self.delegate?.getTableView().deleteSections(IndexSet(integer: sectionIndex), with: .fade)
		default: break
		}
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			self.delegate?.getTableView().insertRows(at: [newIndexPath!], with: .fade)
		case .delete:
			self.delegate?.getTableView().deleteRows(at: [indexPath!], with: .fade)
		case .update:
			self.delegate?.getTableView().reloadRows(at: [indexPath!], with: .fade)
		case .move:
			self.delegate?.getTableView().deleteRows(at: [indexPath!], with: .fade)
			self.delegate?.getTableView().insertRows(at: [newIndexPath!], with: .fade)
		}
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		self.delegate?.getTableView().endUpdates()
	}
}
