//
// WhatARCanDo
// Created by: onee on 2023/8/13
//

import SwiftUI

struct AddPlaneAnchor: View {
    @State var trackingModel: AddPlanceAnchorTrackingModel = .init()

    var body: some View {
        ARSwiftUIView(
            trackingModel: trackingModel,
            debugOptions: [
                .showWorldOrigin,
                .showAnchorOrigins,
                .showAnchorGeometry,
            ]
        )
        .onAppear {
            trackingModel.run(
                enablePlaneClassification: true
            )
        }
        .onDisappear {
            trackingModel.stop()
        }
    }
}

#Preview {
    AddPlaneAnchor()
}
