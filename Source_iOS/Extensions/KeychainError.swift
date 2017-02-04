import Security

enum KeychainError: Error {
	case unimplemented
	case param
	case allocate
	case notAvailable
	case authFailed
	case duplicateItem
	case itemNotFound
	case interactionNotAllowed
	case decode
	case unknown
	
	static func errorFromOSStatus(_ rawStatus: OSStatus) -> KeychainError? {
		if rawStatus == errSecSuccess {
			return nil
		} else {
			// If the mapping doesn't find a match, return unknown.
			return mapping[rawStatus] ?? .unknown
		}
	}

	static let mapping: [Int32: KeychainError] = [
		errSecUnimplemented: .unimplemented,
		errSecParam: .param,
		errSecAllocate: .allocate,
		errSecNotAvailable: .notAvailable,
		errSecAuthFailed: .authFailed,
		errSecDuplicateItem: .duplicateItem,
		errSecItemNotFound: .itemNotFound,
		errSecInteractionNotAllowed: .interactionNotAllowed,
		errSecDecode: .decode
	]
}
