//
//  NewApiResponse.swift
//
//  Created by Balraj Singh on 12/01/19
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct NewsApiResponse: Codable {

  // MARK: Properties
  public var status: String?
  public var totalResults: Int?
  public var articles: [Article]?

}

extension NewsApiResponse : Pagination, Aggregatable {
    public func aggregate(result: Aggregatable) -> Aggregatable {
        guard let newResult = result as? NewsApiResponse else {
            return self
        }
        
        return NewsApiResponse(status: newResult.status, totalResults: newResult.totalResults, articles:  (self.articles ?? []) + (newResult.articles ?? []))
    }
    
    public func isNextPageAvailable() -> Bool {
        return status.map { value -> Bool in return (value.lowercased() == "ok") } ?? false
    }
    
    public func updatePaginationStatus(next: Bool) -> Void { }
}
