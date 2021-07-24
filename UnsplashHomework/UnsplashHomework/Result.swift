//
//  Result.swift
//  UnsplashHomework
//
//  Created by sjju on 2021/07/22.
//

import UIKit

enum Section {
    case main
}

class Item: Hashable {
    
    var image: UIImage!
    let url: String!
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(image: UIImage, url: String) {
        self.image = image
        self.url = url
    }

}

struct URLs:Codable{
    var small : String
    var thumb : String
    var regular : String
    var full : String
    var raw : String
    
}


