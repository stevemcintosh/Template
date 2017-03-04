import ProcedureKit
import Dispatch
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

	let completion: CompletionBlock?
	var output: Pending<ProcedureResult<NSManagedObjectContext>> = .pending
	
	init(completion: @escaping (NSManagedObjectContext) -> Void) {
		self.completion = completion
		super.init()
		name = "EarthquakeDataRetrieval"
		add(condition: MutuallyExclusive<LoadEarthquakeModel>())
	}
	
	override func execute() {
		
		guard !isCancelled else { return }
		
		let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		
		let storeURL = cachesFolder.appendingPathComponent("earthquakes.sqlite")
		
		let model = NSManagedObjectModel.mergedModel(from: nil)!
		
		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
		
		let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.persistentStoreCoordinator = persistentStoreCoordinator
		
		var error = createStore(persistentStoreCoordinator: persistentStoreCoordinator, atURL: storeURL as NSURL?)
		
		if persistentStoreCoordinator.persistentStores.isEmpty {
			/*
			Our persistent store does not contain irreplaceable data (which
			is why it's in the Caches folder). If we fail to add it, we can
			delete it and try again.
			*/
			destroyStore(persistentStoreCoordinator: persistentStoreCoordinator, atURL: storeURL as NSURL)
			error = createStore(persistentStoreCoordinator: persistentStoreCoordinator, atURL: storeURL as NSURL?)
		}
		
		if persistentStoreCoordinator.persistentStores.isEmpty {
			print("Error creating SQLite store: \(error).")
			print("Falling back to `.InMemory` store.")
			error = createStore(persistentStoreCoordinator: persistentStoreCoordinator, atURL: nil, type: NSInMemoryStoreType)
		}
		
		if !persistentStoreCoordinator.persistentStores.isEmpty {
			completion!(context)
			output = .ready(.success(context))
			finish()
			return
		}
		let pkerror = ProcedureKitError.component(LoadEarthquakeModelComponent(), error: error)
		output = .ready(.failure(pkerror))
		finish(withError: pkerror)
	}
	
	fileprivate func createStore(persistentStoreCoordinator: NSPersistentStoreCoordinator, atURL URL: NSURL?, type: String = NSSQLiteStoreType) -> NSError? {
		var error: NSError?
		do {
			let _ = try persistentStoreCoordinator.addPersistentStore(ofType: type, configurationName: nil, at: URL as URL?, options: nil)
		}
		catch let storeError as NSError {
			error = storeError
		}
		
		return error
	}
	
	fileprivate func destroyStore(persistentStoreCoordinator: NSPersistentStoreCoordinator, atURL URL: NSURL, type: String = NSSQLiteStoreType) {
		do {
			let _ = try persistentStoreCoordinator.destroyPersistentStore(at: URL as URL, ofType: type, options: nil)
		}
		catch { }
	}
}
