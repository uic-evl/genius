//
//  GraphManager.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 6/12/24.
//

import SwiftUI
import RealityKit
import ForceSimulation
import Combine

class Node: Entity, HasModel, HasCollision {
    var edges: [Edge] = []
    var publisher = PassthroughSubject<SIMD3<Float>, Never>()
    private var cancellables = Set<AnyCancellable>()
    var isDragging = false
    
    var position: SIMD3<Float> {
        get {super.position}
        set {
            super.position = newValue
            publisher.send(newValue)
        }
    }
    
    init(name: String, position: SIMD3<Float>, mesh: MeshResource, material: PhysicallyBasedMaterial) {
        super.init()
        self.position = position
        self.model = ModelComponent(mesh: mesh, materials: [material])
        self.name = name
        self.components.set(HoverEffectComponent())
        self.components.set(InputTargetComponent())
        self.generateCollisionShapes(recursive: true)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    func move(to target: SIMD3<Float>, duration: TimeInterval) {
        
        guard let scene = self.scene else {
            assertionFailure("Entity must be part of a scene to perform move animation.")
            return
        }

        let startPos = self.position
        let startTime = Date()
                
        scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
            guard let self = self else { return }
            
            let elapsed = Date().timeIntervalSince(startTime)
            let progress = min(Float(elapsed / duration), 1.0)
            let newPos = startPos + (target - startPos) * progress
            
            if !self.isDragging {self.position = newPos}
            
            /*
            if progress >= 1.0 {
                self.unsub()
            }
             */
        }.store(in: &cancellables)


    }
    
    func unsub() {
        cancellables.removeAll()
    }
}

class Edge: Entity, HasModel, HasCollision {
    var nodeA: Node
    var nodeB: Node
    private var cancellables: [AnyCancellable] = []
    
    init(from: Node, to: Node, mesh: MeshResource, material: SimpleMaterial) {
        self.nodeA = from
        self.nodeB = to
        super.init()
        self.model = ModelComponent(mesh: mesh, materials: [material])
        self.name = nodeA.name + " -> " + nodeB.name
        self.components.set(HoverEffectComponent())
        self.components.set(InputTargetComponent())
        self.generateCollisionShapes(recursive: true)
        
        from.publisher.merge(with: to.publisher)
        .sink { [weak self] _ in
            self?.updateEdge(from: from, to: to)
        }.store(in: &cancellables)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    private func updateEdge(from startNode: Node, to endNode: Node) {
        let startPos = startNode.position
        let endPos = endNode.position
            
        // Recalculate attributes
        let newPosition = (startPos + endPos) / 2
        let newRotation = simd_quatf(from: [0, 1, 0], to: simd_normalize(endPos - startPos))
        let newScale = SIMD3<Float>(1.0, simd_distance(startPos, endPos) / 0.1, 1.0)
        
        // Move edge
        self.scale = newScale
        self.position = newPosition
        self.orientation = newRotation
    
    }
}

// Class to model protein graph objects
class Graph: ObservableObject {
    private var proteins: [Protein] = []
    private var interactions: [Interaction] = []
    @Published var nodes: [Node] = []
    @Published var edges: [Edge] = []
    @Published var positions: [SIMD3<Float>] = []
    private var workItems: [DispatchWorkItem] = []
    private var sim: Simulation3D<My3DForce> = Simulation(nodeCount: 0, links: [], forceField: My3DForce())
    private var isShown: Bool = false
    private var isLoading: Bool = false
    var cancellables: Set<AnyCancellable> = []
    
    let nodeColors: [UIColor] = [
        UIColor(red: 17.0/255, green: 181.0/255, blue: 174.0/255, alpha: 1.0),
        UIColor(red: 64.0/255, green: 70.0/255, blue: 201.0/255, alpha: 1.0),
        UIColor(red: 246.0/255, green: 133.0/255, blue: 18.0/255, alpha: 1.0),
        UIColor(red: 222.0/255, green: 60.0/255, blue: 130.0/255, alpha: 1.0),
        UIColor(red: 17.0/255, green: 181.0/255, blue: 174.0/255, alpha: 1.0),
        UIColor(red: 114.0/255, green: 224.0/255, blue: 106.0/255, alpha: 1.0),
        UIColor(red: 22.0/255, green: 124.0/255, blue: 243.0/255, alpha: 1.0),
        UIColor(red: 115.0/255, green: 38.0/255, blue: 211.0/255, alpha: 1.0),
        UIColor(red: 232.0/255, green: 198.0/255, blue: 0.0/255, alpha: 1.0),
        UIColor(red: 203.0/255, green: 93.0/255, blue: 2.0/255, alpha: 1.0),
        UIColor(red: 0.0/255, green: 143.0/255, blue: 93.0/255, alpha: 1.0),
        UIColor(red: 188.0/255, green: 233.0/255, blue: 49.0/255, alpha: 1.0),
    ]
    
    let nodeMaterials: [PhysicallyBasedMaterial]
    let edgeMaterial = SimpleMaterial(color: UIColor(white: 1.0, alpha: 0.5), isMetallic: false)

    
    // Create a template entity for protein descriptions
    let descTemplate = ModelEntity(mesh: MeshResource.generateText(""),
                                   materials: [UnlitMaterial(color: .black)])
    let window = MeshResource.generatePlane(width: 0.17, height: 0.115, cornerRadius: 0.01)
    let windowTemplate: ModelEntity
    
    // Mesh for nodes
    let sphereMesh = MeshResource.generateSphere(radius: 0.01)
    
    // Create template for node labels
    let labelMesh = MeshResource.generateText("",
                                          extrusionDepth: 0,
                                          font: .systemFont(ofSize: 0.01),
                                          alignment: .left)
    let labelTemplate : ModelEntity
    
    
    // Define force component
    private struct My3DForce: ForceField3D {
        typealias Vector = SIMD3<Float>
        
