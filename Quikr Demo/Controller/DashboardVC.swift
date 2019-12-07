//
//  DashboardVC.swift
//  Quikr Demo
//
//  Created by Akshay Somkuwar on 06/12/19.
//  Copyright © 2019 Akshay Somkuwar. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseFirestore
import SDWebImage

class DashboardVC: UIViewController {
    var addsTV: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.tableFooterView = UIView()
        return tv
    }()
    
    var data: [AdModel] = [] {
        didSet {
            addsTV.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        initialSetup()
        handlers()
    }
    
    func setupViews() {
        view.addSubview(addsTV)
        
        addsTV.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left).offset(0)
            make.right.equalTo(view.snp.right).offset(0)
            make.top.equalTo(view.snp.top).offset(0)
            make.bottom.equalTo(view.snp.bottom).offset(0)
        }
    }
    
    func initialSetup() {
        title = "Dashboard"
        view.backgroundColor = .white
        addsTV.delegate = self
        addsTV.dataSource = self
        addsTV.register(AdCell.self, forCellReuseIdentifier: AdCell.identifier)
        addsTV.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        let rightBarButton = UIBarButtonItem(title: "Post Ad", style: UIBarButtonItem.Style.plain, target: self, action: #selector(openPostAdVC))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func handlers() {
        
    }
    
    @objc func openPostAdVC() {
        let vc = PostAddVC() as! PostAddVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func getAds() {
        let db = Firestore.firestore()
        db.collection("Ads").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.data.removeAll()
                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
                    if let _document = document.data() as? [String: Any] {
                        let _object = AdModel(json: _document)
                        self.data.append(_object)
                        print("document appended =>")
                    }
                }
            }
        }
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAds()
    }

}

extension DashboardVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count == 0 ? 1 : data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if data.count == 0 {
            let cell = addsTV.dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath) as! UITableViewCell
            cell.textLabel?.text = "No Ads To Show"
            cell.textLabel?.textAlignment = .center
            return cell
        } else {
            let cell = addsTV.dequeueReusableCell(withIdentifier: AdCell.identifier, for: indexPath) as! AdCell
            cell.object = data[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if tableView == addsTV {
//            let headerView = UIView()
//            let headerCell = tableView.dequeueReusableCell(withIdentifier: AdCell.identifier) as! AdCell
//            headerView.addSubview(headerCell)
//            return headerCell
//        } else {
//            return UIView()
//        }
//    }
    
}


class AdCell: UITableViewCell {
    var itemIV: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 0
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    var titleL: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .white
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 25, weight: UIFont.Weight.bold)
        return label
    }()
    
    var descriptionL: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .white
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)
        return label
    }()
    
    var priceL: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .green
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        return label
    }()
    
    var object: AdModel = AdModel() {
        didSet {
            let strBase64 = object.image
            itemIV.image = base64Convert(base64String: strBase64)
            self.titleL.text = object.title
            self.descriptionL.text = object.description
            self.priceL.text = "₹ " + object.price
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.backgroundColor = .white
        addSubview(itemIV)
        addSubview(titleL)
        addSubview(descriptionL)
        addSubview(priceL)
        
        itemIV.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(0)
            make.right.equalTo(self.snp.right).offset(0)
            make.top.equalTo(self.snp.top).offset(0)
            make.bottom.equalTo(self.snp.bottom).offset(0)
        }
        
        descriptionL.snp.makeConstraints { (make) in
            make.left.equalTo(titleL.snp.left).offset(0)
            make.right.equalTo(titleL.snp.right).offset(0)
            make.bottom.equalTo(itemIV.snp.bottom).offset(-10)
        }
        
        priceL.snp.makeConstraints { (make) in
            make.left.equalTo(titleL.snp.left).offset(0)
            make.right.equalTo(titleL.snp.right).offset(0)
            make.bottom.equalTo(descriptionL.snp.top).offset(-10)
        }
        
        titleL.snp.makeConstraints { (make) in
            make.left.equalTo(itemIV.snp.left).offset(10)
            make.right.equalTo(itemIV.snp.right).offset(-10)
            make.bottom.equalTo(priceL.snp.top).offset(-10)
        }

    }
    
    func base64Convert(base64String: String?) -> UIImage {
        let dataDecoded:Data = Data(base64Encoded: base64String ?? "", options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        if let decodedimage: UIImage = UIImage(data: dataDecoded) {
            return decodedimage
        }
        return UIImage()
    }
 
}


extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
