#if os(iOS)
	
	import UIKit
	import ProcedureKit
	
	private let RemoteNotificationQueue = OperationQueue()
	private let RemoteNotificationName = "RemoteNotificationPermissionNotification"
	
	private enum RemoteRegistrationResult {
		case token(Data)
		case error(NSError)
	}
	
	/// A condition for verifying that the app has the ability to receive push notifications.
	struct RemoteNotificationCondition: OperationCondition {
		/// Evaluate the condition, to see if it has been satisfied or not.

		static let name = "RemoteNotification"
		static let isMutuallyExclusive = false
		
		static func didReceiveNotificationToken(_ token: Data) {
			NotificationCenter.defaultCenter.postNotificationName(RemoteNotificationName, object: nil, userInfo: [
				"token": token
				])
		}
		
		static func didFailToRegister(_ error: NSError) {
			NotificationCenter.defaultCenter.postNotificationName(RemoteNotificationName, object: nil, userInfo: [
				"error": error
				])
		}
		
		let application: UIApplication
		
		init(application: UIApplication) {
			self.application = application
		}
		
		func dependencyForOperation(_ operation: Operation) -> Operation? {
			return RemoteNotificationPermissionOperation(application: application, handler: { _ in })
		}
		
		internal func evaluateForOperation(_ operation: Operation, completion: @escaping (OperationConditionResult) -> Void) {
			/*
			Since evaluation requires executing an operation, use a private operation
			queue.
			*/
			RemoteNotificationQueue.addOperation(RemoteNotificationPermissionOperation(application: application) { result in
				switch result {
				case .token(_):
					completion(.satisfied)
					
				case .error(let underlyingError):
					let error = NSError(domain: "", code: .ConditionFailed, userInfo: [
						OperationConditionKey: type(of: self).name,
						NSUnderlyingErrorKey: underlyingError
						])
					
					completion(.Failed(error))
				}
			})
		}
	}
	
	/**
	A private `Operation` to request a push notification token from the `UIApplication`.
	
	- note: This operation is used for *both* the generated dependency **and**
	condition evaluation, since there is no "easy" way to retrieve the push
	notification token other than to ask for it.
	
	- note: This operation requires you to call either `RemoteNotificationCondition.didReceiveNotificationToken(_:)` or
	`RemoteNotificationCondition.didFailToRegister(_:)` in the appropriate
	`UIApplicationDelegate` method, as shown in the `AppDelegate.swift` file.
	*/
	private class RemoteNotificationPermissionOperation: ProcedureKit.Procedure {
		let application: UIApplication
		fileprivate let handler: (RemoteRegistrationResult) -> Void
		
		fileprivate init(application: UIApplication, handler: @escaping (RemoteRegistrationResult) -> Void) {
			self.application = application
			self.handler = handler
			
			super.init()
			
			/*
			This operation cannot run at the same time as any other remote notification
			permission operation.
			*/
			addCondition(MutuallyExclusive<RemoteNotificationPermissionOperation>())
		}
		
		func execute() {
			
			guard !cancelled else { return }
			
			DispatchQueue.main.async {
				let notificationCenter = NotificationCenter.default
				
				notificationCenter.addObserver(self, selector: #selector(RemoteNotificationPermissionOperation.didReceiveResponse(_:)), name: NSNotification.Name(rawValue: RemoteNotificationName), object: nil)
				
				self.application.registerForRemoteNotifications()
			}
		}
		
		@objc func didReceiveResponse(_ notification: Notification) {
			NotificationCenter.default.removeObserver(self)
			
			let userInfo = notification.userInfo
			
			if let token = userInfo?["token"] as? NSData {
				handler(.token(token as Data))
			}
			else if let error = userInfo?["error"] as? NSError {
				handler(.error(error))
			}
			else {
				fatalError("Received a notification without a token and without an error.")
			}
			
			finish()
		}
	}
	
#endif
