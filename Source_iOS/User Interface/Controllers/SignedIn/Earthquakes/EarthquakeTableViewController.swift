import Foundation
import CoreLocation
import MapKit
import SafariServices

import ProcedureKit
import ProcedureKitLocation
import ProcedureKitMobile

class EarthquakeTableViewController: TableViewController {
    // MARK: Properties
	
	var procedureQueue: ProcedureQueue?
    var earthquake: Earthquake?
    var locationRequest: ProcedureKitLocation.UserLocationProcedure?
    
    @IBOutlet var map: MKMapView!
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
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = earthquake.coordinate
        map.addAnnotation(annotation)
        
        nameLabel.text = earthquake.name
		magnitudeLabel.text = Earthquake.magnitudeFormatter.string(from: NSNumber(value: earthquake.magnitude))
        depthLabel.text = Earthquake.depthFormatter.string(fromMeters: earthquake.depth)
        timeLabel.text = Earthquake.timestampFormatter.string(from: earthquake.timestamp)
        
		let locationProcedure = ProcedureKitLocation.UserLocationProcedure(timeout: 1.0, accuracy: kCLLocationAccuracyHundredMeters) { [weak weakSelf = self] (location) in
			
			if let earthquakeLocation = weakSelf?.earthquake?.location {
                let distance = location.distance(from: earthquakeLocation)
                weakSelf?.distanceLabel.text = Earthquake.distanceFormatter.string(fromMeters: distance)
            }

			weakSelf?.locationRequest?.stopLocationUpdates()
			weakSelf?.locationRequest?.finish()
		}

		procedureQueue?.addOperation(locationProcedure)
        locationRequest = locationProcedure
    }
	
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // If the LocationOperation is still going on, then cancel it.
        locationRequest?.cancel()
    }
	
    @IBAction func shareEarthquake(sender: UIBarButtonItem) {
        guard let earthquake = earthquake else { return }
        guard let url = NSURL(string: earthquake.webLink) else { return }
        
        let location = earthquake.location
        
        let items = [url, location]
        
        /*
            We could present the share sheet manually, but by putting it inside
            an `Operation`, we can make it mutually exclusive with other operations
            that modify the view controller hierarchy.
        */
        let shareOperation = BlockProcedure {
			DispatchQueue.main.async { [weak weakSelf = self] in
                let shareSheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
                shareSheet.popoverPresentationController?.barButtonItem = sender
                weakSelf?.present(shareSheet, animated: true, completion: nil)
            }
        }
        
        /*
            Indicate that this operation modifies the View Controller hierarchy
            and is thus mutually exclusive.
        */
		shareOperation.add(condition: MutuallyExclusive<UIActivityViewController>())

        procedureQueue?.addOperation(shareOperation)
    }
    
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 1 && indexPath.row == 0 {
			// The user has tapped the "More Information" button.
			if let link = earthquake?.webLink, let url = URL(string: link) {
				// If we have a link, present the "More Information" dialog.
				let moreInformation = MoreInformation(url: url)
				moreInformation.add(condition: MutuallyExclusive<SFSafariViewController>())
				procedureQueue?.add(operation: moreInformation)
			} else {
				// No link; present an alert.
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
}

extension EarthquakeTableViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let earthquake = earthquake else { return nil }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        
        view = view ?? MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        
        guard let pin = view else { return nil }
        
        switch earthquake.magnitude {
            case 0..<3: pin.pinTintColor = UIColor.gray
            case 3..<4: pin.pinTintColor = UIColor.blue
            case 4..<5: pin.pinTintColor = UIColor.orange
            default:    pin.pinTintColor = UIColor.red
        }
        
        pin.isEnabled = false

        return pin
    }
}
