//
//  KBar.swift
//
//  Created by Kyle Carson on 12/21/22.
//

import SwiftUI

struct KBar {
	struct Item : KBarItem {
		var id = UUID()
		var title : String
		var subtitle : String? = nil
		var image : Image? = nil
		var badge : String? = nil
		var callback : () -> () = {}
	}

	class Config : ObservableObject {
		var defaultImage = "circle.fill"
		var keybinding : KeyboardShortcut? = KeyboardShortcut("k")
		var showImages = true
		var maxItemsShown = 6
	}
	
	internal init(isActive: Binding<Bool>? = nil, items: [any KBarItem], config: KBar.Config = Config()) {
		self._isActive = isActive
		self.items = items
		self.config = config
		
		if let isActive {
			_internalIsActive = .init(initialValue: isActive.wrappedValue)
		}
	}

	// MARK: Variable
	var items : [any KBarItem]
	var config = Config()
	
	@State internal var search = ""
	@State internal var results : [any KBarItem] = []
	@State internal var selectedResult : (any KBarItem)? = nil
	
	// MARK: Support isActive as an optional binding
	@State internal var internalIsActive = false
	var _isActive : Binding<Bool>?
	internal var isActive : Binding<Bool> {
		return .init {
			return _isActive?.wrappedValue ?? internalIsActive
		} set: { newValue in
			_isActive?.wrappedValue = newValue
			   internalIsActive = _isActive?.wrappedValue ?? newValue
		}
	}
}

// MARK: Convenience Functions
extension KBar {
	private func activate(result: any KBarItem) {
		withAnimation {
			isActive.wrappedValue = false
		}
		
		result.callback()
	}

	private func updateSearch(_ query : String) {
		var results : [any KBarItem] = []

		if !query.isEmpty {
			results = items.filter {
				KBarTextMatcher.matches($0.title, query)
			}
		}

		withAnimation(.easeInOut(duration: 0.2)) {
			self.results = results
			selectedResult = results.first
		}
	}
}

// MARK: KBar View
extension KBar: View {
	var veil : some View {
		Color.init(white: 0.5).opacity(0.5)
			.zIndex(1)
			.edgesIgnoringSafeArea(.all)
			.onTapGesture {
				withAnimation {
					isActive.wrappedValue = false
				}
			}
	}

	@ViewBuilder
	var textFieldContainer : some View {
		HStack {
			Image(systemName: "magnifyingglass")
				.padding(.trailing, 4)

			KBarTextField(text: $search, isFocused: isActive, delegate: self)
				.frame(height: 30)
		}
		.font(.system(size: 20))
		.padding()
		.background(Color.init(white: 0.15))
		.zIndex(1)
		.onChange(of: search) { newValue in
			updateSearch(newValue)
		}
	}

	var resultsContainerHeight : CGFloat {
		let heightPerItem: CGFloat = 47
		let subtitleHeight: CGFloat = 9

		var totalHeight : CGFloat = 0
		let results = results

		for i in 0..<config.maxItemsShown {
			if i < results.count {
				totalHeight += heightPerItem

				let result = results[i]
				if result.subtitle != nil {
					totalHeight += subtitleHeight
				}
			}
		}

		return totalHeight
	}

	@ViewBuilder
	var resultsContainer : some View {
		let results = results
		if !results.isEmpty {
			ScrollView {
				VStack(spacing: 0) {
					ForEach(results, id: \.id) { result in
						
						let index = results.firstIndex { $0.id == result.id }!
						let selected = selectedResult?.id == result.id
						
						KBarItemView(item: result, index: index, selected: selected, callback: {
							activate(result: result)
						})
						.transition(.move(edge: .top))
						.onHover { hovering in
							if hovering {
								selectedResult = result
							}
						}
						.onTapGesture {
							activate(result: result)
						}
					}
					.listStyle(.plain)
				}
			}
			.frame(height: resultsContainerHeight)
			.onAppear {
				selectedResult = results.first
			}
		}
	}

	@ViewBuilder
	var bar : some View {
		VStack {
			VStack(spacing: 0) {
				textFieldContainer

				resultsContainer
			}
			.background(Color.init(white: 0.1))
			.foregroundColor(.white)
			.cornerRadius(6)
			.shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
			.frame(idealWidth: 450)
			.frame(maxWidth: 550)

			Spacer()
		}
		.padding(.vertical, 30)
		.padding(.horizontal)
		.transition(.scale)
	}

	var body: some View {
		if internalIsActive {
			veil
				.overlay(bar)
				.transition(.opacity)
		} else if let keybinding = config.keybinding {
			Button("Activate KBar") {
				search = ""
				results = []
				withAnimation {
					isActive.wrappedValue = true
				}
			}
			.keyboardShortcut(keybinding)
			.hidden()
		}
	}
}

// MARK: KBar KBarTextFieldDelegate
extension KBar : KBarTextFieldDelegate {
	func selectPreviousItem() {
		let index = results.firstIndex { $0.id == selectedResult?.id } ?? 0
		let nextIndex = (index - 1 + results.count) % results.count

		selectedResult = results[nextIndex]
	}

	func selectNextItem() {
		let index = results.firstIndex { $0.id == selectedResult?.id } ?? 0
		let nextIndex = (index + 1) % results.count

		selectedResult = results[nextIndex]
	}

	func onCommit() {
		if let selectedResult {
			activate(result: selectedResult)
		}
	}
}

struct KBar_Previews: PreviewProvider {
	static var previews: some View {
		ZStack {
			KBar(isActive: .constant(true), items: [KBar.Item(title: "Fix Grammar"), KBar.Item(title: "Fix Spelling"), KBar.Item(title: "Emphasize")])

			Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum")
				.lineLimit(nil)
				.padding()
				.frame(height: 400)
		}
		.toolbar {
			Text("KBar")
		}
		.presentedWindowToolbarStyle(.unified(showsTitle: true))
	}
}
