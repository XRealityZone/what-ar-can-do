//
//  CoachingOverlay.swift
//  WhatARCanDo
//
//  Created by 我就是御姐我摊牌了 on 2022/8/7.
//

import ARKit
import Logging
import RealityKit
import SwiftUI

private let logger = Logger(label: "CoachingOverlay")

struct CoachingOverlay: View {
    var body: some View {
        ARViewContainer()
            .navigationTitle(Text("CoachingOverlay"))
            .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.bottom)
    }
}

private struct ARViewContainer: UIViewRepresentable {
    typealias UIViewType = ARView

    func makeUIView(context: Context) -> ARView {
        let config = ARWorldTrackingConfiguration()
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        arView.addCoaching()
        arView.observeSession()
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}

extension ARView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = session
        // use this to make coachingOverlay to fit the width of the ARView
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        coachingOverlay.goal = .tracking
        addSubview(coachingOverlay)
    }

    public func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        logger.info(#function)
    }

    public func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        logger.info(#function)
    }

    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        logger.info(#function)
    }
}

extension ARView: ARSessionDelegate {
    func observeSession() {
        session.delegate = self
    }

    // MARK: ARSessionDelegate

    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        logger.info(#function)
    }

    public func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // update for every frame
    }

    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        logger.info(#function)
    }

    // MARK: Handling Errors

    public func session(_ session: ARSession, didFailWithError error: Error) {
        logger.info(#function)
    }

    // MARK: Handling Interruptions

    public func sessionWasInterrupted(_ session: ARSession) {
        logger.info(#function)
    }

    public func sessionInterruptionEnded(_ session: ARSession) {
        logger.info(#function)
    }

    public func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        logger.info(#function)
        return true
    }

    // MARK: Managing Collaboration

    public func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        logger.info(#function)
    }

    // MARK: Receiving Audio Data

    public func session(_ session: ARSession, didOutputAudioSampleBuffer audioSampleBuffer: CMSampleBuffer) {
        logger.info(#function)
    }

    // MARK: Responding to Tracking Quality Changes

    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        logger.info("did change to state \(camera.trackingState)")
    }

    public func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
        logger.info(#function)
    }
}
