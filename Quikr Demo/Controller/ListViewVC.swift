//
//  ListViewVC.swift
//  Quikr Demo
//
//  Created by Akshay Somkuwar on 11/12/19.
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
import FirebaseStorage
import Firebase
import YPImagePicker

class ListViewVC: UIViewController {
    
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

    var groupsTV: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.tableFooterView = UIView()
        return tv
    }()
    
    var data: [String] = [] {
        didSet {
            groupsTV.reloadData()
        }
    }
    
    var refreshControl: UIRefreshControl!
    var controller = UIImagePickerController()
    var videoFileName = "firstVideo.mp4"
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        initialSetup()
        handlers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        reload()
    }
    
    func setupViews() {
        view.addSubview(groupsTV)
        groupsTV.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(0)
            make.right.equalTo(view.snp.right).offset(0)
            make.top.equalTo(view.snp.top).offset(0)
            make.bottom.equalTo(view.snp.bottom).offset(0)
        }
    }
    
    func initialSetup() {
        view.backgroundColor = .white
        groupsTV.delegate = self
        groupsTV.dataSource = self
        groupsTV.register(SelectGroupsCell.self, forCellReuseIdentifier: SelectGroupsCell.identifier)
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        groupsTV.addSubview(refreshControl)
//        let leftBarButton = UIBarButtonItem(title: "Library", style: UIBarButtonItem.Style.plain, target: self, action: #selector(viewLibrary(_:)))
//        self.navigationItem.leftBarButtonItem = leftBarButton
        let rightBarButton = UIBarButtonItem(title: "Camera", style: UIBarButtonItem.Style.plain, target: self, action: #selector(takeVideo(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
        UIViewController.preventPageSheetPresentation
    }
    
    func handlers() {
        
    }
   
    @objc func reload() {
        data.removeAll()
        for each in FileManager.default.urls(for: .documentDirectory) ?? [] {
            data.append(each.absoluteString)
        }
        refreshControl.endRefreshing()
        
        getStoreData()
        
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
                    MobileFFmpeg.execute("-i \(selectedVideo) \(dataPath)")
                    self.reload()
                }
            }
            picker.popToRootViewController(animated: true)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func takeVideo(_ sender: Any) {
        // 1 Check if project runs on a device with camera available
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            // 2 Present UIImagePickerController to take video
//            controller.sourceType = .camera
//            controller.cameraDevice = .rear
//            controller.showsCameraControls = true
//            controller.mediaTypes = [kUTTypeMovie as String]
//            controller.delegate = self
//            present(controller, animated: true, completion: nil)
//        }
//        else {
//            print("Camera is not available")
//        }
        
        self.present(self.picker, animated: true, completion: nil)
    }

    @objc func viewLibrary(_ sender: Any) {
        // Display Photo Library
        controller.sourceType = UIImagePickerController.SourceType.photoLibrary
        controller.mediaTypes = [kUTTypeMovie as String]
        controller.delegate = self
            
        present(controller, animated: true, completion: nil)
    }
}

extension ListViewVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupsTV.dequeueReusableCell(withIdentifier: SelectGroupsCell.identifier, for: indexPath) as! SelectGroupsCell
        let data = self.data[indexPath.row]
        cell.groupTitleL.text = data
        cell.groupIconIV.image = self.generateThumbnail(path: URL(string: data)!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //        saveVideoToLibrary(url: data[indexPath.row])
        //        playVideo(url: data[indexPath.row])
        let vc = VideoDetailVC() as! VideoDetailVC
        vc.videoUrl = data[indexPath.row]
        vc.secondUrl = data[exist: indexPath.row + 1] ?? ""
        vc.thirdUrl = data[exist: indexPath.row + 2] ?? ""
        vc.count = data.count
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func performOperation(indexPath: IndexPath) {
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
        let dataPath = documentsDirectory.appendingPathComponent("\(indexPath.row).mp4")
        MobileFFmpeg.execute("-i \(data[indexPath.row]) \(dataPath)")
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
    
    private func playVideo(url: String) {
        let player = AVPlayer(url: URL(string: url)!)
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
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
    
    func getStoreData() {
        let store = Storage.storage()
        let storeRef = store.reference()
        let firstFile = storeRef.child("Task_Apple.mp4")
        let secondFile = storeRef.child("Tasks_Breathless.mp4")
        
        firstFile.getData(maxSize: (4 * 1024 * 1024)) { (data, error) in
            if let error = error {
                print("Error \(error)")
            } else {
                if let data = data {
                    self.saveVideoToLibrary(data: data, name: "Task_Apple")
                }
            }
        }
        
        secondFile.getData(maxSize: (4 * 1024 * 1024)) { (data, error) in
            if let error = error {
                print("Error \(error)")
            } else {
                if let data = data {
                    self.saveVideoToLibrary(data: data, name: "Tasks_Breathless")
                }
            }
        }
    }
    
    func saveVideoToLibrary(data: Data?, name: String) {
        if let data = data {
            DispatchQueue.global(qos: .background).async {
                let urlData = NSData(data: data)
                let paths = NSSearchPathForDirectoriesInDomains(
                    FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
                let dataPath = documentsDirectory.appendingPathComponent("\(name).mp4")
                DispatchQueue.main.async {
                    urlData.write(to: dataPath, atomically: true)
                    self.reload()
                }
            }
        }
    }
}


extension ListViewVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedVideo:URL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
            let paths = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
            let name = String.random()
            let dataPath = documentsDirectory.appendingPathComponent("\(name).mp4")
            MobileFFmpeg.execute("-i \(selectedVideo) \(dataPath)")
//            MobileFFmpeg.execute("-i \(selectedVideo) -vf scale=480:480,setdar=1:1 \(dataPath)")
            MobileFFmpeg.getLastReturnCode()
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


class SelectGroupsCell: UITableViewCell {
    var groupIconIV: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 0
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    var groupTitleL: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .black
        label.text = "Human Responsibilities"
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(groupIconIV)
        addSubview(groupTitleL)
        
        groupIconIV.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(0)
            make.centerY.equalTo(self).offset(0)
            make.top.bottom.equalTo(self).offset(0)
            make.width.equalTo(self).multipliedBy(0.4)
//            make.height.width.equalTo(40)
        }
        
        groupTitleL.snp.makeConstraints { (make) in
            make.left.equalTo(groupIconIV.snp.right).offset(15)
            make.centerY.equalTo(groupIconIV).offset(0)
            make.right.equalTo(self).offset(-10)
            make.top.equalTo(self).offset(10)
            make.bottom.equalTo(self).offset(-10)
        }
    }
}


