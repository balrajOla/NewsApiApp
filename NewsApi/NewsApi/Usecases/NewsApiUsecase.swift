//
//  NewsApiUsecase.swift
//  NewsApi
//
//  Created by Balraj Singh on 12/01/19.
//  Copyright © 2019 balraj. All rights reserved.
//

import Foundation
import PromiseKit

class NewsApiUsecase {
    //MARK: Private values
    private let minimumKeywordCount = 3
    private let pageSize = 10
    private var searchUtil: SearchHelper<NewsApiResponse>?
    private var paginationUtil: Paginator<NewsApiResponse>?
    private var newsSearchDataService = NewsSearchDataService()
    
    //MARK: DANGEROUS THING TO KEEP
    var lastSearchKeyword: String = ""
    
    //MARK: Public functions
    func register(forPreExecution: @escaping () -> Void, forCompletion completion: @escaping ((keyword: String, result: Result<NewsApiResponse>)) -> Void) {
        self.paginationUtil = Paginator(pageSize: pageSize,
                                        asyncTask: { (page, size) -> Promise<NewsApiResponse> in
                                            return self.getArticles(for: self.lastSearchKeyword, pageNo: page)
        })
        
        
        searchUtil = SearchHelper(minimumKeywordCount: minimumKeywordCount,
                                  preExecutionOperation: { },
                                  query: { searchKey -> Promise<NewsApiResponse> in
                                    return (searchKey.map { keyword -> Promise<NewsApiResponse> in
                                        
                                        forPreExecution()
                                        
                                        if self.lastSearchKeyword.lowercased() == keyword.lowercased() {
                                            return (self.paginationUtil?.fetchNextPage() ?? Promise<NewsApiResponse>(error: ServiceError<CustomError>.other))
                                        } else {
                                            self.lastSearchKeyword = keyword
                                            return (self.paginationUtil?.fetchFirstPage() ?? Promise<NewsApiResponse>(error: ServiceError<CustomError>.other))
                                        }
                                        
                                        } ?? Promise<NewsApiResponse>(error: ServiceError<CustomError>.other))
        },
                                  completion: completion)
    }
    
    func performSearch(for searchKey: String) {
        self.searchUtil?.search(keyword: searchKey)
    }
    
    //MARK: Private functions
    private func getArticles(for keyword: String, pageNo: Int) -> Promise<NewsApiResponse> {
        return self.newsSearchDataService.search(forWord: keyword, pageNo: pageNo)
    }
}
