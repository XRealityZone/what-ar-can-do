//
// WhatARCanDo
// Created by: onee on 2023/8/13
//

import ARKit
import Foundation
import RealityKit

class AddPlanceAnchorTrackingModel: TrackingModel {
    var enablePlaneClassification: Bool = true
    
    func run(enablePlaneClassification: Bool) {
        self.enablePlaneClassification = enablePlaneClassification
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
        session.delegate = self
    }
    
    // MARK: ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        Task { @MainActor in
            do {
                for anchor in anchors {
                    if let anchor = anchor as? ARPlaneAnchor, self.enablePlaneClassification {
                        try await updatePlaneEntity(anchor)
                    }
                }
            } catch {
                print("error is \(error)")
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        Task { @MainActor in
            do {
                for anchor in anchors {
                    if let anchor = anchor as? ARPlaneAnchor, self.enablePlaneClassification {
                        try await updatePlaneEntity(anchor)
                    }
                }
            } catch {
                print("error is \(error)")
            }
        }
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        Task { @MainActor in
            do {
                for anchor in anchors {
                    if let anchor = anchor as? ARPlaneAnchor, self.enablePlaneClassification {
                        try removePlaneEntity(anchor)
                    }
                }
            } catch {
                print("error is \(error)")
            }
        }
    }
    
    // MARK: Plane Classification
    
    @MainActor fileprivate func updatePlaneEntity(_ anchor: ARPlaneAnchor) async throws {
        let modelEntity = try await generatePlanelExtent(anchor)
        let textEntity = await generatePlaneText(anchor)
        if let anchorEntity = rootEntity.findEntity(named: "PlaneAnchor-\(anchor.identifier)") {
            anchorEntity.children.removeAll()
            anchorEntity.addChild(modelEntity)
            anchorEntity.addChild(textEntity)
        } else {
            let anchorEntity = AnchorEntity(anchor: anchor)
            // NOTE: 需要翻转 -90 度
            anchorEntity.orientation = .init(angle: -.pi / 2, axis: .init(1, 0, 0))
            anchorEntity.addChild(modelEntity)
            anchorEntity.addChild(textEntity)
            anchorEntity.name = "PlaneAnchor-\(anchor.identifier)"
            rootEntity.addChild(anchorEntity)
        }
    }
    
    fileprivate func removePlaneEntity(_ anchor: ARPlaneAnchor) throws {
        if let anchorEntity = rootEntity.findEntity(named: "PlaneAnchor-\(anchor.identifier)") {
            anchorEntity.removeFromParent()
        }
    }
    
    @MainActor fileprivate func generatePlanelExtent(_ anchor: ARPlaneAnchor) async throws -> ModelEntity {
        let extent = anchor.planeExtent
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: .blue)
        material.blending = .transparent(opacity: 0.4)
        let modelEntity = ModelEntity(mesh: .generatePlane(width: extent.width, height: extent.height), materials: [material])
        modelEntity.transform.rotation = .init(angle: extent.rotationOnYAxis, axis: .init(0, 1, 0))
        return modelEntity
    }
    
    @MainActor fileprivate func generatePlaneText(_ anchor: ARPlaneAnchor) async -> ModelEntity {
        let classificationString = anchor.classificationString
        let textModelEntity = ModelEntity(
            mesh: .generateText(classificationString),
            materials: [SimpleMaterial(color: .black, isMetallic: false)]
        )
        textModelEntity.scale = simd_float3(repeating: 0.005)
        textModelEntity.position = simd_float3(anchor.center.x, anchor.center.y, 0.5)
        return textModelEntity
    }
}
