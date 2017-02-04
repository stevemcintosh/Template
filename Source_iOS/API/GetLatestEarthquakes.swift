import ProcedureKit
import CoreData

class GetLatestEarthquakes: GroupProcedure {
	typealias CompletionBlock = (Void) -> Void
	
	let procedureQueue = ProcedureQueue()
	var completion: CompletionBlock
	var downloadProcedure: DownloadEarthquakes?
	var parseProcedure: ParseJSONEarthquakes?
	
	private var hasProducedAlert = false

	init(context: NSManagedObjectContext, completion: @escaping CompletionBlock) {
		
		let cachesFolder = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
		let cacheFile = cachesFolder.appendingPathComponent("earthquakes.json")

		let downloadProcedure = DownloadEarthquakes(cacheFile: cacheFile)
		let parseProcedure = ParseJSONEarthquakes(cacheFile: cacheFile, context: context)
	
		let finishProcedure = BlockOperation(block: completion)
		
		parseProcedure.add(dependency: downloadProcedure)
		finishProcedure.add(dependency: parseProcedure)
		
		self.completion = completion
		super.init(operations: [downloadProcedure, parseProcedure, finishProcedure])
		
		add(condition: MutuallyExclusive<GetLatestEarthquakes>())
	}

}

