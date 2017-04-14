import UIKit

extension UIColor {
    
	static var globalTintColor: UIColor? {
		return UIApplication.shared.keyWindow?.tintColor
	}
    class var cerulean: UIColor {
        return UIColor(red: 6.0 / 255.0, green: 141.0 / 255.0, blue: 202.0 / 255.0, alpha: 1.0)
    }
    
    class var steelGrey: UIColor {
        return UIColor(red: 110.0 / 255.0, green: 130.0 / 255.0, blue: 139.0 / 255.0, alpha: 1.0)
    }
    
    class var black: UIColor {
        return UIColor(white: 51.0 / 255.0, alpha: 1.0)
    }
    
    class var gunmetal: UIColor {
        return UIColor(red: 83.0 / 255.0, green: 97.0 / 255.0, blue: 103.0 / 255.0, alpha: 1.0)
    }
    
    class var green: UIColor {
        return UIColor(red: 0.0, green: 168.0 / 255.0, blue: 123.0 / 255.0, alpha: 1.0)
    }
    
    class var silver: UIColor {
        return UIColor(red: 228.0 / 255.0, green: 229.0 / 255.0, blue: 230.0 / 255.0, alpha: 1.0)
    }
    
    class var almostWhite: UIColor {
        return UIColor(red: 248.0 / 255.0, green: 250.0 / 255.0, blue: 251.0 / 255.0, alpha: 1.0)
    }
    
    class var dark80: UIColor {
        return UIColor(red: 20.0 / 255.0, green: 23.0 / 255.0, blue: 25.0 / 255.0, alpha: 0.8)
    }
    
    class var charcoalGrey: UIColor {
        return UIColor(red: 39.0 / 255.0, green: 47.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
    }
    
    class var almostBlack: UIColor {
        return UIColor(red: 11.0 / 255.0, green: 12.0 / 255.0, blue: 12.0 / 255.0, alpha: 1.0)
    }
    
}
