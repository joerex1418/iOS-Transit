//
//  MapButton.swift
//  Transit
//
//  Created by Joseph Rechenmacher on 6/19/22.
//

import SwiftUI


struct MapButton: View {
    let action: () -> Void
    
    @State var mapIsVisible = false
    
    var body: some View {
        
        Button {
            action()
            mapIsVisible.toggle()
        } label: {
            Image(systemName: mapIsVisible ? "map.fill" : "map")
        }
        .font(Font.custom("Roboto-Regular",size:25))
//        .frame(maxWidth: 100)
        .foregroundColor(Color("mapIconButton"))
        .padding(8)
//        .background(color.darkRed)
        .cornerRadius(8)
    }
}

struct MapButton_Previews: PreviewProvider {
    static var previews: some View {
        MapButton() {}
    }
}
