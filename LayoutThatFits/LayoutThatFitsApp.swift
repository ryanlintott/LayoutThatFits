//
//  LayoutThatFitsApp.swift
//  LayoutThatFits
//
//  Created by Ryan Lintott on 2022-06-09.
//

import SwiftUI

@main
struct LayoutThatFitsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Creates a layout using the first layout that fits in the axes provided from the array of layout preferences.
struct LayoutThatFits: Layout {
    let axes: Axis.Set
    let layoutPreferences: [AnyLayout]
    
    /// Creates a layout using the first layout that fits in the axes provided from the array of layout preferences.
    /// - Parameters:
    ///   - axes: Axes this content must fit in.
    ///   - layoutPreferences: Layout preferences from largest to smallest.
    init(in axes: Axis.Set = [.horizontal, .vertical], _ layoutPreferences: [any Layout]) {
        self.axes = axes
        self.layoutPreferences = layoutPreferences.map { AnyLayout($0) }
    }
    
    func layoutThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> AnyLayout? {
        layoutPreferences.first(where: { layout in
            var cache = layout.makeCache(subviews: subviews)
            let size = layout.sizeThatFits(proposal: proposal, subviews: subviews, cache: &cache)
            
            let widthFits = size.width <= (proposal.width ?? .infinity)
            let heightFits = size.height <= (proposal.height ?? .infinity)
            
            return (widthFits || !axes.contains(.horizontal)) && (heightFits || !axes.contains(.vertical))
        })
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let layout = layoutThatFits(proposal: proposal, subviews: subviews, cache: &cache) ?? layoutPreferences.last else { return CGSize(width: 10, height: 10) }
        var cache = layout.makeCache(subviews: subviews)
        return layout.sizeThatFits(proposal: proposal, subviews: subviews, cache: &cache)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let layout = layoutThatFits(proposal: proposal, subviews: subviews, cache: &cache) ?? layoutPreferences.last else { return }
        var cache = layout.makeCache(subviews: subviews)
        layout.placeSubviews(in: bounds, proposal: proposal, subviews: subviews, cache: &cache)
    }
}

struct ContentView: View {
    @State private var width: CGFloat = 300
    
    var body: some View {
        VStack {
            TabView {
                Group {
                    LayoutThatFitsExample(width: width)
                        .tabItem {
                            Label("LayoutThatFits", systemImage: "rectangle.3.group")
                        }
                    
                    ViewThatFitsExample(width: width)
                        .tabItem {
                            Label("ViewThatFits", systemImage: "rectangle.and.arrow.up.right.and.arrow.down.left.slash")
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThickMaterial)
                .cornerRadius(20)
                .padding()
            }
            .animation(.spring(), value: width)
            
            LabeledContent("Width") {
                Slider(value: $width, in: 50...400)
            }
            .padding()
            .frame(maxWidth: 400)
        }
    }
}

struct FittingContent: View {
    let thing: String
    var body: some View {
        Group {
            Text(thing)
            Text("That")
            Text("Fits")
        }
        .lineLimit(1)
        .padding()
        .foregroundColor(.white)
        .background(Color.accentColor.gradient)
        .cornerRadius(10)
        .fixedSize(horizontal: true, vertical: false)
    }
}

extension View {
    func boxStyle() -> some View {
        self
            .padding(1)
            .background(Rectangle().inset(by: -2).strokeBorder(Color.brown, lineWidth: 2))
            .background(Color.brown.shadow(.inner(radius: 5)))
    }
}

struct LayoutThatFitsExample: View {
    let width: CGFloat
    
    var body: some View {
        VStack {
            Spacer()
            
            LayoutThatFits([HStackLayout(), VStackLayout()]) {
                FittingContent(thing: "Layout")
            }
            .frame(width: width)
            .boxStyle()
            
            Spacer()
            
            Text("LayoutThatFits").font(.title)
            Text("- One set of subviews")
            Text("- Animation works!")
            Text(
"""
LayoutThatFits([
    HStackLayout(),
    VStackLayout()
]) {
    content
}
"""
            )
            .font(.body.monospaced())
            .padding()
        }
    }
}

struct ViewThatFitsExample: View {
    let width: CGFloat
    
    var body: some View {
        VStack {
            Spacer()
            
            ViewThatFits {
                HStack {
                    FittingContent(thing: "View")
                }
                VStack {
                    FittingContent(thing: "View")
                }
            }
            .frame(width: width)
            .boxStyle()
            
            Spacer()
            Text("ViewThatFits").font(.title)
            Text("- Duplicate sets of subviews")
            Text("- Animation not possible")
            Text(
"""
ViewThatFits {
    HStack {
        content
    }
    VStack {
        content
    }
}
"""
            )
            .font(.body.monospaced())
            .padding()
        }
    }
    
}

struct LayoutThatFits_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
