//
//  AddVideoVC.swift
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
import SDWebImage
import FlexibleAVCapture
import YPImagePicker

class AddVideoVC: UIViewController {
    let flexibleAVCaptureVC: FlexibleAVCaptureViewController = FlexibleAVCaptureViewController()
    
    var controller = UIImagePickerController()
    var videoUrl = "" {
        didSet {
            videoIV.image = self.generateThumbnail(path: URL(string: videoUrl)!)
        }
    }
    
    var removeTempData: [String] = []
    
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
    
    let slidingCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()//MediaCollectionViewLayout()//UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        //        cv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        cv.isPagingEnabled = false
        cv.backgroundColor = UIColor.clear
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    var data: [String] = [] {
        didSet {
            self.slidingCV.reloadData()
        }
    }
    
    // Build a picker with your configuration
    let picker: YPImagePicker = {
        var config = YPImagePickerConfiguration()
        config.library.onlySquare = false
        config.onlySquareImagesFromCamera = true
        config.targetImageSize = .original
        config.usesFrontCamera = true
        config.showsPhotoFilters = true
        config.shouldSaveNewPicturesToAlbum = true
        config.video.compression = AVAssetExportPresetHighestQuality
        config.albumName = "MyGreatAppName"
        config.screens = [.video]//[.library, .photo, .video]
        config.startOnScreen = .video
        config.video.recordingTimeLimit = 10
        config.video.libraryTimeLimit = 20
        config.showsCrop = .rectangle(ratio: (16/9))
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
        config.library.mediaType = .video
        //        config.overlayView = myOverlayView
        
        let picker = YPImagePicker(configuration: config)
        return picker
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
        view.addSubview(slidingCV)
        
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
        
        slidingCV.snp.makeConstraints { (make) in
            make.left.right.equalTo(view).offset(0)
            make.top.equalTo(addVideoButton.snp.bottom).offset(20)
            make.height.equalTo(100)
        }
        
    }
    
    func initialSetup() {
        view.backgroundColor = .white
        slidingCV.register(ProductByCategoryCell.self, forCellWithReuseIdentifier: ProductByCategoryCell.identifier)
        slidingCV.delegate = self
        slidingCV.dataSource = self
        self.flexibleAVCaptureVC.delegate = self
//        self.flexibleAVCaptureVC.allowsResizing = false
//        self.flexibleAVCaptureVC.canSetVideoQuality(AVCaptureSession.Preset.medium)
        data.append(self.videoUrl)
        
    }
    
