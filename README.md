# KBar

A SwiftUI package to quickly create a "Command K" bar

![Example Image](https://raw.githubusercontent.com/Nosrac/KBar/main/Images/Example.png)

## Features
- Override features with a configuration
- Optionally intialize with isActive Binding<Bool>

## Configuration
- defaultItems: Items which are shown when the search string is empty (default: `[]`)
- placeholderText: Placeholder text shown when the search string is empty (default: `"Search"`)
- additionalItemsForSearch: Specify additional items which are shown based on the search (default: `nil`) 
- showImages: Are images shown in search results? (default: `true`)
- defaultImage: For items that do not specify an iamge, what SFSymbol do you want to display? (default: `"circle.fill"`)
- keybinding: What keybinding will open the bar? (default: `KeyboardShortcut("k")`) 
- maxItemsShown: How many results should be shown at one time? (default: `6`)
- veil: View that obscures your content when visible

## Example
```
struct Example1 : View {
	@State var favoriteNumbers : [Int] = []

	var items: [KBar.Item] {
		var items : [KBar.Item] = []

		for i in 0 ..< 100 {
			let item = KBar.Item(title: "\(i)") {
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
```
