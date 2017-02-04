import Foundation
import ProcedureKit
import ProcedureKitNetwork

class DownloadEarthquakes: GroupProcedure {
	
	var cacheFile: URL!
	let procedureQueue = ProcedureQueue()
	
	init(cacheFile: URL) {
		super.init(operations: [])
		self.cacheFile = cacheFile
		
		guard let url = URL(string: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson") else { return }
		let request = URLRequest(url: url)
		let network = NetworkProcedure {
			NetworkDataProcedure(session: URLSession.shared, request: request)
		}
		
		// Perform synchronous transform of Data
		let transform = TransformProcedure<Data, URL?> { data in
			do {
				let fileManager = FileManager.default
				if fileManager.fileExists(atPath: cacheFile.absoluteString) {
					try fileManager.removeItem(at: cacheFile)
				}
				try data.write(to: cacheFile, options: .atomic)
				return cacheFile
			} catch {
				return nil
			}
		}.injectPayload(fromNetwork: network)
		
		transform.add(dependency: network)
		procedureQueue.add(operations: network, transform)
	}

	fileprivate func finish(procedure: Procedure, withError: NSError) {
		procedure.cancel(withError: ProcedureKitError.requirementNotSatisfied())
		finish(withError: withError)
	}
}
