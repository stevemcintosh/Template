//
//  UserNotificationCondition.swift
//  Operations
//
//  Created by Daniel Thorpe on 28/07/2015.
//  Copyright (c) 2015 Daniel Thorpe. All rights reserved.
//

import ProcedureKit
import UIKit
import UserNotifications


// need to support triggers that are generated from Notification content
// Push, Time Interval, Calendar, Location
// Push are from remote notifications
// Time Interval, Calendar, Location are local notifications
// eg 
// UNTimeIntervalNotificationTrigger(timeInterval: 120, repeats: false) // every 2 mins
// let dateComponents = DateComponents()
// UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
// let region = CLRegion()
// UNLocationNotificationTrigger(region: region, repeats: false)
//
// Then schedule the trigger
//
// UNUserNotificationCenter.current().add(UNNotificationRequest) { (error) in
// }

public protocol UserNotificationRegistrarType {
    func opr_registerUserNotificationSettings(_ notificationSettings: UNNotificationSettings)
    func opr_currentUserNotificationSettings(completion: @escaping (UNNotificationSettings) -> UNNotificationSettings?)
}

extension UIApplication: UserNotificationRegistrarType {

//	- (void)requestAuthorizationWithOptions:(UNAuthorizationOptions)options completionHandler:(void (^)(BOOL granted, NSError *__nullable error))completionHandler;
//	- (void)getNotificationSettingsWithCompletionHandler:(void(^)(UNNotificationSettings *settings))completionHandler;

    public func opr_registerUserNotificationSettings(_ notificationSettings: UNNotificationSettings) {
//        registerUserNotificationSettings(notificationSettings)
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound]) { (granted, error) in
			if granted {
			}
		}
    }

    public func opr_currentUserNotificationSettings(completion: @escaping (UNNotificationSettings) -> UNNotificationSettings?) {
		UserNotificationCondition.getNotificationSettings(completion: { (settings) in
			return settings 
		})
    }
}

// swiftlint:disable variable_name
private let DidRegisterSettingsNotificationName = "DidRegisterSettingsNotificationName"
private let NotificationSettingsKey = "NotificationSettingsKey"

// swiftlint:enable variable_name

/**
    A condition for verifying that we can present alerts
    to the user via `UILocalNotification` and/or remote
    notifications.

    In order to use this condition effectively, it is
    required that you post a notification from inside the
    UIApplication.sharedApplication()'s delegate method.

    Like this:
        func application(_ application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
            UserNotificationCondition.didRegisterUserNotificationSettings(notificationSettings)
        }

*/
public final class UserNotificationCondition: Condition {

    public enum Behavior {
        // Merge the new settings with the current settings
        case merge
        // Replace the current settings with the new settings
        case replace
    }

    public enum UserNofificationError: Error, Equatable {
        public typealias UserSettingsPair = (current: UNNotificationSettings?, desired: UNNotificationSettings)
        case settingsNotSufficient(UserSettingsPair)
    }

	public static func getNotificationSettings(completion: @escaping (UNNotificationSettings) -> Swift.Void) {
		UNUserNotificationCenter.current().getNotificationSettings { (settings) in
			completion(settings)
		}
	}

	public static func didRegisterUserNotificationSettings(_ notificationSettings: UNNotificationSettings) {
        NotificationCenter.default
            .post(name: Notification.Name(rawValue: DidRegisterSettingsNotificationName), object: nil, userInfo: [NotificationSettingsKey: notificationSettings] )
    }
	
    let settings: UNNotificationSettings
    let behavior: Behavior
    let registrar: UserNotificationRegistrarType

    public convenience init(settings: UNNotificationSettings, behavior: Behavior = .merge) {
        self.init(settings: settings, behavior: behavior, registrar: UIApplication.shared)
    }

