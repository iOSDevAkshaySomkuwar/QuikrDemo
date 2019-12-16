//
//  FFMPEGTestVC.swift
//  Quikr Demo
//
//  Created by Akshay Somkuwar on 10/12/19.
//  Copyright © 2019 Akshay Somkuwar. All rights reserved.
//

import UIKit
import SnapKit
import mobileffmpeg
import MobileCoreServices
import Photos

class FFMPEGTestVC: UIViewController {
    
    var titleTF: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(5)
        textField.backgroundColor = UIColor.groupTableViewBackground
        textField.textColor = UIColor.black
        textField.layer.cornerRadius = 9
        textField.isSecureTextEntry = false
        textField.placeholder = "Please enter title"
        textField.keyboardType = .asciiCapable
        textField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return textField
    }()
    
    var descriptionTV: UITextView = {
        let textField = UITextView()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor.groupTableViewBackground
        textField.textColor = UIColor.black
        textField.layer.cornerRadius = 9
        textField.isSecureTextEntry = false
        textField.keyboardType = .asciiCapable
        textField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return textField
    }()
    
    var submitAdButton: CustomButton = {
        let button = CustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.blue
        button.setTitle("Post Ad", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        button.layer.cornerRadius = 9
        return button
    }()
    
    var cameraButton: CustomButton = {
        let button = CustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.blue
        button.setTitle("Camera", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        button.layer.cornerRadius = 9
        return button
    }()
    
    var libraryButton: CustomButton = {
        let button = CustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.blue
        button.setTitle("Library", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        button.layer.cornerRadius = 9
        return button
    }()
    
    var selectedImageString: String = ""
    
    var controller = UIImagePickerController()
    let videoFileName = "test2.mp3"
    
    var urlsArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        initialSetup()
        handlers()
    }
    
    func setupViews() {
        view.addSubview(titleTF)
        view.addSubview(descriptionTV)
        view.addSubview(submitAdButton)
        view.addSubview(cameraButton)
        view.addSubview(libraryButton)
        
        titleTF.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.top.equalTo(view.snp.top).offset(100)
            make.height.equalTo(40)
        }
        
        descriptionTV.snp.makeConstraints { (make) in
            make.left.equalTo(titleTF.snp.left).offset(0)
            make.right.equalTo(titleTF.snp.right).offset(0)
            make.top.equalTo(titleTF.snp.bottom).offset(10)
            make.height.equalTo(400)
        }
        
        submitAdButton.snp.makeConstraints { (make) in
            make.left.equalTo(titleTF.snp.left).offset(0)
            make.right.equalTo(titleTF.snp.right).offset(0)
            make.top.equalTo(descriptionTV.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        cameraButton.snp.makeConstraints { (make) in
            make.left.equalTo(titleTF.snp.left).offset(0)
            make.right.equalTo(titleTF.snp.right).offset(0)
            make.top.equalTo(submitAdButton.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        libraryButton.snp.makeConstraints { (make) in
            make.left.equalTo(titleTF.snp.left).offset(0)
            make.right.equalTo(titleTF.snp.right).offset(0)
            make.top.equalTo(cameraButton.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        
    }
    
    func initialSetup() {
        title = "FFMpeg"
        view.backgroundColor = .white
        requestPhotoAuthorization()
        print(FileManager.default.urls(for: .documentDirectory) ?? "none")
    }
    
    func handlers() {
        submitAdButton.pressed = { (sender) in
            self.testFFMPEG(data: self.titleTF.text!)
        }
        
        cameraButton.pressed = { (sender) in
            self.takeVideo(sender)
        }
        
        libraryButton.pressed = { (sender) in
            self.viewLibrary(sender)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @objc func testFFMPEG(data: String) {
        let command = """
        \(data)
        """
        MobileFFmpeg.execute(command)
        let commandOutput = MobileFFmpeg.getLastCommandOutput()
        print(commandOutput)
        descriptionTV.text = commandOutput!
    }
    
    @objc func takeVideo(_ sender: Any) {
        // 1 Check if project runs on a device with camera available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // 2 Present UIImagePickerController to take video
            controller.sourceType = .camera
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
        else {
            print("Camera is not available")
        }
    }

    @objc func viewLibrary(_ sender: Any) {
        // Display Photo Library
        controller.sourceType = UIImagePickerController.SourceType.photoLibrary
        controller.mediaTypes = [kUTTypeMovie as String]
        controller.delegate = self
            
        present(controller, animated: true, completion: nil)
    }
    
    
}


extension FFMPEGTestVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 1
        if let selectedVideo:URL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
            // Save video to the main photo album
            let selectorToCall = #selector(FFMPEGTestVC.videoSaved(_:didFinishSavingWithError:context:))
            
            // 2
            UISaveVideoAtPathToSavedPhotosAlbum(selectedVideo.relativePath, self, selectorToCall, nil)
            // Save the video to the app directory
            let videoData = try? Data(contentsOf: selectedVideo)
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let dataPath = documentsDirectory.appendingPathComponent(videoFileName)
            do {
                try! videoData?.write(to: dataPath, options: [])
            } catch (let error) {
                print(error)
            }
        }
        // 3
        picker.dismiss(animated: true)
    }
    
    @objc func videoSaved(_ video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer){
        if let theError = error {
            print("error saving the video = \(theError)")
        } else {
           DispatchQueue.main.async(execute: { () -> Void in
            self.saveVideoToLibrary()
           })
        }
    }
    
    func saveVideoToLibrary() {
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
        let dataPath = documentsDirectory.appendingPathComponent(videoFileName)
        let dataPath1 = documentsDirectory.appendingPathComponent("akshay.mp3")
        MobileFFmpeg.execute("-i \(dataPath) \(dataPath1)")
        let commandOutput = MobileFFmpeg.getLastCommandOutput()
        print(commandOutput)
        descriptionTV.text = commandOutput!
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: dataPath1)
        }) { saved, error in
            if saved {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).firstObject
                // fetchResult is your latest video PHAsset
                // To fetch latest image  replace .video with .image
            }
        }
    }
    
    func requestPhotoAuthorization() {
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()

        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
        }

        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
        }

        else if (status == PHAuthorizationStatus.notDetermined) {

            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in

                if (newStatus == PHAuthorizationStatus.authorized) {

                }

                else {

                }
            })
        }

        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
        }

    }
}

extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}
