import Foundation
import CoreData
import ProcedureKit

private struct ParsedEarthquake {
    // MARK: Properties.
    
    let date: Date
    let identifier, name, link: String
    let depth, latitude, longitude, magnitude: Double
    
    // MARK: Initialization
    init?(feature: [String: AnyObject]) {
        guard let earthquakeID = feature["id"] as? String, !earthquakeID.isEmpty else { return nil }
        identifier = earthquakeID
        
        let properties = feature["properties"] as? [String: AnyObject] ?? [:]
        
        name = properties["place"] as? String ?? ""
        
        link = properties["url"] as? String ?? ""
        
        magnitude = properties["mag"] as? Double ?? 0.0
        
        if let offset = properties["time"] as? Double {
            date = Date(timeIntervalSince1970: offset / 1000)
        }
        else {
            date = Date.distantFuture
        }
        
        let geometry = feature["geometry"] as? [String: AnyObject] ?? [:]
        
        if let coordinates = geometry["coordinates"] as? [Double], coordinates.count == 3 {
            longitude = coordinates[0]
            latitude = coordinates[1]
            
            // `depth` is in km, but we want to store it in meters.
            depth = coordinates[2] * 1000
        }
        else {
            depth = 0
            latitude = 0
            longitude = 0
        }
    }
}

class ParseJSONEarthquakes: Procedure {
    typealias CompletionBlock = () -> Void
    
    let cacheURL: URL
    let context: NSManagedObjectContext
    let completion: CompletionBlock
	
	init(cacheURL: URL, context: NSManagedObjectContext, completion: @escaping CompletionBlock) {
        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
    
        importContext.mergePolicy = NSOverwriteMergePolicy
        
        self.cacheURL = cacheURL
        self.context = importContext
        self.completion = completion

        super.init(disableAutomaticFinishing: false)
        
    }
    
    override func execute() {

        guard !isCancelled else { return }
        
        guard let stream = InputStream(url: cacheURL) else {
            finish()
            return
        }
        
        stream.open()
        
        defer {
            stream.close()
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: stream, options: []) as? [String : AnyObject]
            if let features = json?["features"] as? [[String: AnyObject]] {
                parse(features: features)
            } else {
                finish()
                self.completion()
            }
        }
        catch let jsonError as NSError {
            finish(withError: jsonError)
            self.completion()
        }
    }
    
    private func parse(features: [[String: AnyObject]]) {
        let parsedEarthquakes = features.flatMap { ParsedEarthquake(feature: $0) }
        
        context.perform {
            for newEarthquake in parsedEarthquakes {
                self.insert(parsed: newEarthquake)
            }
            
            let error = self.saveContext()
            self.finish(withError: error)
            self.completion()

        }
    }
    
    private func insert(parsed: ParsedEarthquake) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Earthquake.entityName)
        request.predicate = NSPredicate(format: "identifier = %@", parsed.identifier)
        
        if let _ = (try? context.fetch(request))?.first as? Earthquake {
            return
        } else if let earthquake = NSEntityDescription.insertNewObject(forEntityName: Earthquake.entityName, into: context) as? Earthquake {
			let (date: date, string: _) = Earthquake.ddMMYYYFromDate(date: parsed.date)
			earthquake.sectionIdentifier = date
            earthquake.identifier = parsed.identifier
            earthquake.timestamp = parsed.date
            earthquake.latitude = parsed.latitude
            earthquake.longitude = parsed.longitude
            earthquake.depth = parsed.depth
            earthquake.webLink = parsed.link
            earthquake.name = parsed.name
            earthquake.magnitude = parsed.magnitude
        }
    }
    
    private func saveContext() -> NSError? {
        var error: NSError?
        
        if context.hasChanges {
            do {
                try context.save()
            }
            catch let saveError as NSError {
                error = saveError
            }
        }
        
        return error
    }
}