    init(settings: UNNotificationSettings, behavior: Behavior = .merge, registrar: UserNotificationRegistrarType) {
        self.settings = settings
        self.behavior = behavior
        self.registrar = registrar
        super.init()
        name = "UserNotification"
        mutuallyExclusive = false
        addDependency(UserNotificationPermissionOperation(settings: settings, behavior: behavior, registrar: registrar))
    }

    public override func evaluate(_ operation: Procedure, completion: (OperationConditionResult) -> Void) {
        if let current = registrar.opr_currentUserNotificationSettings() {

            switch (current, settings) {

            case let (current, settings) where current.contains(settings):
                completion(.satisfied)

            default:
                completion(.failed(Error.settingsNotSufficient(current, settings)))
            }
        }
        else {
            completion(.failed(Error.settingsNotSufficient(.none, settings)))
        }
    }
}

public func == (lhs: UserNotificationCondition.Error, rhs: UserNotificationCondition.Error) -> Bool {
    switch (lhs, rhs) {
    case let (.settingsNotSufficient(current: aCurrent, desired: aDesired), .settingsNotSufficient(current: bCurrent, desired: bDesired)):
        return (aCurrent == bCurrent) && (aDesired == bDesired)
    }
}

public class UserNotificationPermissionOperation: Procedure {

    enum NotificationObserver {
        case settingsDidChange

        var selector: Selector {
            switch self {
            case .settingsDidChange:
                return #selector(UserNotificationPermissionOperation.notificationSettingsDidChange(_:))
            }
        }
    }

    let settings: UNNotificationSettings
    let behavior: UserNotificationCondition.Behavior
    let registrar: UserNotificationRegistrarType

    public convenience init(settings: UIUserNotificationSettings, behavior: UserNotificationCondition.Behavior = .merge) {
        self.init(settings: settings, behavior: behavior, registrar: UIApplication.shared)
    }

    init(settings: UNNotificationSettings, behavior: UserNotificationCondition.Behavior = .merge, registrar: UserNotificationRegistrarType) {
        self.settings = settings
        self.behavior = behavior
        self.registrar = registrar
        super.init()
        name = "User Notification Permissions Procedure"
        addCondition(AlertPresentation())
    }

    public override func execute() {
        NotificationCenter.default
            .addObserver(self, selector: NotificationObserver.settingsDidChange.selector, name: NSNotification.Name(rawValue: DidRegisterSettingsNotificationName), object: nil)
        Queue.main.queue.async(execute: request)
    }

    func request() {
        var settingsToRegister = settings
        if let current = registrar.opr_currentUserNotificationSettings() {
            switch (current, behavior) {
            case (let currentSettings, .merge):
                settingsToRegister = currentSettings.settingsByMerging(settings)
            default:
                break
            }
        }
        registrar.opr_registerUserNotificationSettings(settingsToRegister)
    }

    func notificationSettingsDidChange(_ aNotification: Notification) {
        NotificationCenter.default.removeObserver(self)
        self.finish()
    }
}

extension UIUserNotificationSettings {

    func contains(_ settings: UNNotificationSettings) -> Bool {

        if !types.contains(settings.types) {
            return false
        }

        let myCategories = categories ?? []
        let otherCategories = settings.categories ?? []
        return myCategories.isSuperset(of: otherCategories)
    }

    func settingsByMerging(_ settings: UNNotificationSettings) -> UNNotificationSettings {
        let union = types.union(settings.types)

        let myCategories = categories ?? []
        var existingCategoriesByIdentifier = Dictionary(sequence: myCategories) { $0.identifier }

        let newCategories = settings.categories ?? []
        let newCategoriesByIdentifier = Dictionary(sequence: newCategories) { $0.identifier }

        for (newIdentifier, newCategory) in newCategoriesByIdentifier {
            existingCategoriesByIdentifier[newIdentifier] = newCategory
        }

        let mergedCategories = Set(existingCategoriesByIdentifier.values)
        return UNNotificationSettings(types: union, categories: mergedCategories)
    }
}

extension UIUserNotificationType {

    public var boolValue: Bool {
        return self != []
    }
}
