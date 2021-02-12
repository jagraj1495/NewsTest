//
//  NewsFetcher.swift
//  NewsTest
//
//  Created by JAGRAJ SINGH on 11/02/21.
//

import Foundation
import UIKit.UIImage
import Alamofire

class NewsFetcher {
    
    
    
    let apiKey = "" // TODO: Please set your key here
    let url = URL(string: "https://newsapi.org/v2/top-headlines")!
    
    private var sentRequests: [URL: DataRequest] = [:]
    
    private var totalResults: Int = 100
    private var page: Int = 1
    private let pageSize: Int = 10
    private let maximumPages: Int = 10
    
    var canFetchMore: Bool {
        totalResults > (page * pageSize) && maximumPages >= page
    }
    
    func fetchData(_ completion: @escaping ([Article]?, Error?) -> ()) {
        let params: [String : Any] = ["apiKey": apiKey, "country": "us", "page": page, "pageSize": pageSize]
        
        AF.request(url, method: .get, parameters: params, headers: nil).validate().responseData { response in
            
            guard let data = response.data else {
                completion(nil, response.error)
                return
            }
            
            do {
                let data = try JSONDecoder().decode(DataResponse.self, from: data)
                self.totalResults = data.totalResults
                self.page += 1

                completion(data.articles, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func downloadImage(at url: URL, completion: @escaping (UIImage?)->()) {
        let request = AF.request(url, method: .get).validate().responseData { response in
            self.sentRequests[url] = nil
            
            if let data = response.data, let image = UIImage(data: data) {
                completion(image)
            } else {
                // Handle error
                print(response.error)
                completion(nil)
            }
        }
        sentRequests[url] = request
    }
    
    func cancelRequests() {
        sentRequests.forEach {
            $0.value.cancel()
        }
        sentRequests.removeAll()
    }
}


