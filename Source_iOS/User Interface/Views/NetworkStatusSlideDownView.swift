//
//  NetworkStatusSlideDownView.swift
//  Template
//
//  Created by stephenmcintosh on 24/4/17.
//  Copyright © 2017 Stephen McIntosh. All rights reserved.
//
import UIKit
import Foundation

import Alamofire
import ProcedureKit

class NetworkStatusSlideDownView: UILabel {
	
	var reachabilityManager: NetworkReachabilityManager?
	
	deinit {
		MemoryResourceTracking.decrementTotal(String(describing: self))
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		MemoryResourceTracking.incrementTotal(String(describing: self))
	}
	
	convenience init(reachabilityManager: NetworkReachabilityManager) {
		guard let window = UIApplication.shared.delegate?.window as? UIWindow else { fatalError("Can't get main window") }
		var frame = window.bounds
		frame.origin.y = -20
		frame.size.height = 20
		self.init(frame: frame)
		self.frame = frame
		self.autoresizingMask = .flexibleWidth
		self.autoresizesSubviews = true
		
		self.showHideView(isConnected: NetworkReachabilityManager.isConnectedToNetwork())
		
		reachabilityManager.listener = { status in
			var available = false
			
			switch status {
			case .reachable(_):
				available = true
			default: break
			}
			self.showHideView(isConnected: available)
		}
		reachabilityManager.startListening()
		self.reachabilityManager = reachabilityManager
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func showHideView(isConnected: Bool) {
		var position = self.center
		position.y = isConnected ? -10 : 10
		guard let window = UIApplication.shared.delegate?.window as? UIWindow else { fatalError("Can't get main window") }
		if isConnected == false {
			self.font = UIFont(name: "Graphik-Regular", size: 12)
			self.text = "No internet connection"
			self.textAlignment = .center
			self.textColor = UIColor.white
			self.backgroundColor = UIColor.red
			window.bringSubview(toFront: self)
			window.windowLevel = UIWindowLevelStatusBar
		} else {
			self.text = nil
			self.backgroundColor = UIColor.clear
			window.windowLevel = UIWindowLevelNormal
		}
		
		UIView.animate(withDuration: 0.25,
		               animations:{
						self.layer.position = position
		})
	}
	
}
