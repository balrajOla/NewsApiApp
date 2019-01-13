//
//  NewsSearchDataService.swift
//  NewsApi
//
//  Created by Balraj Singh on 12/01/19.
//  Copyright © 2019 balraj. All rights reserved.
//

import Foundation
import PromiseKit

struct NewsSearchDataService {
    var searchTask: URLSessionDataTask?
    
    let restService = RESTService(baseUrl: "https://newsapi.org")
    
    mutating func search(forWord word: String, pageNo: Int) -> Promise<NewsApiResponse> {
        // cancel the previous task
        searchTask?.cancel()
        
        // create request resource
        let searchRequestResource = Resource<NewsApiResponse, CustomError>(jsonDecoder: JSONDecoder(), path: self.searchRequestUrlMaker(forWord: word, pageNo: pageNo))
        
        return Promise<NewsApiResponse> { seal in
            // make request
            searchTask = self.restService.load(resource: searchRequestResource) { response in
                switch response {
                case .success(let searchResponse):
                    seal.fulfill(searchResponse)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    private func searchRequestUrlMaker(forWord word: String, pageNo: Int) -> String {
        return "/v2/everything?q=\(word)&sortBy=popularity&apiKey=fb9762af11314beeb697ade56b3805ca&page=\(pageNo)"
    }
}
