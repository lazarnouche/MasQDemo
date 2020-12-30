//
//  MaskViewController.swift
//  MasQDemo
//
//  Created by Laurent Azarnouche on 12/30/20.
//  Copyright © 2020 Bucephal. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit
import ARVideoKit

class MaskViewController: UIViewController, ARSCNViewDelegate {
    
    
    var recorder: RecordAR?
    var analysis = ""
    var togglePhoto = true
    var maskNode = SCNReferenceNode()
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet var shutterView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = ""
        sceneView.delegate = self
        guard ARFaceTrackingConfiguration.isSupported else { return }
        print(ARFaceTrackingConfiguration.supportedVideoFormats)
        // Initialize with SpriteKit scene
        recorder = RecordAR(ARSceneKit: sceneView)
        
        // Specifiy supported orientations
        recorder?.inputViewOrientations = [.portrait, .landscapeLeft, .landscapeRight]
        createMask()
        
        
    }
    
    
    func createMask(){
        
        
        
        let targetUrl = maskOptions.currentIndex()
        maskNode = SCNReferenceNode(url: targetUrl)!
        maskNode.load()
        maskNode.light = SCNLight()
        maskNode.rotation = SCNVector4(x: 0, y: 0, z: 0, w: 1)
        maskNode.light!.type = .directional
        maskNode.light!.castsShadow = true
        maskNode.light?.shadowMode = .deferred
        
        
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            print("Error Saving ARKit Scene \(error)")
        } else {
            print("ARKit Scene Successfully Saved")
        }
    }
    
    
    func takePhoto(){
        shutterView.alpha = 1.0
        shutterView.isHidden = false
        if let soundURL = Bundle.main.url(forResource: "shutter", withExtension: ".mp3"){
            var mySound : SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
            AudioServicesPlayAlertSound(mySound)
        }
        
        UIView.animate(withDuration: 0.5) {
            self.shutterView.alpha = 0.0
        } completion: { (finished) in
            self.shutterView.isHidden = false
            
            
            MaskApi.imagewithMask = self.sceneView.snapshot()
            
            self.sceneView.scene.rootNode.enumerateChildNodes { (faceNode, _) in
                if let faceNodeName = faceNode.name{
                    if faceNodeName == "face"{
                        faceNode.geometry!.firstMaterial?.transparency = 0
                        self.maskNode.removeFromParentNode()
                        
                    }
                }
            }
            MaskApi.imagewitouthMask = self.sceneView.snapshot()
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateAvatarImage"), object: nil)
            
        }
        
    }
    
    @IBAction func gifAction(_ sender: UIButton) {
        
        takePhoto()
        
        
    }
    
    @IBAction func faceAction(_ sender: UIButton) {
        
        
        sceneView.scene.rootNode.enumerateChildNodes { (faceNode, _) in
            if let faceNodeName = faceNode.name{
                if faceNodeName == "face"{
                    faceNode.geometry!.firstMaterial?.transparency = 1
                    textureOptions.next()
                    faceNode.geometry?.firstMaterial?.diffuse.contents =
                        UIImage(named: textureOptions.currentIndex().absoluteString)
                    
                    self.maskNode.removeFromParentNode()
                    
                }
            }
        }
        
    }
    
    @IBAction func maskAction(_ sender: UIButton) {
        
        self.maskNode.removeFromParentNode()
        
        maskOptions.next()
        self.createMask()
        
        sceneView.scene.rootNode.enumerateChildNodes { (faceNode, _) in
            if let faceNodeName = faceNode.name{
                if faceNodeName == "face"{
                    self.addNodeToFaceNode(facenode: faceNode, masknode: maskNode)
                    
                    
                }
            }
        }
        
        
    }
    
    func addNodeToFaceNode(facenode faceNode: SCNNode, masknode maskNode: SCNNode){
        
        maskNode.position.z = faceNode.boundingBox.min.z
        maskNode.position.y = -0.1
        
        faceNode.geometry!.firstMaterial?.transparency = 0
        faceNode.geometry!.firstMaterial?.lightingModel = .physicallyBased
        faceNode.addChildNode(maskNode)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        recorder?.rest()
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        recorder?.prepare(configuration)
        sceneView.session.run(configuration)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard anchor is ARFaceAnchor else {return nil}
        print("renderer")
        
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)
        let faceNode = SCNNode(geometry: faceGeometry)
        faceNode.name = "face"
        addNodeToFaceNode(facenode: faceNode, masknode: maskNode)
        
        return faceNode
        
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry,
              let faceAnchor = anchor as? ARFaceAnchor
        else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
        expression(anchor: faceAnchor)
        
        DispatchQueue.main.async {
            self.navigationItem.title = self.analysis
        }
        
    }
    
    func expression(anchor: ARFaceAnchor) {
        // 1
        let smileLeft = anchor.blendShapes[.mouthSmileLeft]
        let smileRight = anchor.blendShapes[.mouthSmileRight]
        //        let cheekPuff = anchor.blendShapes[.cheekPuff]
        //        let tongue = anchor.blendShapes[.tongueOut]
        self.analysis = ""
        
        // 2
        if ((smileLeft?.decimalValue ?? 0.0) + (smileRight?.decimalValue ?? 0.0)) > 0.9 {
            self.analysis += ""
        }else{
            self.analysis += "You have to smile! "
        }
        
        //        if cheekPuff?.decimalValue ?? 0.0 > 0.1 {
        //            self.analysis += "Your cheeks are puffed. "
        //        }
        //
        //        if tongue?.decimalValue ?? 0.0 > 0.1 {
        //            self.analysis += "Don't stick your tongue out! "
        //        }
    }
    
}


