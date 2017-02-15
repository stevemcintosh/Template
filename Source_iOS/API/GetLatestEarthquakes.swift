import ProcedureKit
import CoreData

class GetLatestEarthquakes: GroupProcedure {
	typealias CompletionBlock = (Void) -> Void
	
	init(context: NSManagedObjectContext, completion: @escaping CompletionBlock) {
		let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let cacheFile = cachesFolder.appendingPathComponent("earthquakes.json")

		let downloadProcedure = DownloadEarthquakes(cacheFile: cacheFile)
		let parseProcedure = ParseJSONEarthquakes(cacheFile: cacheFile, context: context) {
			completion()
		}
		
		parseProcedure.add(dependency: downloadProcedure)
		
		downloadProcedure.add(observer: NetworkObserver(controller: NetworkActivityController.shared))
		parseProcedure.add(observer: NetworkObserver(controller: NetworkActivityController.shared))

		super.init(operations: [downloadProcedure, parseProcedure])
		
		add(condition: MutuallyExclusive<GetLatestEarthquakes>())
	}

}

