import ProcedureKit
import CoreData

struct LoadEarthquakeModelComponent: ProcedureKitComponent {
    let name = "LoadEarthquakeModelContext"
}

enum LoadEarthquakeModelError: Error {
    case none
    case myError
}

class LoadEarthquakeModel: Procedure, OutputProcedure {
    typealias CompletionBlock = (NSManagedObjectContext) -> Void

    let completion: CompletionBlock
    var output: Pending<ProcedureResult<NSManagedObjectContext>> = .pending
	
    init(completion: @escaping (NSManagedObjectContext) -> Void) {
        self.completion = completion
        super.init()
        name = "EarthquakeDataRetrieval"
        add(condition: MutuallyExclusive<LoadEarthquakeModel>())
    }
    
    override func execute() {
        
        guard !isCancelled else { return }
        
		var model: NSManagedObjectModel! = nil
		if let existingModelURL = Bundle.main.url(forResource: "Earthquakes", withExtension: "momd") {
			model = NSManagedObjectModel(contentsOf: existingModelURL)
		} else {
			model = NSManagedObjectModel.mergedModel(from: nil)
		}
		
		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
		let context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
		
		let cachesFolder2 = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let storeURL2 = cachesFolder2.appendingPathComponent("earthquakes.sqlite")
		do {
			try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL2, options: nil)
			context.persistentStoreCoordinator = persistentStoreCoordinator
			completion(context)
			output = .ready(.success(context))
			finish()
			return

		} catch {
			let pkerror = ProcedureKitError.component(LoadEarthquakeModelComponent(), error: error)
			output = .ready(.failure(pkerror))
			finish(withError: pkerror)
		}
    }    
}

struct EarthquakeModelContext {
	
	var context: NSManagedObjectContext? {
		var model: NSManagedObjectModel! = nil
		if let existingModelURL = Bundle.main.url(forResource: "Earthquakes", withExtension: "momd") {
			model = NSManagedObjectModel(contentsOf: existingModelURL)
		} else {
			model = NSManagedObjectModel.mergedModel(from: nil)
		}
		
		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
		let context2 = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
		
		let cachesFolder2 = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let storeURL2 = cachesFolder2.appendingPathComponent("earthquakes.sqlite")
		do {
			try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL2, options: nil)
			context2.persistentStoreCoordinator = persistentStoreCoordinator
			return context2
		} catch {
			return nil
		}
	}
}
