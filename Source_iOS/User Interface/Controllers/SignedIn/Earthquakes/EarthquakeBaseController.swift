import Foundation
import CoreLocation
import MapKit
import SafariServices

import ProcedureKit
import ProcedureKitLocation
import ProcedureKitMobile

public struct LocationPlacemark: Equatable {
	public static func == (lhs: LocationPlacemark, rhs: LocationPlacemark) -> Bool {
		return lhs.location == rhs.location && lhs.placemark == rhs.placemark
	}
	public let location: CLLocation
	public let placemark: CLPlacemark
}

class EarthquakeBaseController: TableViewController {
    // MARK: Properties
    var earthquake: Earthquake?

    private var locationProcedure: ProcedureKitLocation.UserLocationProcedure?
	private var placeMark: MKPlacemark?
	
	fileprivate struct Constants {
		static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
		static let AnnotationViewReuseIdentifier = "pin"
		static let ShowImageSegue = "ShowImageSegue"
		static let EditUserWaypoint = "Edit Earthquake"
	}
	
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
		
		let locationProcedure = UserLocationProcedure(timeout: 60.0, accuracy: kCLLocationAccuracyHundredMeters) { [weak self] (location) in
			
			if let earthquakeLocation = self?.earthquake?.location {
                let distance = location.distance(from: earthquakeLocation)
                self?.distanceLabel.text = Earthquake.distanceFormatter.string(fromMeters: distance)
            }

			self?.locationProcedure?.finish()
		}

		locationProcedure.add(observer: NetworkObserver())
		procedureQueue.addOperation(locationProcedure)
        self.locationProcedure = locationProcedure
    }
	
    override func viewWillDisappear(_ animated: Bool) {
        // If the locationProcedure is still going on, then cancel it.
        locationProcedure?.cancel()
		super.viewWillDisappear(animated)
    }
	
    @IBAction func shareEarthquake(sender: UIBarButtonItem) {
        guard let earthquake = earthquake else { return }
		guard let url = NSURL(string: earthquake.webLink)
		else { return }
		
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

        procedureQueue.addOperation(shareOperation)
    }
    
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 1 && indexPath.row == 0 {
			// The user has tapped the "More Information" button.
			if let link = earthquake?.webLink, let url = URL(string: link) {
				let moreInformation = MoreInformation(url: url)
				moreInformation.add(condition: MutuallyExclusive<SFSafariViewController>())
				procedureQueue.add(operation: moreInformation)
			} else {
				let alert = AlertProcedure(presentAlertFrom: self, waitForDismissal: true)
				alert.add(actionWithTitle: "Ok") { alert, action in
					alert.log.info(message: "Running the handler!")
				}
				alert.title = "No Information"
				alert.message = "Please select an earthquake and try again"
				procedureQueue.add(operation: alert)
			}
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
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
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//		var imageData: Data?
//		let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton
//
//		let operation = BlockProcedure {
//			guard let url = (view.annotation as? Earthquake.Waypoint)?.thumbnailURL else { return }
//			imageData = try? Data(contentsOf: url as URL)
//		}
//
//		operation.add(observer: BlockObserver(didFinish: { _, errors in
//			DispatchQueue.main.async {
//				if imageData != nil {
//					let image = UIImage(data: imageData!)
//					thumbnailImageButton?.setImage(image, for: UIControlState())
//				}
//				operation.finish(withErrors: errors)
//			}
//		}))
//
//		procedureQueue.addOperation(operation)
	}
	
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if control == view.leftCalloutAccessoryView {
			let operation = BlockProcedure {
				DispatchQueue.main.async { [weak weakSelf = self] in
					weakSelf?.performSegue(withIdentifier: EarthquakeBaseController.Constants.ShowImageSegue, sender: weakSelf?.view)
				}
			}
			
			operation.add(observer: BlockObserver(didFinish: { _, errors in
				DispatchQueue.main.async {
					operation.finish(withErrors: errors)
				}
			}))
			procedureQueue.addOperation(operation)
		} else if control == view.rightCalloutAccessoryView  {
			let operation = BlockProcedure {
				DispatchQueue.main.async {
					mapView.deselectAnnotation(view.annotation, animated: true)
				}
			}
			operation.add(observer: BlockObserver(didFinish: { _, errors in
				DispatchQueue.main.async { [weak weakSelf = self] in
					weakSelf?.performSegue(withIdentifier: EarthquakeBaseController.Constants.EditUserWaypoint, sender: view)
					operation.finish(withErrors: errors)
				}
			}))
			procedureQueue.addOperation(operation)
		}
	}
}