        var force = CompositedForce<Vector, _, _> {
            Kinetics3D.CenterForce(center: .zero, strength: 1)
            Kinetics3D.ManyBodyForce(strength: -1)
            Kinetics3D.LinkForce(stiffness: .constant(0.5))
        }
    }
    
    // Declare singleton instance of Graph
    static let shared = Graph()
    private init() {
        // Define an array of node materials
        nodeMaterials = nodeColors.map { c in
            var material = PhysicallyBasedMaterial()
            material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: c)
            material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 1.0)
            material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 0.01)
            
            material.emissiveColor = PhysicallyBasedMaterial.EmissiveColor(color: c)
            material.emissiveIntensity = 0.4
            return material
        }
        
        // Set templates
        descTemplate.position = SIMD3<Float>(-0.07, -0.045, 0.000001)
        descTemplate.name = "desc"
        
        windowTemplate = ModelEntity(mesh: window, materials: [UnlitMaterial(color: .white)])
        windowTemplate.position = SIMD3<Float>(0.1, 0, 0)
        windowTemplate.name = "descWindow"
        windowTemplate.addChild(descTemplate)
        windowTemplate.isEnabled = false
        
        labelTemplate = ModelEntity(mesh: labelMesh, materials: [UnlitMaterial(color: .white)])
        labelTemplate.position = SIMD3<Float>(-0.015, 0.01, 0)
        labelTemplate.name = "label"
        
    }
    
    func setData(p: [Protein], i: [Interaction]) {
        self.proteins = p
        self.interactions = i
        buildSim()
    }
    
    func getNodes() -> [Node] {return self.nodes}
    func getEdges() -> [Edge] {return self.edges}
    func getProteins() -> [Protein] {return self.proteins}
    func getInteractions() -> [Interaction] {return self.interactions}
    func getIsShown() -> Bool {return self.isShown}
    func toggleIsShown() {self.isShown.toggle()}
    func getIsLoading() -> Bool {return self.isLoading}
    func toggleIsLoading() {self.isLoading.toggle()}
    func clear() {
        self.proteins = []
        self.interactions = []
        self.nodes = []
        self.edges = []
        self.positions = []
        for workItem in workItems { workItem.cancel() }
        workItems.removeAll()
    }
    
    // Build simulation for force-directed drawing
    private func buildSim() {
        let links = self.interactions.map { i in
            let fromID = self.proteins.firstIndex { mn in
                mn.getPreferredName() == i.getProteinA()
            }!
            let toID = self.proteins.firstIndex { mn in
                mn.getPreferredName() == i.getProteinB()
            }!
            return EdgeID(source: fromID, target: toID)
        }
        
        sim = Simulation(
            nodeCount: self.proteins.count,
            links: links,
            forceField: My3DForce()
        )
        
        // Set initial positions
        tickSim()
    }
    
    // Update positions after single iteration
    private func tickSim() {
        sim.tick()
        let scaleRatio: Float = 0.0081
        self.positions = sim.kinetics.position.asArray().map { pos in
            simd_float3(
                (pos[1]) * scaleRatio,
                -(pos[0]) * scaleRatio,
                (pos[2]) * scaleRatio + 0.25
        )}
    }
    
    // Run simulation to obtain optimal positions
    private func runSim() {
        for i in 1..<450 {
            let workItem = DispatchWorkItem { [weak self] in
                self?.tickSim()
            }
            workItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1, execute: workItem)
        }
    }
    
    func createModel() {
        createNodes()
        createEdges()
        runSim()
    }
    
    private func createNodes() {
        // Create entities for proteins
        for (index, p) in proteins.enumerated() {
            let proteinObject = Node(name: p.getPreferredName(),
                                     position: positions[index],
                                     mesh: sphereMesh,
                                     material: nodeMaterials[index%nodeMaterials.count])
            
            // Add protein name
            let labelEntity = labelTemplate.clone(recursive: true)
            let newLabel = MeshResource.generateText(p.getPreferredName(),
                                                     extrusionDepth: 0,
                                                     font: .systemFont(ofSize: 0.01),
                                                     alignment: .left)
            labelEntity.model?.mesh = newLabel
            
            // Clone template and replace mesh
            let windowEntity = windowTemplate.clone(recursive: true)
            if let descEntity = windowEntity.children.first as? ModelEntity {
                let newMesh = MeshResource.generateText(p.getAnnotation(),
                                                        extrusionDepth: 0,
                                                        font: .systemFont(ofSize: 0.008),
                                                        containerFrame: CGRect(x: -0.01, y: -0.0075,
                                                                               width: 0.16,
                                                                               height: 0.1),
                                                        alignment: .left,
                                                        lineBreakMode: .byWordWrapping)
                descEntity.model?.mesh = newMesh
            }
                
            // Add children entites to proteinObject
            proteinObject.addChild(windowEntity)
            proteinObject.addChild(labelEntity)
                
            nodes.append(proteinObject)
        }
    }
    
    private func createEdges() {
        // Create entities for edges
        for i in interactions {
                
            // Retrieve proteins
            let p1 = nodes.first(where: { $0.name == i.getProteinA()})!
            let p2 = nodes.first(where: { $0.name == i.getProteinB()})!
            
            // Create edge
            let rad = 0.0005 + (0.0015 - 0.0005) * i.getScore()
            let line = MeshResource.generateCylinder(height: 0.1, radius: Float(rad))
            let lineEntity = Edge(from: p1, to: p2, mesh: line, material: edgeMaterial)
            
            edges.append(lineEntity)
        }
    }
}
