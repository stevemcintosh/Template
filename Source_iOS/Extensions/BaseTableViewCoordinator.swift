//
//  BaseTableViewCoordinator.swift
//  Template
//
//  Created by stephenmcintosh on 22/6/17.
//  Copyright © 2017 Stephen McIntosh. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class BaseTableViewCoordinator: NSObject {
	open var context: NSManagedObjectContext?
	open var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
	
	var fetchObjects: [Any?] {
		do {
			try self.fetchedResultsController?.performFetch()
			return self.fetchedResultsController?.fetchedObjects ?? []
		} catch {
			return []
		}
	}
	
	var numberofSections: Int {
		get {
			return fetchedResultsController?.sections?.count ?? 0
		}
	}
	
	override init() {
		super.init()
	}
	
	func performFetch() {
		try? self.fetchedResultsController?.performFetch()
	}
	
	func numberOfRowsInSection(_ section: Int) -> Int? {
		return fetchedResultsController?.sections?[section].objects?.count
	}
}
