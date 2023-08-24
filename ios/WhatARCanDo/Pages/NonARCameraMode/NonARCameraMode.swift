//
//  NonARCameraMode.swift
//  WhatARCanDo
//
//  Created by 我就是御姐我摊牌了 on 2022/9/22.
//

import Combine
import Logging
import RealityKit
import SwiftUI

private let logger = Logger(label: "NonARCameraMode")

struct NonARCameraMode: View {
    var body: some View {
        ARViewContainer()
            .navigationTitle(Text("NonARCameraMode"))
            .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.bottom)
    }
}

private struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: true)

        let skyboxResource = try! EnvironmentResource.load(named: "NonARCameraMode")
        arView.environment.lighting.resource = skyboxResource
        arView.environment.background = .skybox(skyboxResource)

        var sphereMaterial = SimpleMaterial()
        sphereMaterial.metallic = MaterialScalarParameter(floatLiteral: 1)
        sphereMaterial.roughness = MaterialScalarParameter(floatLiteral: 0)

        let sphereEntity = ModelEntity(mesh: .generateSphere(radius: 1), materials: [sphereMaterial])
        let sphereAnchor = AnchorEntity(world: .zero)
        sphereAnchor.addChild(sphereEntity)
        arView.scene.anchors.append(sphereAnchor)

        let camera = PerspectiveCamera()
        camera.camera.fieldOfViewInDegrees = 60

        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)

        arView.scene.addAnchor(cameraAnchor)

        let cameraDistance: Float = 3
        var currentCameraRotation: Float = 0
        let cameraRotationSpeed: Float = 0.01

        context.coordinator.sceneEventsUpdateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { _ in
            let x = sin(currentCameraRotation) * cameraDistance
            let z = cos(currentCameraRotation) * cameraDistance

            let cameraTranslation = SIMD3<Float>(x, 0, z)
            let cameraTransform = Transform(scale: .one,
                                            rotation: simd_quatf(),
                                            translation: cameraTranslation)

            camera.transform = cameraTransform
            camera.look(at: .zero, from: cameraTranslation, relativeTo: nil)

            currentCameraRotation += cameraRotationSpeed
        }

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Delegate {
        return Delegate()
    }
}

private class Delegate: NSObject {
    var sceneEventsUpdateSubscription: Cancellable!
}
