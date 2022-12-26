//
//  File.swift
//  
//
//  Created by Kyle Carson on 12/24/22.
//

import Foundation
import SwiftUI

public protocol KBarItem : Identifiable {
	var id : UUID { get }
	var image : Image? { get }
	var title : String { get }
	var subtitle : String? { get }
	var badge : String? { get }
	var callback : () -> Void { get }
}
