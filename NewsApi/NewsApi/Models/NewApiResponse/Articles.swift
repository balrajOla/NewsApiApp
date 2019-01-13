//
//  Articles.swift
//
//  Created by Balraj Singh on 12/01/19
//  Copyright (c) . All rights reserved.
//

import Foundation

public struct Article: Codable {

  // MARK: Properties
  public var content: String?
  public var source: Source?
  public var publishedAt: String?
  public var description: String?
  public var title: String?
  public var urlToImage: String?
  public var author: String?
  public var url: String?

}
