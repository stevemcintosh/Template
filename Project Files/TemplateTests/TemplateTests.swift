//
//  TemplateTests.swift
//  TemplateTests
//
//  Created by stephenmcintosh on 17/2/17.
//  Copyright © 2017 Stephen McIntosh. All rights reserved.
//

import CoreData
import ProcedureKit
import UIKit
import XCTest

@testable import Template

class TemplateTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
		let tempExpectation1 = self.expectation(description: "Getting earthquake data, check first value")
		let tempExpectation2 = self.expectation(description: "Getting earthquake data, check last value")

		let procedureQueue = ProcedureQueue()
		let procedure = LoadEarthquakeModel { context in
			let request = NSFetchRequest<NSFetchRequestResult>(entityName: Earthquake.entityName)
			let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
			do {
				try context.persistentStoreCoordinator?.execute(deleteRequest, with: context)
			} catch let error as NSError {
				print(error)
			}
			
			let bundle = Bundle(for: type(of: self))
			let resourceURL = bundle.url(forResource: "earthquakes", withExtension: "json")
			let parseProcedure = ParseJSONEarthquakes(cacheFile: resourceURL!, context: context) {
				request.sortDescriptors = [NSSortDescriptor(
					key: "timestamp",
					ascending: false
					)]
				let count = try? context.fetch(request).count
				print("inserted: \(count)")
				if let earthquake = (try? context.fetch(request))?.first as? Earthquake {
					print(earthquake.identifier, earthquake.name)
					if earthquake.name == "26km WNW of Rock Creek, Alabama" &&
						earthquake.identifier == "us20008ke8" {
						tempExpectation1.fulfill()
					}
				}
				if let earthquake = (try? context.fetch(request))?.last as? Earthquake {
					print(earthquake.identifier, earthquake.name)
					if earthquake.name == "105km ESE of Yakutat, Alaska" &&
						earthquake.identifier == "ak15089704" {
						tempExpectation2.fulfill()
					}
				}
			}
			procedureQueue.add(operation: parseProcedure)
		}
		procedureQueue.add(operation: procedure)
		waitForExpectations(timeout: 60, handler: nil)
	}

}
