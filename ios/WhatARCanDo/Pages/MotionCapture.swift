//
//  MotionCapture.swift
//  WhatARCanDo
//
//  Created by 我就是御姐我摊牌了 on 2022/6/11.
//

import ARKit
import FocusEntity
import RealityKit
import SwiftUI

struct MotionCapture: View {
    var body: some View {
        RealityKitView()
            .navigationTitle(Text("MotionCapture"))
            .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.bottom)
    }
}

struct RealityKitView: UIViewRepresentable {
    typealias UIViewType = ARView

    func makeUIView(context: Context) -> ARView {
        let view = ARView()

        let session = view.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)

        let coachOverlay = ARCoachingOverlayView()
        coachOverlay.session = session
        coachOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachOverlay.goal = .horizontalPlane
        view.addSubview(coachOverlay)

#if DEBUG
        view.debugOptions = [
            .showFeaturePoints,
        ]
#endif

        // Handle ARSession events via delegate
        context.coordinator.view = view
        session.delegate = context.coordinator

        // Handle taps
        view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTap)
            )
        )

        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // TODO:
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, ARSessionDelegate {
        weak var view: ARView?
        var focusEntity: FocusEntity?

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let view = view else { return }
            debugPrint("Anchors added to the scene: ", anchors)
            focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
        }

        @objc func handleTap() {
            guard let view = view, let focusEntity = focusEntity else { return }

            // Create a new anchor to add content to
            let anchor = AnchorEntity()
            view.scene.anchors.append(anchor)

            // Add a Box entity with a blue material
            let box = MeshResource.generateBox(size: 0.5, cornerRadius: 0.05)
            let material = SimpleMaterial(color: .blue, isMetallic: true)
            let diceEntity = ModelEntity(mesh: box, materials: [material])
//           diceEntity.position = focusEntity.position

            anchor.addChild(diceEntity)
        }
    }
}
