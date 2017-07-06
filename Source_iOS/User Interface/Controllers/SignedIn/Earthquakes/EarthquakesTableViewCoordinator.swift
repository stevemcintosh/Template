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
import ProcedureKitMobile
import ProcedureKitNetwork

class EarthquakesTableViewCoordinator: BaseTableViewCoordinator {
	let timestampFormatter = DateFormatter()
	weak var delegate: EarthquakesTableViewControllerDelegate?
	var procedureQueue: ProcedureQueue?
	
	override init() {
		super.init()
		timestampFormatter.dateStyle = .medium
	}
	
	func loadEarthquakeModel(completionHandler: @escaping () -> Void) {
		
		if self.context != nil {
			completionHandler()
			return
		}
		
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
	
	func getEarthquakes(showRefreshControl: Bool = false) {
		if showRefreshControl { self.delegate?.refreshControl(state: .start) }
		self.delegate?.navigationBarAnimation(state: .start)
		
		self.loadEarthquakeModel {
			if let context = self.context {
				let getEarthquakesGroupProcedure = GetLatestEarthquakes(context: context) {
					let request = NSFetchRequest<NSFetchRequestResult>(entityName: Earthquake.entityName)
					request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
					request.fetchLimit = 100
					request.fetchBatchSize = 20
					
					let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "sectionIdentifier", cacheName: "Root")
					self.fetchedResultsController = controller
					self.fetchedResultsController?.delegate = self
					self.performFetch()
					
					DispatchQueue.main.async { [weak self] in
						if showRefreshControl { self?.delegate?.refreshControl(state: .stop) }
						self?.delegate?.navigationBarAnimation(state: .stop)
						self?.delegate?.updateUI()
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
	
	func titleForHeaderInSection(section: Int) -> String? {
		guard let sectionInfo = fetchedResultsController?.sections else { return "" }
		var sectionHeadingStr = sectionInfo[section].name
		
		guard self.earthquakeInfo(at: IndexPath(row: 0, section:0))?.identifier != "" else { return sectionInfo[section].name }
		guard let sectionHeadingDate = self.earthquakeInfo(at: IndexPath(row: 0, section: section))?.timestamp else { return sectionInfo[section].name }
		
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
