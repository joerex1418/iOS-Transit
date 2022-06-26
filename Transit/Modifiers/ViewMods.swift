//
//  ViewMods.swift
//  Transit
//
//  Created by Joseph Rechenmacher on 6/20/22.
//

import Foundation
import SwiftUI

struct AccentBorder: ViewModifier {
    let alignment: Alignment
    let height: CGFloat
    let opacity: Double
    
    init(_ alignment: Alignment, height: CGFloat? = nil, opacity: Double? = nil) {
        self.alignment = alignment
        if let height = height {
            self.height = height
        } else {
            self.height = 1
        }
        if let opacity = opacity {
            self.opacity = opacity
        } else {
            self.opacity = 0.30
        }
        
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .frame(width: nil, height: self.height, alignment: self.alignment)
                    .foregroundColor(Color.gray.opacity(self.opacity)),
                alignment: self.alignment)
    }
}
