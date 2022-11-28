//
//  View+Ripple.swift
//
//  Created by Yanis Plumit on 21.11.2022.
//


import Foundation
import SwiftUI
import ViewOnTouch

public extension View {
    func rippleEffect(color: Color, viewModel: RippleViewModel, clipShape: any Shape) -> some View {
        modifier(RippleViewModifier(color: color, viewModel: viewModel, clipShape: clipShape))
    }
    
    @available(*, deprecated, renamed: "rippleEffect")
    func addRipple<S>(color: Color, rippleViewModel: RippleViewModel, clipShape: S) -> some View where S : Shape {
        self
            .overlay(content: {
                SwiftUIRippleView(rippleViewModel: rippleViewModel, color: UIColor(color))
                    .clipShape(clipShape)
            })
    }
}
 
public extension View {
    func addRippleTouchHandler(viewModel: RippleViewModel,
                               tapAction: (() -> Void)? = nil,
                               longGestureAction: ((CGPoint, RippleViewGestureState) -> Void)? = nil) -> some View {
        self
            .onTouch(type: longGestureAction == nil ? .allWithoutLongGesture : .all,
                     perform: { location, event in
                switch event {
                case .started:
                    viewModel.isTouchHandling = true
                    viewModel.touchDown?(location)
                case .moved:
                    viewModel.touchMove?(location)
                case .ended:
                    viewModel.isTouchHandling = false
                    viewModel.touchUp?(location)
                case .tapGesture where !viewModel.isTouchHandling:
                    viewModel.touchDown?(location)
                    viewModel.touchUp?(location)
                    tapAction?()
                case .longGestureStarted:
                    longGestureAction?(location, .started)
                case .longGestureMoved:
                    longGestureAction?(location, .moved)
                case .longGestureEnded:
                    longGestureAction?(location, .ended)
                default:
                    break
                }
            })
    }
}
