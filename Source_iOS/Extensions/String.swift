import Foundation

private extension String {
	var trimmed: String {
		return (self as NSString).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
}

extension String {
	var asEarthquakeDate: Date? {
		get {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z"
			return dateFormatter.date(from: self)
		}
	}
}
