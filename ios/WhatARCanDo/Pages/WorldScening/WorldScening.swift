//
// WhatARCanDo
// Created by: onee on 2023/8/13
//

import ARKit
import RealityKit
import SwiftUI

struct WorldScening: View {
    @State var trackingModel: WorldSceningTrackingModel = .init()

    var body: some View {
        ARSwiftUIView(
            trackingModel: trackingModel
        )
        .onAppear {
            trackingModel.run(
                enableGeoMesh: true,
                enableMeshClassfication: true
            )
        }
        .onDisappear {
            trackingModel.stop()
        }
    }
}

#Preview {
    WorldScening()
}
