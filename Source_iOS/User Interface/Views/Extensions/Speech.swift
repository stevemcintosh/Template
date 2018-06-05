//
//  Speech.swift
//  Template
//
//  Created by Steve McIntosh on 31/1/18.
//  Copyright © 2018 Stephen McIntosh. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class Speech: NSObject {
	static let speechSynthesizer = AVSpeechSynthesizer()
	
	static func BCP47LanguageCodeFromISO681LanguageCode(iso681LanguageCode: String = "en") -> String {
		if (iso681LanguageCode.hasPrefix("en")) {
			return "en-AU"
		} else {
			fatalError("Unknown language code")
		}
	}

	static func BCP47LanguageCodeForString(string: String) -> String {
		guard let iso681LanguageCode = CFStringTokenizerCopyBestStringLanguage(string as CFString, CFRangeMake(0, string.count - 1 )) as String? else { return "en-AU"}
		return BCP47LanguageCodeFromISO681LanguageCode(iso681LanguageCode: iso681LanguageCode)
	}
	
	static func say(phrase wordsToSpeech: String, after: Double = 0.1) {
		let utterance = AVSpeechUtterance.init(string: wordsToSpeech)
		utterance.voice = AVSpeechSynthesisVoice(language: BCP47LanguageCodeForString(string: wordsToSpeech))
		utterance.rate = AVSpeechUtteranceDefaultSpeechRate
		utterance.preUtteranceDelay = after
		utterance.postUtteranceDelay = 0.1
		Speech.speechSynthesizer.speak(utterance)
	}
	
	override init() {
		super.init()
		Speech.speechSynthesizer.delegate = self
	}
}

extension Speech : AVSpeechSynthesizerDelegate {
}