    func handlers() {
        playVideoButton.pressed = { (sender) in
            self.playVideo(url: self.videoUrl)
        }
        
        addVideoButton.pressed = { (sender) in
            self.addVideo()
        }
        
//        picker.delegate = self
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if let video = items.singleVideo {
                print(video.fromCamera)
                print(video.thumbnail)
                print(video.url)
                if let selectedVideo:URL = (video.url as? URL) {
                    let paths = NSSearchPathForDirectoriesInDomains(
                        FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                    let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
                    let name = String.random()
                    let dataPath = documentsDirectory.appendingPathComponent("\(name).mp4")
//                    MobileFFmpeg.execute("-i \(selectedVideo) \(dataPath)")
//                    //            MobileFFmpeg.execute("-i \(selectedVideo) -vsync 2 -vf scale=480:480,setdar=1:1 \(dataPath)")
//                    MobileFFmpeg.getLastReturnCode()
                    self.data.append(String(describing: selectedVideo))
                    self.removeTempData.append(String(describing: selectedVideo))
                }
            }
            picker.popToRootViewController(animated: true)
            picker.dismiss(animated: true, completion: nil)
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
    
    private func addVideo() {
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
        let name = String.random()
        let dataPath = documentsDirectory.appendingPathComponent("concated\(name).mp4")
        
        
        var sourcesArray: [String] = self.data
        
        //Getting sources
        var sources = ""
        for (index, each) in sourcesArray.enumerated() {
            sources += "-i \(each) "
        }
        
        //Getting audio vieo tracks for audio and video
        var audioVideoSources = ""
        for (index, each) in sourcesArray.enumerated() {
            //            audioVideoSources += "[\(index):v] [\(index):a] "
            audioVideoSources += """
            [\(index):v]setpts=PTS-STARTPTS,setsar=1,setdar=1/1,scale=320x320[v\(index)];\n[\(index):a]asetpts=PTS-STARTPTS[a\(index)];
            """
            if (sourcesArray.count - 1) != index {
                audioVideoSources += "\n"
            }
        }
        
        var audioTracks = ""
        for (index, each) in sourcesArray.enumerated() {
            audioTracks += "[v\(index)][a\(index)] "
        }
        
        audioVideoSources += (" " + audioTracks)
        
        //Getting concat video count and track
        var concatCountString = "concat=n=\(sourcesArray.count):v=1:a=1[v][a]"
        
        
        let command = """
        \(sources)\
        -filter_complex "\(audioVideoSources)\(concatCountString)" -map "[v]" -map "[a]" -preset medium -crf 18 \(dataPath) -y
        """
        
        MobileFFmpeg.execute(command)
        let code = MobileFFmpeg.getLastReturnCode()
        if code == 0 {
            let alert = UIAlertController(title: "Videos Merged!", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (alert) in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error occured while merging videos.", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (alert) in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            do {
                let fileManager = FileManager.default
                try fileManager.removeItem(at: dataPath)
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
        
        for each in removeTempData {
            do {
                let fileManager = FileManager.default
                try fileManager.removeItem(at: URL(string: each)!)
            }
            catch let error as NSError {
                print("An error took place: \(error)")
            }
        }
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
    
    @objc func takeVideo() {
        // 1 Check if project runs on a device with camera available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // 2 Present UIImagePickerController to take video
            controller.sourceType = .camera
            controller.cameraDevice = .rear
            controller.allowsEditing = true
            controller.showsCameraControls = true
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
        else {
            print("Camera is not available")
        }
    }
    
    @objc func viewLibrary() {
        // Display Photo Library
        controller.sourceType = UIImagePickerController.SourceType.photoLibrary
        controller.mediaTypes = [kUTTypeMovie as String]
        controller.delegate = self
            
        present(controller, animated: true, completion: nil)
    }
    
}


extension AddVideoVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //pageControl.numberOfPages = farmImagesArray.count
        return (data.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == (data.count) {
            let cell = slidingCV.dequeueReusableCell(withReuseIdentifier: ProductByCategoryCell.identifier, for: indexPath) as! ProductByCategoryCell
            let value = ""
            cell.populate(bannerImageUrl: value)
            return cell
        } else {
            let cell = slidingCV.dequeueReusableCell(withReuseIdentifier: ProductByCategoryCell.identifier, for: indexPath) as! ProductByCategoryCell
            let value = data[indexPath.row]//Int.random(in: 0...6)
            cell.populate(bannerImageUrl: value)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("✅ \(indexPath)")
        if indexPath.row == (data.count) {
//            self.takeVideo()
//            self.viewLibrary()
//            self.present(flexibleAVCaptureVC, animated: true, completion: nil)
            self.present(self.picker, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (Double(Device.SCREEN_WIDTH) * 0.5)
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
}


class ProductByCategoryCell: UICollectionViewCell {
    
    var bgV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var bannerImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = #imageLiteral(resourceName: "icons8-plus-256")
        image.layer.cornerRadius = 0
        image.contentMode = .scaleAspectFill
        image.layer.borderColor = UIColor.clear.cgColor
        image.layer.borderWidth = 2
        image.clipsToBounds = true
        return image
    }()
    
    func populate(bannerImageUrl : String) {
        backgroundColor = UIColor.systemGroupedBackground
        contentView.addSubview(bgV)
        contentView.addSubview(bannerImage)
        
//        if let _url = URL(string: bannerImageUrl) {
//            bannerImage.sd_setImage(with: _url, placeholderImage: UIImage(), options: SDWebImageOptions.highPriority, completed: nil)
//        } else {
//            bannerImage.image = UIImage(named: "icons8-plus-256")
//        }
        
        if bannerImageUrl == "" {
            bannerImage.image = UIImage(named: "icons8-plus-256")
        } else {
            bannerImage.image = generateThumbnail(path: URL(string: bannerImageUrl)!)
        }
        
        bgV.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(4)
            make.top.equalTo(self).offset(4)
            make.right.equalTo(self).offset(-4)
            make.bottom.equalTo(self).offset(-4)
        }
        
        bannerImage.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(bgV).offset(0)
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
    
    
}


extension AddVideoVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate, FlexibleAVCaptureDelegate {
       
    func didCapture(withFileURL fileURL: URL) {
        print(fileURL)
        if let selectedVideo:URL = (fileURL) {
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let name = String.random()
            let dataPath = documentsDirectory.appendingPathComponent("\(name).mp4")
            MobileFFmpeg.execute("-i \(selectedVideo) \(dataPath)")
            //            MobileFFmpeg.execute("-i \(selectedVideo) -vsync 2 -vf scale=480:480,setdar=1:1 \(dataPath)")
            MobileFFmpeg.getLastReturnCode()
            self.data.append(String(describing: dataPath))
            self.removeTempData.append(String(describing: dataPath))
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedVideo:URL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let name = String.random()
            let dataPath = documentsDirectory.appendingPathComponent("\(name).mp4")
            MobileFFmpeg.execute("-i \(selectedVideo) \(dataPath)")
            //            MobileFFmpeg.execute("-i \(selectedVideo) -vsync 2 -vf scale=480:480,setdar=1:1 \(dataPath)")
            MobileFFmpeg.getLastReturnCode()
            self.data.append(String(describing: dataPath))
            self.removeTempData.append(String(describing: dataPath))
        }
        picker.dismiss(animated: true)
    }
    
    @objc func videoSaved(_ video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer){
        if let theError = error {
            print("error saving the video = \(theError)")
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
            })
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
