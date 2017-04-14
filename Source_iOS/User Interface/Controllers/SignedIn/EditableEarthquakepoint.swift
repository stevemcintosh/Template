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

extension Earthquake.Waypoint : MKAnnotation {
	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
	var title: String? { return name }	
	var subtitle: String? { return info }
}
