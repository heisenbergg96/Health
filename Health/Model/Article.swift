//
//  Article.swift
//  Health
//
//  Created by Vikhyath on 28/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import UIKit

class Article {
    
    var title: String
    var description: String
    var urlToImage: String
    var url: String
    
    init(title: String, description: String, urlToImage: String, url: String) {
        
        self.title = title
        self.description = description
        self.urlToImage = urlToImage
        self.url = url
    }
}
