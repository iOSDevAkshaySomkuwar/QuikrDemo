//
//  Model.swift
//  Quikr Demo
//
//  Created by Akshay Somkuwar on 07/12/19.
//  Copyright © 2019 Akshay Somkuwar. All rights reserved.
//

import Foundation

struct AdModel: Codable {
    var title: String = String()
    var description: String = String()
    var image: String = String()
    var price: String = String()
    init() {
        self.title = ""
        self.description = ""
        self.image = ""
        self.price = ""
    }
    init(json: [String: Any]) {
        self.title = json["title"] as? String ?? ""
        self.description = json["description"] as? String ?? ""
        self.image = json["image"] as? String ?? ""
        self.price = json["price"] as? String ?? ""
    }
}
