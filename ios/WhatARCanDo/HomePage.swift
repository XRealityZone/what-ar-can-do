//
//  HomePage.swift
//  WhatARCanDo
//
//  Created by Onee on 2022/3/17.
//

import SwiftUI

struct HomePage: View {
    var body: some View {
        NavigationView {
            List {
                ListItem(title: "CoachingOverlay", description: "了解 CoachingOverlay 是如何引导用户进入 AR 世界的", destination: CoachingOverlay())
                ListItem(title: "NonARCamera", description: "ARView 除了展示 AR，还可以展示 NonAR 的场景，是不是很神奇？【狗头】", destination: NonARCameraMode())
                ListItem(title: "PlaneAnchor", description: "了解 PlaneAnchor 是如何检测到平面的", destination: AddPlaneAnchor())
                ListItem(title: "BodyAnchor", description: "了解 BodyAnchor 是如何检测到人体的", destination: AddBodyAnchor())
                ListItem(title: "SceneReconstruction", description: "了解 SceneReconstruction 是如何识别场景的", destination: WorldScening())
            }
            .navigationTitle("What AR Can Do")
        }
        .navigationViewStyle(.stack)
    }
}

struct ListItem<Destination>: View where Destination : View {
    let title: String
    let description: String
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(description)
                    .foregroundColor(.gray)
                    .fontWeight(.light)
                    .font(.subheadline)
            }
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomePage()
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro Max"))
        }
    }
}
