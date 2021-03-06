/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
The Earthquake model object.
*/

import Foundation
import CoreData
import CoreLocation

/*
    An `NSManagedObject` subclass to model basic earthquake properties. This also
    contains some convenience methods to aid in formatting the information.
*/
class Earthquake: NSManagedObject {
    // MARK: Static Properties

    static let entityName = "Earthquake"
    
    // MARK: Formatters

    static let datetimestampFormatter: DateFormatter = {
        let datetimestampFormatter = DateFormatter()
		datetimestampFormatter.locale = Locale.current
		datetimestampFormatter.timeZone = TimeZone.autoupdatingCurrent
		datetimestampFormatter.dateStyle = .medium
        datetimestampFormatter.timeStyle = .medium

        return datetimestampFormatter
    }()
	
	static func ddMMYYYFromDate(date: Date) -> (date: Date?, string: String?) {
		guard let calendar = NSCalendar(identifier: .gregorian) else { return (nil, nil) }
		let components = calendar.components([.month, .day, .year], from: date)
		guard let date = calendar.date(from: components) else { return (nil, nil) }
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale.current
		dateFormatter.timeZone = TimeZone.autoupdatingCurrent
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		return (date, dateFormatter.string(from: date))
	}
	
    static let magnitudeFormatter: NumberFormatter = {
        let magnitudeFormatter = NumberFormatter()
        
        magnitudeFormatter.numberStyle = .decimal
        magnitudeFormatter.maximumFractionDigits = 1
        magnitudeFormatter.minimumFractionDigits = 1

        return magnitudeFormatter
    }()
    
    static let depthFormatter: LengthFormatter = {
        
        let depthFormatter = LengthFormatter()
        depthFormatter.isForPersonHeightUse = false

        return depthFormatter
    }()
    
    static let distanceFormatter: LengthFormatter = {
        let distanceFormatter = LengthFormatter()

        distanceFormatter.isForPersonHeightUse = false
        distanceFormatter.numberFormatter.maximumFractionDigits = 2
        
        return distanceFormatter
    }()

    // MARK: Properties
    @NSManaged public var sectionIdentifier: Date?
    @NSManaged var identifier: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var name: String
    @NSManaged var magnitude: Double
    @NSManaged var timestamp: Date
    @NSManaged var depth: Double
    @NSManaged var webLink: String
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var location: CLLocation {
        return CLLocation(coordinate: coordinate, altitude: -depth, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: timestamp as Date)
    }
    
    class Waypoint: NSObject {
        var latitude: Double
        var longitude: Double
        var name: String?
        var info: String?
        
        init(latitude: Double, longitude: Double, name: String?, info: String?) {
            self.latitude = latitude
            self.longitude = longitude
            self.name = name
            self.info = info
            super.init()
        }
        
        override var description: String {
            return ["lat=\(latitude)", "lon=\(longitude)", super.description].joined(separator: " ")
        }
    }
    
    override var description: String {
        let descriptions = [String]()
        return descriptions.joined(separator: "\n")
    }
}
