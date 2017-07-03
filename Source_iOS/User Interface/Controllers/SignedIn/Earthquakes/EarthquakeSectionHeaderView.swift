/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
A UITableViewCell to display the high-level information of an earthquake
*/

import UIKit

class EarthquakeSectionHeaderView: TableViewCell {
    // MARK: Properties
	@IBOutlet weak var sectionTitle: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		self.initialise()
		separatorInset = UIEdgeInsets.zero
		preservesSuperviewLayoutMargins = false
	}
	
	override var layoutMargins: UIEdgeInsets {
		get { return UIEdgeInsets.zero }
		set (newVal) { }
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		self.initialise()
	}
}

private extension EarthquakeSectionHeaderView {
	func initialise() {
		self.sectionTitle.text = nil
	}
}
