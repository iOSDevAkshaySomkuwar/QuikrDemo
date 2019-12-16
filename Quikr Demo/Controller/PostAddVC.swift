//
//  PostAddVC.swift
//  Quikr Demo
//
//  Created by Akshay Somkuwar on 06/12/19.
//  Copyright © 2019 Akshay Somkuwar. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CropViewController
import mobileffmpeg

class PostAddVC: UIViewController {
    
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
    
    var priceTF: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(5)
        textField.backgroundColor = UIColor.groupTableViewBackground
        textField.textColor = UIColor.black
        textField.layer.cornerRadius = 9
        textField.isSecureTextEntry = false
        textField.placeholder = "Please enter price"
        textField.keyboardType = .phonePad
        textField.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        return textField
    }()
    
    var uploadImageTF: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(5)
        textField.backgroundColor = UIColor.groupTableViewBackground
        textField.textColor = UIColor.black
        textField.layer.cornerRadius = 9
        textField.isSecureTextEntry = false
        textField.placeholder = "Please select image"
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
    
    var selectedImageString: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        initialSetup()
        handlers()
    }
    
    func setupViews() {
        view.addSubview(titleTF)
        view.addSubview(priceTF)
        view.addSubview(descriptionTV)
        view.addSubview(uploadImageTF)
        view.addSubview(submitAdButton)
        
        titleTF.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.top.equalTo(view.snp.top).offset(100)
            make.height.equalTo(40)
        }
        
        priceTF.snp.makeConstraints { (make) in
            make.left.equalTo(titleTF.snp.left).offset(0)
            make.right.equalTo(titleTF.snp.right).offset(0)
            make.top.equalTo(titleTF.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        descriptionTV.snp.makeConstraints { (make) in
            make.left.equalTo(titleTF.snp.left).offset(0)
            make.right.equalTo(titleTF.snp.right).offset(0)
            make.top.equalTo(uploadImageTF.snp.bottom).offset(10)
            make.height.equalTo(400)
        }
        
        uploadImageTF.snp.makeConstraints { (make) in
            make.left.equalTo(titleTF.snp.left).offset(0)
            make.right.equalTo(titleTF.snp.right).offset(0)
            make.top.equalTo(priceTF.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        submitAdButton.snp.makeConstraints { (make) in
            make.left.equalTo(titleTF.snp.left).offset(0)
            make.right.equalTo(titleTF.snp.right).offset(0)
            make.top.equalTo(descriptionTV.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        
    }
    
    func initialSetup() {
        title = "Post Ad"
        view.backgroundColor = .white
        uploadImageTF.delegate = self
        priceTF.delegate = self
        titleTF.delegate = self
    }
    
    func handlers() {
        submitAdButton.pressed = { (sender) in
            self.createEntry()
        }
    }
    
    @objc func createEntry() {
        let data = [
            "title": titleTF.text!,
            "description": descriptionTV.text!,
            "price": priceTF.text!,
            "image": selectedImageString
        ]
        // Add a new document in collection "cities"
        let db = Firestore.firestore()
        db.collection("Ads").addDocument(data: data, completion: { err in
        if let err = err {
            print("Error writing document: \(err)")
        } else {
            print("Document successfully written!")
            self.navigationController?.popViewController(animated: true)
        }
        })

    }
    
    func testFFMPEG(data: String) {
//        MobileFFmpeg.execute("ffmpeg -i sampleOne.mp4 sample.mp3")
        let command = """
\(data)
"""
        MobileFFmpeg.execute(command)
        let commandOutput = MobileFFmpeg.getLastCommandOutput()
        print(commandOutput)
        descriptionTV.text = commandOutput!
//        let b = FileManager.default.urls(for: .documentDirectory,
//        in: .userDomainMask)
//        print(b)
                
        //        Bundle.main.url(forResource: audioFileName, withExtension: "mp4")
        //        if let audioFilePath = Bundle.main.path(forResource: audioFileName, ofType: "mp4") {
        //            print(audioFilePath)
        //            let audioFileName = "sampleOne"
        //        let mediaInfo = MobileFFmpeg.getMediaInformation(String(describing: audioFilePath))
        //        print(mediaInfo)
        //            let commandCode = MobileFFmpeg.getLastReturnCode()
        //            print(commandCode)
        
        //        }
    }
    
}


extension PostAddVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate, CropViewControllerDelegate, UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == uploadImageTF {
            self.openPhotosAction()
        }
    }
    
    @objc func openPhotosAction() {
        uploadImageTF.text = ""
        uploadImageTF.resignFirstResponder()
        titleTF.resignFirstResponder()
        priceTF.resignFirstResponder()
        descriptionTV.resignFirstResponder()
        view.resignFirstResponder()
        view.endEditing(true)
        showActionSheet()
    }
    
    func goToView(image: UIImage){
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.aspectRatioPreset = .preset4x3
        self.navigationController?.pushViewController(cropViewController, animated: true)
//        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        self.dismiss(animated: true, completion: nil)
        self.goToView(image: pickedImage)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        uploadImageTF.text = "Image is selected"
        selectedImageString = image.base64(format: ImageFormat.jpeg(0.5))!
        
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true, completion: nil)
        
    }
    
    func showActionSheet() {
        let alert:UIAlertController = UIAlertController(title: "Choose Image",
                                                        message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) { UIAlertAction in
            self.camera()
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) { UIAlertAction in
            self.photoLibrary()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) { UIAlertAction in
        }
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceView?.center = view.center
        }
    }
    
    // show camera
    func camera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            self.present(myPickerController, animated: true, completion: nil)
            
        }
        
    }
    
    // show photo library
    func photoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
           
        }
    }
}
