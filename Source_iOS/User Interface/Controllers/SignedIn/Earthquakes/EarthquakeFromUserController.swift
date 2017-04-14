import Foundation
import CoreLocation
import MapKit
import SafariServices

import ProcedureKit
import ProcedureKitLocation
import ProcedureKitMobile

public struct UserLocationPlacemark: Equatable {
	public static func == (lhs: UserLocationPlacemark, rhs: UserLocationPlacemark) -> Bool {
		return lhs.location == rhs.location && lhs.placemark == rhs.placemark
	}
	public let location: CLLocation
	public let placemark: CLPlacemark
}

class EarthquakeFromUserController: EarthquakeBaseController {
    // MARK: Properties
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	// MARK: View Controller
	
	fileprivate struct Constants {
		static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59) // sad face
		static let AnnotationViewReuseIdentifier = "pin"
		static let EditUserWaypoint = "Edit Earthquake"
	}
}

extension EarthquakeFromUserController {
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//		let imageData: Data?
//		let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton
//
//		let operation = BlockProcedure {
//			guard let url = (view.annotation as? Earthquake.Waypoint)?.thumbnailURL else { return }
//			imageData = try? Data(contentsOf: url as URL)
//		}
		
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
//		procedureQueue?.addOperation(operation)
	}
	
	
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if control == view.leftCalloutAccessoryView {
			let operation = BlockProcedure {
				DispatchQueue.main.async {// [weak weakSelf = self] in
//					weakSelf?.performSegue(withIdentifier: EarthquakeFromUserController.Constants.ShowImageSegue, sender: weakSelf?.view)
				}
			}
			
			operation.add(observer: BlockObserver(didFinish: { _, errors in
				DispatchQueue.main.async {
					operation.finish(withErrors: errors)
				}
			}))
			procedureQueue?.addOperation(operation)
		} else if control == view.rightCalloutAccessoryView  {
			let operation = BlockProcedure {
				DispatchQueue.main.async {
					mapView.deselectAnnotation(view.annotation, animated: true)
				}
			}
			operation.add(observer: BlockObserver(didFinish: { _, errors in
				DispatchQueue.main.async { [weak weakSelf = self] in
					weakSelf?.performSegue(withIdentifier: EarthquakeFromUserController.Constants.EditUserWaypoint, sender: view)
					operation.finish(withErrors: errors)
				}
			}))
			procedureQueue?.addOperation(operation)
		}
	}
}
