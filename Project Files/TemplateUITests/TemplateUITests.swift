//
//  TemplateUITests.swift
//  TemplateUITests
//
//  Created by stephenmcintosh on 17/9/17.
//  Copyright © 2017 Stephen McIntosh. All rights reserved.
//

import XCTest

class TemplateUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
		
		self.testExample()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		let app = XCUIApplication()
		
		// check that all UI elements can be seen and are in the correct state
		
		XCTAssert(app.buttons["Join a session"].isHittable)
		XCTAssert(app.staticTexts["Please enter your username and password"].exists)
		let enterYourUsernameTextField = app.textFields["Enter your username"]
		XCTAssert(enterYourUsernameTextField.exists && enterYourUsernameTextField.isEnabled)
		
		let username = app.textFields["Enter your username"]
		XCTAssert(username.exists && username.isEnabled)
		
		let enterYourPasswordSecureTextField = app.secureTextFields["Enter your password"]
		XCTAssert(enterYourPasswordSecureTextField.exists && enterYourPasswordSecureTextField.isEnabled)
		
		let saveSettingsButton = app.buttons["Clear all"]
		saveSettingsButton.tap()
		XCTAssert(saveSettingsButton.exists && saveSettingsButton.isEnabled)
		
		let login = app.buttons["Log In"]
		XCTAssert(login.exists && !login.isEnabled)
		
		// check that all UI elements can be seen and are in the correct state
		// after updating the username and password with valid information
		
		enterYourUsernameTextField.tap()
		enterYourUsernameTextField.typeText("sovative")
		
		enterYourPasswordSecureTextField.tap()
		enterYourPasswordSecureTextField.typeText("imobile")
		
		XCTAssert(saveSettingsButton.exists && saveSettingsButton.isEnabled)
		XCTAssert(login.exists && login.isEnabled)
		
		app.buttons["Log In"].tap()
		login.tap()
    }
    
}
