//
//  ContentLoader.swift
//  LoadMoreDemo
//
//  Created by Alessandro Marzoli on 02/04/2020.
//  Copyright © 2020 Alessandro Marzoli. All rights reserved.
//

import Foundation

struct Item: Codable {
  let id: UUID = UUID()
  let name: String
  let date: Date
}

struct PaginatedResponse {
  let items: [Item]
  let totalItems: Int
  let currentPage: Int
  let numberOfPages: Int
}

extension ContentLoader {
  static func fakeContent() -> [Item] {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    //let resource = "MOCK_DATA-1"
    let resource = "MOCK_DATA-2"
    if let path = Bundle.main.path(forResource: resource, ofType: "json") {
      if let jsonData = try? NSData(contentsOfFile: path, options: .dataReadingMapped) {
        let items = try! decoder.decode([Item].self, from: jsonData as Data)
        return items.sorted { $0.date < $1.date }
      }
    }
    return []
  }
}

final class ContentLoader {
  enum Error: Swift.Error {
    case cancel
    case error
  }

  private let allItems: [Item] // it's guaranteed that these items are ordered by date 
  private let pageSize = 20
  private let queue = OperationQueue()

  init() {
    allItems = Self.fakeContent()
  }

  func fetchContent(page: Int = 1, completion: @escaping (Result<PaginatedResponse, ContentLoader.Error>) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
      let numberOfItems = self.allItems.count
      let totalPages = (Double(numberOfItems) / Double(self.pageSize)).rounded(.awayFromZero)
      let start = (page - 1) * self.pageSize // 0  20 40
      let end = (self.pageSize * page) - 1   // 19 39 59
      let realEnd = min(end, numberOfItems)
      let items = Array(self.allItems[start..<realEnd])
      let response = PaginatedResponse(items: items, totalItems: numberOfItems, currentPage: page, numberOfPages: Int(totalPages))
      if Bool.random() || page == 1  {
        completion(.success(response))
      } else {
        completion(.failure(.error))
      }
    }
  }
}
