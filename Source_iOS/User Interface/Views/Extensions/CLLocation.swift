//
//  CLLocation.swift
//  Template
//
//  Created by stephenmcintosh on 23/7/17.
//  Copyright © 2017 Stephen McIntosh. All rights reserved.
//

import Foundation
import MapKit

extension CLLocation {
	public static func == (lhs: CLLocation, rhs: CLLocation) -> Bool {
		return (lhs.altitude == rhs.altitude &&
			lhs.coordinate.latitude == rhs.coordinate.latitude &&
			lhs.coordinate.longitude == rhs.coordinate.longitude)
	}
}
