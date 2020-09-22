/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A UITableViewCell to display the high-level information of an earthquake
*/

import UIKit

class EarthquakeTableViewCell: TableViewCell {
    // MARK: Properties

    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var magnitudeLabel: UILabel!
    @IBOutlet var magnitudeImage: UIImageView!
    
	
	// MARK: Configuration
	
	override func prepareForReuse() {
		super.prepareForReuse()
		initializeCell()
	}
	
    func configure(earthquake: Earthquake) {
		
		locationLabel.text = earthquake.name
		locationLabel.textColor = LabelTextColor.color

		let timestamp = earthquake.timestamp
		timestampLabel.text = Earthquake.datetimestampFormatter.string(from: timestamp)
		timestampLabel.textColor = LabelTextColor.color

		magnitudeLabel.text = Earthquake.magnitudeFormatter.string(from: NSNumber(value: earthquake.magnitude))
		magnitudeLabel.textColor = LabelTextColor.color
		
        let imageName: String
        
        switch earthquake.magnitude {
            case 0..<2: imageName = ""
            case 2..<3: imageName = "2.0"
            case 3..<4: imageName = "3.0"
            case 4..<5: imageName = "4.0"
            default:    imageName = "5.0"
        }

        magnitudeImage.image = UIImage(named: imageName)
    }

}

private extension EarthquakeTableViewCell {
	func initializeCell() {
		locationLabel.text = nil
		timestampLabel.text = nil
		magnitudeLabel.text = nil
		magnitudeImage.image = nil
	}
}

