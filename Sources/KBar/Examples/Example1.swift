//
//  File.swift
//
//
//  Created by Kyle Carson on 12/24/22.
//

import Foundation
import SwiftUI

struct Example1 : View {
	@State var favoriteNumbers : [Int] = []

	func config() -> KBar.Config {
		let config = KBar.Config()
		config.showImages = false
		config.maxItemsShown = 5
		config.keybinding = .init("k")
		config.placeholderText = "Type a number to get started"

		if !favoriteNumbers.isEmpty {
			let numbersAsText = favoriteNumbers.map { "\($0)" }.joined(separator: ", ")
			config.defaultItems = [
				KBar.Item(title: "Remove All Favorites", subtitle: numbersAsText,  image: Image(systemName: "trash.fill")) {
					self.favoriteNumbers = []
				}
			]
		}
		
		config.additionalItemsForSearch = { search in
			var items: [KBar.Item] = []
			
			if let int = Int(search), int >= 100 {
				items.append(KBar.Item(title: search, subtitle: "Custom", badge: "#") {
					favoriteNumbers.append(int)
				})
			}
			
			return items
		}

		return config
	}

	var items: [KBar.Item] {
		var items : [KBar.Item] = []

		for i in 0 ..< 100 {
			let item = KBar.Item(title: "\(i)", subtitle: "Pick This", badge: "#") {
				favoriteNumbers.append(i)
			}

			items.append(item)
		}

		return items
	}
	
	@State var isActive = false

	var body : some View {
		ZStack {
			KBar(isActive: $isActive, items: items, config: config())

			ScrollView {
				
				Text("What are your favorite numbers?")
					.font(.largeTitle)
					.padding()

				if favoriteNumbers.isEmpty {
					Text("Press Command + K to get started")
				} else {
					LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
						ForEach(favoriteNumbers.sorted(), id: \.self) { number in
							Text("\(number)")
								.font(.headline)
						}
					}
				}
			}
			.padding()
			.frame(width: 600, height: 400)
		}
	}
}

struct Example1_Previews: PreviewProvider {
	static var previews: some View {
		Example1()
	}
}
