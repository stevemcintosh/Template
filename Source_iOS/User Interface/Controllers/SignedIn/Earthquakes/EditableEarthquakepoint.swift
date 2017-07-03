import MapKit

class EditableEarthquakepoint : Earthquake.Waypoint {
    override var coordinate: CLLocationCoordinate2D {
        get {
            return super.coordinate
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
}

class Link {
	var href: String
	var linkattributes = [String:String]()
	
	init(href: String) { self.href = href }
	
	var url: NSURL? { return NSURL(string: href) }
	var text: String? { return linkattributes["text"] }
	var type: String? { return linkattributes["type"] }
	
	var description: String {
		var descriptions = [String]()
		descriptions.append("href=\(href)")
		if linkattributes.count > 0 { descriptions.append("linkattributes=\(linkattributes)") }
		return descriptions.reduce("[", +)
	}
}

extension Earthquake.Waypoint : MKAnnotation {
	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
	var title: String? { return name }	
	var subtitle: String? { return info }	
	
	var thumbnailURL: NSURL? { return getImageURLofType(type: "thumbnail") }
	var imageURL: NSURL? { return getImageURLofType(type: "large") }
	
	private func getImageURLofType(type: String) -> NSURL? {
//		for link in links {
//			if link.type == type {
//				return link.url
//			}
//		}
		return nil
	}
}
