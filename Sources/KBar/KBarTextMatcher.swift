//
//  KBarTextMatcher.swift
//  Sage
//
//  Created by Kyle Carson on 12/21/22.
//

import Foundation

internal class KBarTextMatcher {
	private static var cache : [Int:[String]] = [:]
	
	private static func getWords(_ text: String) -> [String] {
		if let cached = cache[text.hashValue] {
			return cached
		}
		
		let words = text.lowercased().components(separatedBy: " ")
		
		cache[text.hashValue] = words
		
		return words
	}
	
	static func matches(_ text: String, _ match: String) -> Bool {
		let textWords = getWords(text)
		let matchWords = getWords(match)
		
		for matchWord in matchWords {
			var matched = false
			for textWord in textWords {
				if textWord.hasPrefix(matchWord) {
					matched = true
					break
				}
			}
			
			if !matched {
				return false
			}
		}
		
		return true
	}
	
	static func getMatches(_ texts: [(String,UUID)], _ match: String) -> [UUID] {
		var matched : [UUID] = []
		
		for (text, id) in texts {
			if matches(text, match) {
				matched.append(id)
			}
		}
		
		return matched
	}
}
