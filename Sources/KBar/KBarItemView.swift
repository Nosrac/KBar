//
//  SwiftUIView.swift
//  
//
//  Created by Kyle Carson on 12/24/22.
//

import SwiftUI

internal struct KBarItemView: View {
	var item : any KBarItem
	var index : Int
	var selected : Bool
	var callback : () -> Void
	@EnvironmentObject var config : KBar.Config
	
    var body: some View {
		HStack {
			if config.showImages {
				(item.image ?? Image(systemName: config.defaultImage))
					.padding(.trailing, 4)
			}

			VStack(alignment: .leading) {
				Text(item.title)
					.font(.system(size: 16, weight: .semibold, design: .default))
					.lineLimit(1)

				if let subtitle = item.subtitle {
					Text(subtitle)
						.font(.system(size: 14, weight: .regular, design: .default))
						.foregroundColor(.gray)
						.lineLimit(1)
				}
			}

			Spacer()
			
			if let badge = item.badge {
				Text(badge)
					.font(.system(size: 14, weight: .regular, design: .default))
					.foregroundColor(.gray)
					.lineLimit(1)
			}

			if index < 9 {
				Button {
					callback()
//					activate(result: result)
				} label: {
					Text(selected ? "⏎" : "⌘ \(index + 1)")
						.font(.system(size: 16))
						.foregroundColor(.white)
						.padding(.horizontal, 8)
						.padding(.vertical, 4)
						.frame(width: 45)
						.background(Color.init(white: 0.15))
						.cornerRadius(4)
						.shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
				}
				.buttonStyle(.plain)
				.keyboardShortcut(KeyEquivalent(.init("\(index + 1)")))
			}
		}
		.padding(.horizontal)
		.padding(.vertical, 10)
		.background(selected ? Color(nsColor: NSColor.selectedContentBackgroundColor) : Color.clear)
    }
}

internal struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
		KBar_Previews.previews
    }
}
