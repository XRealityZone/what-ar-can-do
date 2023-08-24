//
//  AddBodyAnchor.swift
//  WhatARCanDo
//
//  Created by 我就是御姐我摊牌了 on 2022/8/7.
//

import ARKit
import Logging
import SceneKit
import SwiftUI

private let logger = Logger(label: "AddBodyAnchor")

struct AddBodyAnchor: View {
    var body: some View {
        ARSCNViewContainer()
            .navigationTitle(Text("AddBodyAnchor"))
            .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.bottom)
    }
}

private struct ARSCNViewContainer: UIViewRepresentable {
    typealias UIViewType = ARSCNView

    func makeUIView(context: Context) -> ARSCNView {
        let config = ARBodyTrackingConfiguration()
        config.isLightEstimationEnabled = true
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        arView.automaticallyUpdatesLighting = true
        arView.autoenablesDefaultLighting = true
#if DEBUG
        arView.debugOptions = [
            .showWorldOrigin,
            .showWireframe,
        ]
#endif
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {}

    func makeCoordinator() -> Delegate {
        Delegate()
    }
}

private class Delegate: NSObject, ARSCNViewDelegate {
    let scene: SCNScene
    let head: SCNNode
    let body: SCNNode
    let sceneQueue: DispatchQueue = .init(label: "com.onee.scene.queue")

    override init() {
        self.scene = SCNScene(named: "scn.scnassets/HelloWorld.scn")!
        self.body = scene.rootNode.childNode(withName: "body", recursively: true)!
        self.head = scene.rootNode.childNode(withName: "head", recursively: true)!
    }

    // MARK: ARSCNViewDelegate

    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        logger.info("didAdd \(anchor)")
        sceneQueue.async {
            if let bodyAnchor = anchor as? ARBodyAnchor {
                let bodySketleton = bodyAnchor.skeleton
                if let headTransform = bodySketleton.modelTransform(for: .head) {
                    let clonedHead = self.head.clone()
                    clonedHead.name = "head"
                    clonedHead.transform = SCNMatrix4(headTransform)
                    node.addChildNode(clonedHead)
                }
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor is ARBodyAnchor {
            let clonedBody = body.clone()
            clonedBody.name = "body"
            return clonedBody
        }
        return nil
    }

    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // update for nearly every frame
        if let anchor = anchor as? ARBodyAnchor, node.name == "body" {
            if let headNode = node.childNode(withName: "head", recursively: false), let headTransform = anchor.skeleton.modelTransform(for: .head) {
                headNode.transform = SCNMatrix4(headTransform)
            }
        }
    }

    public func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        logger.info("didRemove \(anchor)")
    }
}
