//
//  LayoutTest.swift
//  LayoutThatFits
//
//  Created by Ryan Lintott on 2022-07-14.
//

import SwiftUI

struct TestLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.forEach { subview in
            subview.place(at: bounds.origin, proposal: .unspecified)
        }
    }
    
    
}

struct LayoutTest: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct LayoutTest_Previews: PreviewProvider {
    static var previews: some View {
        LayoutTest()
    }
}
