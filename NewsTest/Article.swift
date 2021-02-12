//
//  News.swift
//  NewsTest
//
//  Created by JAGRAJ SINGH on 11/02/21.
//

import Foundation
import UIKit.UIImage

class Article: Decodable, Equatable {
    let title: String
    let description: String?
    private let datePublished: String
    let urlToImage: URL?
    
    var image: UIImage?
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = formatter.date(from: datePublished)!
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case title, description, urlToImage
        case datePublished = "publishedAt"
    }
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.title == rhs.title // I've seen that id under source can be nil
    }
}

struct DataResponse: Decodable {
    let articles: [Article]
    let totalResults: Int
}

