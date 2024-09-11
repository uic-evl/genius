//
//  ProteinSpace.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 6/10/24.
//

import SwiftUI
import RealityKit
import ARKit

// Immersive Space to view protein networks
struct ProteinSpace: View {
    @ObservedObject var graph: Graph = Graph.shared
    let root = Entity()
    let session = ARKitSession()
    let worldInfo = WorldTrackingProvider()
    
    var body: some View {
        RealityView { content in
            try? await session.run([worldInfo])
            // Retrieve headeset position
            let pose = worldInfo.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
            let devicePos = (pose?.originFromAnchorTransform.translation ?? simd_float3(0,1,0)) + simd_float3(0, 0, -0.7)
            
            // Position graph in front of headset with devicePos
            print(devicePos) //SIMD3<Float>(0.0, 1.6, -0.7)
            root.position = devicePos
            content.add(root)
        }
        // Add/remove nodes when internal array updates
        .onChange(of: graph.nodes) { oldNodes, newNodes in
            
            let nodesToAdd = newNodes.filter {n in !oldNodes.contains(n)}
            for node in nodesToAdd {
                root.addChild(node)
            }
            
            let nodesToRemove = root.children.filter {n in !newNodes.contains(n) && !n.name.contains("->")}
            for node in nodesToRemove {
                root.removeChild(node)
            }
        }
        // Add/remove edges when internal array updates
        .onChange(of: graph.edges) { oldEdges, newEdges in
            let edgesToAdd = newEdges.filter {e in !oldEdges.contains(e)}
            for edge in edgesToAdd {
                root.addChild(edge)
            }
            
            let edgesToRemove = root.children.filter {e in !newEdges.contains(e) && e.name.contains("->")}
            for edge in edgesToRemove {
                root.removeChild(edge)
            }
        }
        // Update node positions when internal array updates
        .onChange(of: graph.positions) { oldPos, newPos in
            for (index, pos) in newPos.enumerated() {
                if graph.nodes.count == graph.positions.count {
                    let node = graph.nodes[index]
                    node.move(to: pos, duration: 1)
                    //node.move(to: Transform(translation: pos), relativeTo: node.parent, duration: 1)
                }
            }
        }
        // Show description when object is clicked
        .gesture(TapGesture().targetedToAnyEntity().onEnded { value in
            let object = value.entity
            if let descEntity = object.children.first(where: { $0.name == "descWindow"}) {
                descEntity.isEnabled.toggle()
                    
                // If object is an edge, highlight it
                if let edge = object as? Edge {
                    if descEntity.isEnabled{
                        edge.model?.materials = [SimpleMaterial(color: UIColor(white: 1.0, alpha: 1.0), isMetallic: false)]
                    } else {
                        edge.model?.materials = [SimpleMaterial(color: UIColor(white: 1.0, alpha: 0.5), isMetallic: false)]
                    }
                }
            }
        }) 
        // Enable drag gestures on protein objects
        .gesture(DragGesture().targetedToAnyEntity().onChanged { value in
            if let node = value.entity as? Node {
                node.isDragging = true
                node.position = value.convert(value.location3D, from: .local, to: node.parent!)
            }
        }
        .onEnded { value in
            if let node = value.entity as? Node {
                node.isDragging = false
                
            }
        })
    }
}

// Add attribute to retrieve headset position
//extension simd_float4x4 {
//    var translation: simd_float3 { return simd_float3(columns.3.x, columns.3.y, columns.3.z)}
//}

#Preview {
    ProteinSpace()
}
