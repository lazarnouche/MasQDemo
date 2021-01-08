//  DownloadService.swift
//  FaceTrackingModule
//
//  Created by Ben Alem on 12/30/20.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ZIPFoundation
import RealmSwift

class DownloadService{
    
    
    static func preparedownloadMasks(){
        
        self.getunzipedMask()
        if let maskremoteurl = MaskApi.maskRemoteURL, maskremoteurl.isEmpty {
            self.downloadMasks()
            print("======")
            
        }
    }
    
    static func downloadMasks(){
        
        let ref = Ref().storageRoot.child("Mask")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let sourceDirectory = URL.init(fileURLWithPath: paths, isDirectory: true)
        
        
        
        ref.listAll { (result, error) in
            if let error = error{
                print(error)
            }
            print("result result \(result)")
            for item in result.items{
                print("item itm \(item)")
                item.downloadURL { (dataURL, error) in
                    if error != nil {
                        print("Errorr here \(error!.localizedDescription)")
                        return
                    }
                    if let url = dataURL {
                        let fileUrl = sourceDirectory.appendingPathComponent("Data/\(url.lastPathComponent)")
                        let masknameurl = (url.lastPathComponent as NSString).deletingPathExtension
                        let targetUrl = sourceDirectory.appendingPathComponent("Data/\(masknameurl)")
                        if url.pathExtension == "zip"{
                            
                            DownloadService.unzipMasks(from: item, folderUrl: targetUrl, fileUrl: fileUrl)
                            
                        }
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    static func unzipMasks(from item: StorageReference, folderUrl: URL, fileUrl: URL){
        let fileManager = FileManager()
        item.write(toFile: fileUrl) { (url, error) in
            if error != nil {
                print("ERROR FOUND: \(error!)")
            }else{
                print("before \(Thread.isMainThread)")
                let queue = DispatchQueue(label: "work_queue")
                queue.async{
                    do {
                        try fileManager.unzipItem(at: url!, to: folderUrl)
                        
                        let name = (url!.lastPathComponent as NSString).deletingPathExtension
                        let scnURL = URL(string: "\(folderUrl.absoluteString)/\(name)/\(name).scn")
                        
                        
                        print("is main thread \(Thread.isMainThread)")
                        print("current thread is \(Thread.current)")
                        
                        MaskApi.maskRemoteURL!.append(scnURL!)
                        
                        
                        
                    } catch {
                        print("Extraction of ZIP archive failed with error:\(error)")
                    }
                }
                
            }
        }
    }
    
    
    static func getunzipedMask(){
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            if fileURLs.isEmpty{
                print("No files found")
                return
            }
            if let enumerator = FileManager.default.enumerator(at: fileURLs[0], includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                for case let scnURL as URL in enumerator {
                    if scnURL.pathExtension == "scn"{
                        print(scnURL)
                        MaskApi.maskRemoteURL!.append(scnURL)
                        
                    }
                    
                }
            }
            
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
    }
    
    
    
}
