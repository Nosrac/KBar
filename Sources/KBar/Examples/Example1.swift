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

	var body : some View {
		ZStack {
			KBar(items: items)

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
