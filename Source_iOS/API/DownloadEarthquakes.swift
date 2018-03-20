import Foundation
import ProcedureKit

class DownloadEarthquakes: GroupProcedure {
    
    var cacheURL: URL!
    
    init(cacheURL: URL) {
        super.init(operations: [])
        self.cacheURL = cacheURL
        
        guard let url = URL(string: "http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson") else { return }
        let request = URLRequest(url: url)
        
        let network = NetworkProcedure {
            NetworkDataProcedure(session: URLSession.shared, request: request)
        }
        
        // Perform synchronous transform of Data
        let transform = TransformProcedure<Data, URL?> { data in
            do {
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: cacheURL.path) {
                    try fileManager.removeItem(at: cacheURL)
                }
                try data.write(to: cacheURL, options: .atomic)
                return cacheURL
            } catch {
                self.finish(withError: ProcedureKitError.requirementNotSatisfied())
                return nil
            }
        }.injectPayload(fromNetwork: network)
        
        transform.add(dependency: network)
        add(children: [network, transform])
		
		//
//		guard let url2 = URL(string: "http://rp.stevemcintosh.tk:8080/api/hello") else { return }
//		let request2 = URLRequest(url: url2)
//
//		let network2 = NetworkProcedure {
//			NetworkDataProcedure(session: URLSession.shared, request: request2)
//		}
//
//		// Perform synchronous transform of Data
//		let transform2 = TransformProcedure<Data, URL?> { data in
//			do {
//				let fileManager = FileManager.default
//				if fileManager.fileExists(atPath: cacheURL.path) {
//					try fileManager.removeItem(at: cacheURL)
//				}
//				//try data.write(to: cacheURL, options: .atomic)
//				return cacheURL
//			} catch {
//				self.finish(withError: ProcedureKitError.requirementNotSatisfied())
//				return nil
//			}
//			}.injectPayload(fromNetwork: network2)
//		
//		transform2.add(dependency: network2)
//		add(children: [network2, transform2])
    }

    fileprivate func finish(procedure: Procedure, withError: NSError) {
        procedure.cancel(withError: ProcedureKitError.requirementNotSatisfied())
        finish(withError: withError)
    }
}
