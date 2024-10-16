//
//  ImmersiveView.swift
//  GENIUS
//
//  Created by Rick Massa on 5/9/24.
//

import SwiftUI
import RealityKit
import ARKit
import RealityKitContent
import GestureKit
import Speech

struct ImmersiveView: View {
    @EnvironmentObject var recorder: Recorder
    @EnvironmentObject var argo: Argo
    
    var updatingTextHolder = UpdatingTextHolder.shared
    @State private var recording = false
    @State private var blasting = false
    @State private var startCount = 0;
    @State private var stopCount = 0;
    @State private var spidermanActive = false
    let speechSynthesizer = AVSpeechSynthesizer()
    let showHUD = false
    
    let detector: GestureDetector
      
    init() {
        // Attempt to find the URL for the resource
        guard let handsTogetherURL = Bundle.main.url(forResource: "hands-together", withExtension: "gesturecomposer") else {
            fatalError("hands-together.gesturecomposer not found in bundle")
        }
        
        guard let spreadURL = Bundle.main.url(forResource: "spread", withExtension: "gesturecomposer") else {
            fatalError("spread.gesturecomposer not found in bundle")
        }
        
        guard let spidermanURL = Bundle.main.url(forResource: "spiderman", withExtension: "gesturecomposer") else {
                    fatalError("spiderman.gesturecomposer not found in bundle")
        }
    
        // Initialize the configuration with the URL
        let configuration = GestureDetectorConfiguration(packages: [handsTogetherURL, spreadURL, spidermanURL])
        
        // Initialize the detector with the configuration
        detector = GestureDetector(configuration: configuration)
        }
    
    
    @State var scene: Entity = Entity()
    @State var headTrackedEntity: Entity = {
        let headAnchor = AnchorEntity(.head)
        headAnchor.position = [0, -0.075, -0.35]
            return headAnchor
        }()
    
    @ObservedObject var graph: Graph = Graph.shared
    let root = Entity()
    let session = ARKitSession()
    let worldInfo = WorldTrackingProvider()
    
    var body: some View {
        RealityView { content in
            // Displays Halo HUD if true
            if showHUD {
                let mesh: MeshResource = .generatePlane(width: 0.83, height: 0.6)
                        
                var material = SimpleMaterial()
                material.color = .init(tint: .white.withAlphaComponent(0.999),
                                    texture: .init(try! .load(named: "halo_hud.png")))
                material.metallic = .float(1.0)
                material.roughness = .float(0.0)

                let planeEntity = ModelEntity(mesh: mesh, materials: [material])
                headTrackedEntity.addChild(planeEntity)
                
                content.add(headTrackedEntity)
                
                try? await session.run([worldInfo])
                // Retrieve headeset position
                let pose = worldInfo.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
                let devicePos = (pose?.originFromAnchorTransform.translation ?? simd_float3(0,1,0)) + simd_float3(0, 0, -0.7)
                
                // Position graph in front of headset with devicePos
                //root.position = devicePos
                root.position = SIMD3<Float>(0.0, 1.6, -0.7)
                content.add(root)
            }
        }
        .task {
            await detectGestures()
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
                node.unsub()
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
    
    private func detectStart(gestureWanted: String, detectedGesture: String) -> Bool {
        if detectedGesture.contains("Detected: \(gestureWanted)") {
            startCount += 1
        }
        else if (detectedGesture.contains("Reset: \(gestureWanted)")){
            startCount = 0
        }
        
        if startCount == 5 {
            startCount = 0
            return true
        }
        else {
            return false
        }
    }
    
    private func detectStop(gestureWanted: String, detectedGesture: String) -> Bool {
        if detectedGesture.contains("Reset: \(gestureWanted)") {
            return true
        }
        else {
            return false
        }
    }
        
    private func detectGestures() async {
       do {
           for try await gesture in detector.detectedGestures {
               let detectedGesture = gesture.description
               
               //Check recording gesture
               if !recording && detectStart(gestureWanted: "All fingers then thumb", detectedGesture: detectedGesture) {
                   recording = true
                   recorder.startRecording()
                   updatingTextHolder.isRecording = true
               }
               else if recording && detectStop(gestureWanted: "All fingers then thumb", detectedGesture: detectedGesture) {
                   recording = false
                   recorder.stopRecording()
                   updatingTextHolder.isRecording = false
                    argo.handleRecording()
               }
               
               // Check blaster gesture
               if !blasting && detectStart(gestureWanted: "Spread", detectedGesture: detectedGesture) {
                   blasting = true
                   //updatingTextHolder.mode = "Start blasting"
               }
               else if recording && detectStop(gestureWanted: "Spread", detectedGesture: detectedGesture) {
                   blasting = false
                   //updatingTextHolder.mode = "Stop blasting"
               }
               
               
               if  detectStart(gestureWanted: "Spider-Man", detectedGesture: detectedGesture) {
                   
                    
                    loadSpidermanScene()
                    spidermanActive = true
                    }
               else if spidermanActive && detectStop(gestureWanted: "Spider-Man", detectedGesture: detectedGesture) {
                    spidermanActive = false
                    removeSpidermanScene()
                }
           }
       }
    }
    private func loadSpidermanScene() {
        guard let spidermanURL = Bundle.main.url(forResource: "SpiderMan", withExtension: "usda") else {
            //print("Error: SpiderMan.usda not found in bundle")
            return
        }
        
        do {
            let spidermanEntity = try Entity.loadModel(contentsOf: spidermanURL)
            spidermanEntity.name = "Spiderman"
            headTrackedEntity.addChild(spidermanEntity)
            // print("Spiderman scene loaded successfully")
        } catch {
            print("Error loading Spiderman scene: \(error)")
        }
    }
        
    private func removeSpidermanScene() {
        headTrackedEntity.findEntity(named: "Spiderman")?.removeFromParent()
        }
    
    func showEntity(name:String) {
        scene.findEntity(named: name)?.isEnabled = true
    }
    
    func removeEntity(name:String) {
        scene.findEntity(named: name)?.isEnabled = true
    }
}

// Add attribute to retrieve headset position
extension simd_float4x4 {
    var translation: simd_float3 { return simd_float3(columns.3.x, columns.3.y, columns.3.z)}
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
