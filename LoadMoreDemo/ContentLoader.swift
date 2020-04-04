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
  private let allItems: [Item] // it's guaranteed that these items are ordered by date 
  private let pageSize = 20
  private let queue: OperationQueue

  init() {
    allItems = Self.fakeContent()
    queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1 // let's be conservative
    queue.qualityOfService = .userInitiated // since this queue will be used to fetch data for the UI
  }

  // Cancels all the scheduled operations, you may want to call it when the UI gets closed or if the user stops scrolling
  func cancel() {
    queue.cancelAllOperations()
  }

  func fetchContent(page: Int = 1, completion: @escaping (Result<PaginatedResponse, FetchOperation.Error>) -> Void) {
    let operation = FetchOperation(page: page, pageSize: self.pageSize, fakeItems: self.allItems)
    operation.onResult = { result in
      completion(result)
    }
    queue.addOperation(operation)
  }
}

/// Operation that fetches a single page, on a real system it should be async probably
class FetchOperation: Operation {
  enum Error: Swift.Error {
    case cancel
    case error
  }

  var onResult: ((Result<PaginatedResponse,FetchOperation.Error>) -> Void)?

  private(set) var result: Result<PaginatedResponse,FetchOperation.Error>! {
    didSet {
      onResult?(result)
    }
  }
  let requestedPage: Int
  let pageSize: Int
  private let fakeItems: [Item]

  init(page: Int, pageSize: Int, fakeItems: [Item]) {
    self.requestedPage = page
    self.pageSize = pageSize
    self.fakeItems = fakeItems
  }

  override func main() {
    // Emulates a network call
    let sleepTime = [1, 2, 3].randomElement()!
    sleep(UInt32(sleepTime))
    guard !isCancelled else { return }
    let numberOfItems = self.fakeItems.count
    let totalPages = (Double(numberOfItems) / Double(self.pageSize)).rounded(.awayFromZero)
    let start = (requestedPage - 1) * self.pageSize // 0  20 40
    let end = (self.pageSize * requestedPage) - 1   // 19 39 59
    let realEnd = min(end, numberOfItems)
    let items = Array(self.fakeItems[start..<realEnd])
    let response = PaginatedResponse(items: items, totalItems: numberOfItems, currentPage: requestedPage, numberOfPages: Int(totalPages))

    guard !isCancelled else { return }

    if Bool.random() {
      result = .success(response)
    } else {
      result = .failure(.error)
    }
  }

  override func cancel() {
    print("operation was cancelled")
    result = .failure(.cancel)
    super.cancel()
  }
}
