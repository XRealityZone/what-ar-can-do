//
//  TrackingModel.swift
//  WhatVisionOSCanDo
//
//  Created by onee on 2023/8/11.
//

import ARKit
import Foundation
import RealityKit

class WorldSceningTrackingModel: TrackingModel {
    
    var enableGeoMesh: Bool = true
    var enableMeshClassfication: Bool = true
    
    func run(enableGeoMesh: Bool, enableMeshClassfication: Bool) {
        self.enableGeoMesh = enableGeoMesh
        self.enableMeshClassfication = enableMeshClassfication
        
        let config = ARWorldTrackingConfiguration()
        config.sceneReconstruction = [.mesh, .meshWithClassification]
        session.run(config)
        session.delegate = self
        
    }
    
    // MARK: ARSessionDelegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        Task { @MainActor in
            do {
                for anchor in anchors {
                    if let anchor = anchor as? ARMeshAnchor, self.enableGeoMesh {
                        let geometry = anchor.geometry
                        try await createMeshEntity(geometry, anchor)
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
                    if let anchor = anchor as? ARMeshAnchor, self.enableGeoMesh {
                        let geometry = anchor.geometry
                        try await updateMeshEntity(geometry, anchor)
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
                    if let anchor = anchor as? ARMeshAnchor, self.enableGeoMesh {
                        let geometry = anchor.geometry
                        try removeMeshEntity(geometry, anchor)
                    }
                }
            } catch {
                print("error is \(error)")
            }
        }
    }
    
    // MARK: Geometry Mesh
    
    @MainActor fileprivate func createMeshEntity(_ geometry: ARMeshGeometry, _ anchor: ARMeshAnchor) async throws {
        let modelEntity = try await generateModelEntity(geometry: geometry)
        let anchorEntity = Entity()
        anchorEntity.transform = Transform(matrix: anchor.transform)
        anchorEntity.addChild(modelEntity)
        anchorEntity.name = "MeshAnchor-\(anchor.identifier)"
        rootEntity.addChild(anchorEntity)
    }
    
    @MainActor fileprivate func updateMeshEntity(_ geometry: ARMeshGeometry, _ anchor: ARMeshAnchor) async throws {
        let modelEntity = try await generateModelEntity(geometry: geometry)
        if let anchorEntity = rootEntity.findEntity(named: "MeshAnchor-\(anchor.identifier)") {
            anchorEntity.children.removeAll()
            anchorEntity.transform = Transform(matrix: anchor.transform)
            anchorEntity.addChild(modelEntity)
        }
    }
    
    fileprivate func removeMeshEntity(_ geometry: ARMeshGeometry, _ anchor: ARMeshAnchor) throws {
        if let anchorEntity = rootEntity.findEntity(named: "MeshAnchor-\(anchor.identifier)") {
            anchorEntity.removeFromParent()
        }
    }
    
    // MARK: Helpers
    
    @MainActor func generateModelEntity(geometry: ARMeshGeometry) async throws -> ModelEntity {
        // generate mesh
        var desc = MeshDescriptor()
        let posValues = geometry.vertices.asSIMD3(ofType: Float.self)
        desc.positions = .init(posValues)
        let normalValues = geometry.normals.asSIMD3(ofType: Float.self)
        desc.normals = .init(normalValues)
        do {
            desc.primitives = .polygons(
                (0..<geometry.faces.count).map { _ in UInt8(geometry.faces.indexCountPerPrimitive) },
                (0..<geometry.faces.count * geometry.faces.indexCountPerPrimitive).map {
                    geometry.faces.buffer.contents()
                        .advanced(by: $0 * geometry.faces.bytesPerIndex)
                        .assumingMemoryBound(to: UInt32.self).pointee
                }
            )
        }
        let meshResource = try MeshResource.generate(from: [desc])
        let material = SimpleMaterial(color: .red, isMetallic: true)
        let modelEntity = ModelEntity(mesh: meshResource, materials: [material])
        return modelEntity
    }
}
