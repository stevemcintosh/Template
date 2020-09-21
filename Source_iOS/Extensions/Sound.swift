//
//  Sound.swift
//  Template
//
//  Created by Steve McIntosh on 31/1/18.
//  Copyright © 2018 Stephen McIntosh. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class Sound: NSObject {
	static var player: AVAudioPlayer! = nil
	
	static func play(named soundName: String) {
		let _ = Sound.init(named: soundName)
	}
	
	init(named soundName: String) {
		super.init()
		guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { fatalError("Sound file not found")}
		
		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
			try? AVAudioSession.sharedInstance().setActive(true)
			
			Sound.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
			
			Sound.player.play()
		} catch let error {
			print(error.localizedDescription)
		}
	}
}
