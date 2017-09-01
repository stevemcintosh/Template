import ProcedureKit
import CoreData

class GetLatestEarthquakes: GroupProcedure {
	typealias CompletionBlock = () -> Void
	
	init(context: NSManagedObjectContext, completion: @escaping CompletionBlock) {
		let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let cacheURL = cachesFolder.appendingPathComponent("earthquakes.json")

		let downloadProcedure = DownloadEarthquakes(cacheURL: cacheURL)
		let parseProcedure = ParseJSONEarthquakes(cacheURL: cacheURL, context: context) {
			completion()
		}
		
		parseProcedure.add(dependency: downloadProcedure)
		
		downloadProcedure.add(observer: NetworkObserver())
		parseProcedure.add(observer: NetworkObserver())

		super.init(operations: [downloadProcedure, parseProcedure])
		
		add(condition: MutuallyExclusive<GetLatestEarthquakes>())
	}

}

