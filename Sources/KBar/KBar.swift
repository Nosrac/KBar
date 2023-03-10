//
//  KBar.swift
//
//  Created by Kyle Carson on 12/21/22.
//

import SwiftUI

public struct KBar {
	public struct Item : KBarItem {
		public init(id: UUID = UUID(), title: String, subtitle: String? = nil, image: Image? = nil, badge: String? = nil, callback: @escaping () -> () = {}) {
			self.id = id
			self.title = title
			self.subtitle = subtitle
			self.image = image
			self.badge = badge
			self.callback = callback
		}
		
		public var id = UUID()
		public var title : String
		public var subtitle : String? = nil
		public var image : Image? = nil
		public var badge : String? = nil
		public var callback : () -> () = {}
	}
	
	public class Config : ObservableObject {
		public var defaultImage = "circle.fill"
		public var keybinding : KeyboardShortcut? = KeyboardShortcut("k")
		public var showImages = true
		public var maxItemsShown = 6
		public var veil : some View = Color.init(white: 0.1).opacity(0.85)
		public var defaultItems : [any KBarItem] = []
		public var placeholderText = "Search"
		
		public var additionalItemsForSearch : ((String) -> [any KBarItem])? = nil
		
		public init() {
			
		}
	}
	
	public init(isActive: Binding<Bool>, items: [any KBarItem], config: KBar.Config = Config()) {
		_isActive = isActive
		self.items = items
		self.config = config
	}
	
	public init(isActive: Binding<Bool>, items: [any KBarItem], additionalItemsForSearch: @escaping ((String) -> [any KBarItem])) {
		
		let config = Config()
		config.additionalItemsForSearch = additionalItemsForSearch
		
		self.init(isActive: isActive, items: items, config: config)
	}
	
	// MARK: Variable
	var items : [any KBarItem]
	var config = Config()
	
	@State internal var search = ""
	@State internal var visibleItems : [any KBarItem] = []
	@State internal var selectedItem : (any KBarItem)? = nil
	
	@Binding var isActive : Bool
}

// MARK: Convenience Functions
extension KBar {
	private func activate(item: any KBarItem) {
		withAnimation {
			isActive = false
		}
		
		item.callback()
	}
	
	private func updateSearch(_ query : String) {
		var visibleItems : [any KBarItem] = config.defaultItems
		
		if !query.isEmpty {
			visibleItems = items.filter {
				KBarTextMatcher.matches($0.title, query)
			}
			
			visibleItems.append(contentsOf: config.additionalItemsForSearch?( query ) ?? [] )
		}
		
		withAnimation(.easeInOut(duration: 0.2)) {
			self.visibleItems = visibleItems
			selectedItem = visibleItems.first
		}
	}
}

// MARK: KBar View
extension KBar: View {
	@ViewBuilder
	var textFieldContainer : some View {
		HStack {
			Image(systemName: "magnifyingglass")
				.padding(.trailing, 4)
			
			KBarTextField(text: $search, isFocused: $isActive, config: config, delegate: self)
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
	
	var itemsViewHeight : CGFloat {
		let heightPerItem: CGFloat = 47
		let subtitleHeight: CGFloat = 9
		
		var totalHeight : CGFloat = 0
		let visibleItems = visibleItems
		
		for i in 0..<config.maxItemsShown {
			if i < visibleItems.count {
				totalHeight += heightPerItem
				
				let item = visibleItems[i]
				if item.subtitle != nil {
					totalHeight += subtitleHeight
				}
			}
		}
		
		return totalHeight
	}
	
	@ViewBuilder
	var itemsView : some View {
		let items = visibleItems
		if !items.isEmpty {
			ScrollView {
				VStack(spacing: 0) {
					ForEach(items, id: \.id) { item in
						
						let index = items.firstIndex { $0.id == item.id }!
						let selected = selectedItem?.id == item.id
						
						KBarItemView(item: item, index: index, selected: selected, callback: {
							activate(item: item)
						})
						.transition(.move(edge: .top))
						.onHover { hovering in
							if hovering {
								selectedItem = item
							}
						}
						.onTapGesture {
							activate(item: item)
						}
					}
					.listStyle(.plain)
				}
			}
			.frame(height: itemsViewHeight)
			.onAppear {
				selectedItem = items.first
			}
		}
	}
	
	@ViewBuilder
	var bar : some View {
		VStack {
			VStack(spacing: 0) {
				textFieldContainer
				
				itemsView
			}
			.background(Color.init(white: 0.1))
			.foregroundColor(.white)
			.addBorder(Color.init(white: 0.32), width: 1, cornerRadius: 6)
			.shadow(color: .black.opacity(0.35), radius: 4, x: 0, y: 2)
			.frame(idealWidth: 450)
			.frame(maxWidth: 550)
			
			Spacer()
		}
		.padding(.vertical, 30)
		.padding(.horizontal)
		.transition(.scale)
	}
	
	@ViewBuilder
	var activationButton : some View {
		if let keybinding = config.keybinding {
			Button("Activate KBar") {
				search = ""
				updateSearch(search)
				withAnimation {
					isActive = true
				}
			}
			.keyboardShortcut(keybinding)
			.hidden()
		}
	}
	
	public var body: some View {
		if isActive {
			config.veil
				.edgesIgnoringSafeArea(.all)
				.zIndex(1)
				.onTapGesture {
					withAnimation {
						isActive = false
					}
				}
				.overlay(bar)
				.transition(.opacity)
				.environmentObject(config)
		} else {
			activationButton
		}
	}
}

// MARK: KBar KBarTextFieldDelegate
extension KBar : KBarTextFieldDelegate {
	func selectPreviousItem() {
		let index = visibleItems.firstIndex { $0.id == selectedItem?.id } ?? 0
		let nextIndex = (index - 1 + visibleItems.count) % visibleItems.count
		
		selectedItem = visibleItems[nextIndex]
	}
	
	func selectNextItem() {
		let index = visibleItems.firstIndex { $0.id == selectedItem?.id } ?? 0
		let nextIndex = (index + 1) % visibleItems.count
		
		selectedItem = visibleItems[nextIndex]
	}
	
	func onCommit() {
		if let selectedItem {
			activate(item: selectedItem)
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
