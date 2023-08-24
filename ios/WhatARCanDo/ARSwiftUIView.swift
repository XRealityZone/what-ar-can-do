//
// WhatARCanDo
// Created by: onee on 2023/8/13
//

import ARKit
import RealityKit
import SwiftUI

struct ARSwiftUIView: UIViewRepresentable {
    typealias UIViewType = ARView

    let trackingModel: TrackingModel
    var debugOptions: ARView.DebugOptions

    init(trackingModel: TrackingModel, debugOptions: ARView.DebugOptions = []) {
        self.trackingModel = trackingModel
        self.debugOptions = debugOptions
    }

    func makeUIView(context: Context) -> ARView {
        let view = ARView()

        let session = trackingModel.session
        view.session = session
        view.scene.addAnchor(trackingModel.rootEntity)

        let coachOverlay = ARCoachingOverlayView()
        coachOverlay.session = session
        coachOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachOverlay.goal = .horizontalPlane
        view.addSubview(coachOverlay)

#if DEBUG
        view.debugOptions = debugOptions
#endif

        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // do nothing for now
    }
}
