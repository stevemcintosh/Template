import Security
import Foundation

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

enum DigitalAssetError: Error {
	case serviceNameMissing
	case usernameMissing
	case passwordMissing
}

struct DigitalAsset {
	
	var loginID : String
	var password : String
	var serviceName : String
	
	init(loginID : String, password : String, serviceName : String) {
		self.loginID = loginID
		self.password = password
		self.serviceName = serviceName
	}
}


let SecurityManagerService = "Template-iOS"

class KeyChain {
	
	static var prefix: String {
		get {
			return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
		}
	}

	class func baseAttributesForAccount(account: String) -> NSMutableDictionary {
		return [kSecClass as NSString: kSecClassGenericPassword,
		        kSecAttrService as NSString: prefix + SecurityManagerService,
		        kSecAttrAccount as NSString: account]
	}
	
	class func loadDigitalAssets() -> [DigitalAsset]? {
		var returnArray: Array = [DigitalAsset]()
		
		do {
			if let facebook: DigitalAsset = try KeyChain.getDigitalAsset(serviceName: "Facebook") {
				returnArray.append(facebook)
			}
		} catch { }
		
		do {
			if let twitter: DigitalAsset = try KeyChain.getDigitalAsset(serviceName: "Twitter") {
				returnArray.append(twitter)
			}
		} catch { }
		
		return returnArray
	}

	class private func getDigitalAsset(serviceName: String) throws -> DigitalAsset? {

		// Attempt to get DigitalAsset attributes
		let baseDigitalAssetAttributes: NSMutableDictionary = KeyChain.baseAttributesForAccount(account: serviceName)
		baseDigitalAssetAttributes[kSecReturnData as NSString] = true
		
		var extractedData: AnyObject?
		let status = SecItemCopyMatching(baseDigitalAssetAttributes, &extractedData)
		if let error = KeychainError.errorFromOSStatus(status) {
			throw error
		}
		
		if status == errSecSuccess {
			guard let retrievedData = extractedData as? NSData else { return nil }
			do {
				if let digitalAssetInfo = try JSONSerialization.jsonObject(with: retrievedData as Data, options: .allowFragments) as? [String : AnyObject] {
					guard let serviceName = digitalAssetInfo["serviceName"] as? String else { throw DigitalAssetError.serviceNameMissing }
					
					let digitalAsset = DigitalAsset(loginID: digitalAssetInfo["username"] as? String ?? "", password: digitalAssetInfo["password"] as? String ?? "", serviceName: serviceName)
					
					return digitalAsset
				} else {
					return nil
				}
			} catch {
				throw error
			}
		}
		return nil
	}
	
	class func saveDigitalAsset(digitalAsset: DigitalAsset) throws {

		let digitalAssetInfo: Dictionary = ["serviceName" : digitalAsset.serviceName,
		                                    "username" : digitalAsset.loginID,
		                                    "password" : digitalAsset.password]

		let DigitalAssetAttributes: NSMutableDictionary = KeyChain.baseAttributesForAccount(account: digitalAsset.serviceName)
		do {
			let DigitalAssetData: NSData = try JSONSerialization.data(withJSONObject: digitalAssetInfo, options: .prettyPrinted) as NSData
			DigitalAssetAttributes[kSecValueData as NSString] = DigitalAssetData
			DigitalAssetAttributes[kSecAttrAccessible as NSString] = kSecAttrAccessibleWhenUnlocked
			
			// Check if the key exists
			let addStatus: OSStatus = SecItemAdd(DigitalAssetAttributes, nil)
			if addStatus == errSecDuplicateItem {
				DigitalAssetAttributes.removeObject(forKey: kSecValueData as NSString)
				let updateAttributes: Dictionary = [kSecValueData as NSString: DigitalAssetData]
				let addStatus: OSStatus = SecItemUpdate(DigitalAssetAttributes, updateAttributes as CFDictionary)
				if addStatus != errSecSuccess {
					print("There was a problem updating the digitalAsset information for \(digitalAsset.serviceName).")
					throw KeychainError.itemNotFound
				}
			} else if addStatus != errSecSuccess {
				print("There was a problem adding the digitalAsset \(digitalAsset.serviceName) to the keychain")
				throw KeychainError.unknown
			}
		} catch let error {
			throw error
		}
	}
}
