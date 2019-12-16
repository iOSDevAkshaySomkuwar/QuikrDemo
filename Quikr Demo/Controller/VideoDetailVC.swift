//
//  VideoDetailVC.swift
//  Quikr Demo
//
//  Created by Akshay Somkuwar on 12/12/19.
//  Copyright © 2019 Akshay Somkuwar. All rights reserved.
//

import UIKit
import SnapKit
import mobileffmpeg
import AVKit
import AVFoundation
import MobileCoreServices
import Photos
import AssetsLibrary

class VideoDetailVC: UIViewController {
    
    var videoUrl = "" {
        didSet {
            videoIV.image = self.generateThumbnail(path: URL(string: videoUrl)!)
        }
    }
    
    var secondUrl = ""
    var thirdUrl = ""
    var count = 0

    var videoIV: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 0
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    var playVideoButton: CustomButton = {
        let button = CustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.orange
        button.setTitle("Play Video", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        button.layer.cornerRadius = 9
        return button
    }()
    
    var addVideoButton: CustomButton = {
        let button = CustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.orange
        button.setTitle("Add Video", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        button.layer.cornerRadius = 9
        return button
    }()
    
    var addImageButton: CustomButton = {
        let button = CustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.orange
        button.setTitle("Add Image", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        button.layer.cornerRadius = 9
        return button
    }()
    
    var addTextButton: CustomButton = {
        let button = CustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.orange
        button.setTitle("Add Text", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        button.layer.cornerRadius = 9
        return button
    }()
    
    var saveVideoButton: CustomButton = {
        let button = CustomButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.orange
        button.setTitle("Save Video To Photos", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        button.layer.cornerRadius = 9
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        initialSetup()
        handlers()
    }
    
    func setupViews() {
        view.addSubview(videoIV)
        view.addSubview(playVideoButton)
        view.addSubview(addVideoButton)
        view.addSubview(addImageButton)
        view.addSubview(addTextButton)
        view.addSubview(saveVideoButton)
        
        videoIV.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(0)
            make.right.equalTo(view.snp.right).offset(0)
            make.top.equalTo(view).offset(80)
            make.height.equalTo(250)
        }
        
        playVideoButton.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(30)
            make.right.equalTo(view.snp.right).offset(-30)
            make.top.equalTo(videoIV.snp.bottom).offset(50)
            make.height.equalTo(40)
        }
        
        addVideoButton.snp.makeConstraints { (make) in
            make.left.equalTo(playVideoButton.snp.left).offset(0)
            make.right.equalTo(playVideoButton.snp.right).offset(0)
            make.top.equalTo(playVideoButton.snp.bottom).offset(20)
            make.height.equalTo(40)
        }
        
        addImageButton.snp.makeConstraints { (make) in
            make.left.equalTo(playVideoButton.snp.left).offset(0)
            make.right.equalTo(playVideoButton.snp.right).offset(0)
            make.top.equalTo(addVideoButton.snp.bottom).offset(20)
            make.height.equalTo(40)
        }
        
        addTextButton.snp.makeConstraints { (make) in
            make.left.equalTo(playVideoButton.snp.left).offset(0)
            make.right.equalTo(playVideoButton.snp.right).offset(0)
            make.top.equalTo(addImageButton.snp.bottom).offset(20)
            make.height.equalTo(40)
        }
        
        saveVideoButton.snp.makeConstraints { (make) in
            make.left.equalTo(playVideoButton.snp.left).offset(0)
            make.right.equalTo(playVideoButton.snp.right).offset(0)
            make.top.equalTo(addTextButton.snp.bottom).offset(20)
            make.height.equalTo(40)
        }
    }
    
    func initialSetup() {
        view.backgroundColor = .white
    }
    
    func handlers() {
        playVideoButton.pressed = { (sender) in
            self.playVideo(url: self.videoUrl)
        }
        
        addVideoButton.pressed = { (sender) in
//            self.addVideo(url: self.videoUrl)
            let vc = AddVideoVC() as! AddVideoVC
            vc.videoUrl = self.videoUrl
            vc.count = self.count
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        saveVideoButton.pressed = { (sender) in
            self.saveVideoToLibrary(url: self.videoUrl)
        }
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
   
    private func playVideo(url: String) {
        let player = AVPlayer(url: URL(string: url)!)
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    private func addVideo(url: String) {
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
        let name = String.random()
        let dataPath = documentsDirectory.appendingPathComponent("concated\(name).mp4")
        
        
        var sourcesArray: [String] = []
        sourcesArray.append(url)
        sourcesArray.append(secondUrl)
//        sourcesArray.append(thirdUrl)
        
        //Getting sources
        var sources = ""
        for (index, each) in sourcesArray.enumerated() {
            sources += "-i \(each) "
        }
        
        //Getting audio vieo tracks for audio and video
        var audioVideoSources = ""
        for (index, each) in sourcesArray.enumerated() {
            audioVideoSources += "[\(index):v] [\(index):a] "
        }
        
        //Getting concat video count and track
        var concatCountString = "concat=n=\(sourcesArray.count):v=1:a=1"
        
        
        let command = """
        \(sources)\
        -filter_complex "\(audioVideoSources)\(concatCountString) [v] [a]" \
        -map "[v]" -map "[a]" \(dataPath)
        """
        
        
        MobileFFmpeg.execute(command)
        MobileFFmpeg.getLastReturnCode()
    }
    
    
    func saveVideoToLibrary(url: String) {
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
        let isVideoCompatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(documentsDirectory.absoluteString)
        
        let library = ALAssetsLibrary()
        library.writeVideoAtPath(toSavedPhotosAlbum: URL(string: url), completionBlock: { (url, error) -> Void in
            // Done! Go check your camera roll
            print(error)
            print(url)
            if error == nil {
                let alert = UIAlertController(title: "File saved in photos!", message: nil, preferredStyle: .alert)
                let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: error?.localizedDescription ?? "", message: nil, preferredStyle: .alert)
                let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
}

