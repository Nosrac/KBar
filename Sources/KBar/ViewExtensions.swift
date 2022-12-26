//
//  File.swift
//  
//
//  Created by Kyle Carson on 12/26/22.
//

import Foundation
import SwiftUI

extension View {
	public func addBorder<S>(_ content: S, width: CGFloat = 0.5, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
		let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
		return clipShape(roundedRect)
			 .overlay(roundedRect.strokeBorder(content, lineWidth: width))
	}
}
