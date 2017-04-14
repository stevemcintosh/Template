import Foundation
import CoreLocation
import MapKit
import SafariServices

import ProcedureKit
import ProcedureKitLocation
import ProcedureKitMobile

class EarthquakeBaseController: TableViewController {
    // MARK: Properties
	
	var procedureQueue: ProcedureQueue?
    var earthquake: Earthquake?

    private var locationProcedure: ProcedureKitLocation.UserLocationProcedure?
	private var placeMark: MKPlacemark?
	
	@IBOutlet var map: MKMapView! {
		didSet {
			map.mapType = .standard
			map.delegate = self
		}
	}
	
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var magnitudeLabel: UILabel!
    @IBOutlet var depthLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	// MARK: View Controller
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		// Default all labels if there's no earthquake.
        guard let earthquake = earthquake else {
            nameLabel.text = ""
            magnitudeLabel.text = ""
            depthLabel.text = ""
            timeLabel.text = ""
            distanceLabel.text = ""

            return
        }
		
		title = earthquake.name

        let span = MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)
        map.region = MKCoordinateRegion(center: earthquake.coordinate, span: span)
        
		let annotation = Earthquake.Waypoint(latitude: earthquake.coordinate.latitude,
		                                     longitude: earthquake.coordinate.longitude,
		                                     name: earthquake.name,
		                                     info: "\(earthquake.magnitude.description) on the Ricter scale")
        map.addAnnotation(annotation)
        
        nameLabel.text = earthquake.name
		magnitudeLabel.text = Earthquake.magnitudeFormatter.string(from: NSNumber(value: earthquake.magnitude))
        depthLabel.text = Earthquake.depthFormatter.string(fromMeters: earthquake.depth)
        timeLabel.text = Earthquake.timestampFormatter.string(from: earthquake.timestamp)
		
		let locationProcedure = UserLocationProcedure(timeout: 10.0, accuracy: kCLLocationAccuracyHundredMeters) { [weak weakSelf = self] (location) in
			
			if let earthquakeLocation = weakSelf?.earthquake?.location {
                let distance = location.distance(from: earthquakeLocation)
                weakSelf?.distanceLabel.text = Earthquake.distanceFormatter.string(fromMeters: distance)
            }

			weakSelf?.locationProcedure?.finish()
		}

		locationProcedure.add(observer: NetworkObserver())
		procedureQueue?.addOperation(locationProcedure)
        self.locationProcedure = locationProcedure
    }
	
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // If the locationProcedure is still going on, then cancel it.
        locationProcedure?.cancel()
    }
	
    @IBAction func shareEarthquake(sender: UIBarButtonItem) {
        guard let earthquake = earthquake else { return }
        guard let url = NSURL(string: earthquake.webLink) else { return }
        
        let location = earthquake.location
        
        let items = [url, location]
        
        let shareOperation = BlockProcedure {
			DispatchQueue.main.async { [weak weakSelf = self] in
                let shareSheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
                shareSheet.popoverPresentationController?.barButtonItem = sender
                weakSelf?.present(shareSheet, animated: true, completion: nil)
            }
        }
        
		shareOperation.add(condition: MutuallyExclusive<UIActivityViewController>())

        procedureQueue?.addOperation(shareOperation)
    }
    
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 1 && indexPath.row == 0 {
			// The user has tapped the "More Information" button.
			if let link = earthquake?.webLink, let url = URL(string: link) {
				let moreInformation = MoreInformation(url: url)
				moreInformation.add(condition: MutuallyExclusive<SFSafariViewController>())
				procedureQueue?.add(operation: moreInformation)
			} else {
				let alert = AlertProcedure(presentAlertFrom: self, waitForDismissal: true)
				alert.add(actionWithTitle: "Ok") { alert, action in
					alert.log.info(message: "Running the handler!")
				}
				alert.title = "No Information"
				alert.message = "Please select an earthquake and try again"
				if self.procedureQueue == nil { self.procedureQueue = ProcedureQueue() }
				procedureQueue?.add(operation: alert)
			}
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	fileprivate struct Constants {
		static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
		static let AnnotationViewReuseIdentifier = "pin"
	}
}

extension EarthquakeBaseController: MKMapViewDelegate {
	
	internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let earthquake = earthquake else { return nil }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: EarthquakeBaseController.Constants.AnnotationViewReuseIdentifier) as? MKPinAnnotationView
        
		if view == nil {
			view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: EarthquakeBaseController.Constants.AnnotationViewReuseIdentifier)
			view?.canShowCallout = true

		} else {
			view?.annotation = annotation
		}
		
		guard let pin = view else { return nil }
		
		view?.isEnabled = true
		view?.isDraggable = annotation is EditableEarthquakepoint
		view?.leftCalloutAccessoryView = nil
		view?.rightCalloutAccessoryView = nil

		switch earthquake.magnitude {
            case 0..<3: pin.pinTintColor = UIColor.gray
            case 3..<4: pin.pinTintColor = UIColor.blue
            case 4..<5: pin.pinTintColor = UIColor.orange
            default:    pin.pinTintColor = UIColor.red
        }
        
        return pin
    }	
}
