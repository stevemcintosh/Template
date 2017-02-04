import UIKit

extension UIColor {
	static var globalTintColor: UIColor? {
		return UIApplication.shared.keyWindow?.tintColor
	}
}
