//
//  ViewController.swift
//  LoadMoreDemo
//
//  Created by Alessandro Marzoli on 02/04/2020.
//  Copyright © 2020 Alessandro Marzoli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  private let contentLoader = ContentLoader()
  private var content = [TableSection]()
  private var shouldShowLoadingCell: Bool = false
  private var currentPage = 1
  private var errorFetchingCurrentPage: Bool = false

  private(set) lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.delegate = self
    tableView.dataSource = self
    return tableView
  }()
  
  private lazy var loadingCell: LoadingTableViewCell = {
    let cell = LoadingTableViewCell(style: .default, reuseIdentifier: LoadingTableViewCell.cellID)
    cell.onReload = { [weak self] in
      self?.loadContent()
    }
    return cell
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Load More"
    self.view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
      tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
      tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
      tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
      ]
    )

    tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: ItemTableViewCell.cellID)
    tableView.register(LoadingTableViewCell.self, forCellReuseIdentifier: LoadingTableViewCell.cellID)
    tableView.refreshControl = UIRefreshControl()
    tableView.refreshControl?.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
    
    tableView.refreshControl?.beginRefreshing()
    loadContent()
  }
}

extension ViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return content.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let itemsSection = self.itemsSection(at: section) {
      let count = itemsSection.items.count
      if self.content.count - 1 == section {
        return shouldShowLoadingCell ? count + 1 : count
      } else {
        return count
      }
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if isLoadingIndexPath(indexPath) {
      return loadingCell
    } else {
      let section = self.itemsSection(at: indexPath)!
      let item = section.items[indexPath.row]
      let cell = self.tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.cellID, for: indexPath) as! ItemTableViewCell
      cell.itemNameLabel.text = item.name
      return cell
    }
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return self.itemsSection(at: section)?.name ?? "❌ error"
  }
}

extension ViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard isLoadingIndexPath(indexPath) else { return }
    if !self.errorFetchingCurrentPage {
      fetchNextPage()
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if isLoadingIndexPath(indexPath) {
      return 150
    }
    return 60
  }
}

extension ViewController {
  func itemsSection(at indexPath: IndexPath) -> TableSection? {
    guard let section = itemsSection(at: indexPath.section) else { return nil }
    return section
  }
  
  func itemsSection(at index: Int) -> TableSection? {
    guard index < content.count else { return nil }
    return content[index]
  }

  private func isLoadingIndexPath(_ indexPath: IndexPath) -> Bool {
    guard shouldShowLoadingCell else { return false }
    let section = self.content[indexPath.section]
    return self.content.count - 1 == indexPath.section && indexPath.row == section.items.count
  }
}

extension ViewController {
  @objc
  private func refreshContent() {
    currentPage = 1
    loadContent(refresh: true)
  }



  private func loadContent(refresh: Bool = false) {
    print("Fetching page \(currentPage)")
    contentLoader.fetchContent(page: currentPage) { [weak self] result in
      guard let self = self else { return }

      DispatchQueue.main.async {
        switch result {
        case .success(let response):
          self.errorFetchingCurrentPage = false
          self.updateDatasource(response: response, refresh: refresh)
        case .failure:
          self.errorFetchingCurrentPage = true
          self.loadingCell.state = .reload
        }
      }
    }
  }

  func updateDatasource(response: PaginatedResponse, refresh: Bool) {
    if refresh {
      let itemsByGroup = Dictionary(grouping: response.items) { GroupingByDay.makeNew(for: $0) }
      var sections = [TableSection]()
      for (group, items) in itemsByGroup {
        let newSection = TableSection(grouping: group, items: items)
        sections.append(newSection)
      }
      self.content = sections.sorted { $0.grouping < $1.grouping }
    } else {
      if self.content.count > 0 {
        var copy = self.content // TODO: is a copy needed here?
        for item in response.items {
          let group = GroupingByDay.makeNew(for: item)
          if let sectionIndex = copy.firstIndex(where: { $0.grouping == group }) {
            var section = copy[sectionIndex]
            section.items.append(item)
            section.items.sort { $0.date < $1.date }
            copy[sectionIndex] = section
          } else {
            var newSection = TableSection(grouping: group)
            newSection.items = [item]
            copy.append(newSection)
          }
        }
        self.content = copy.sorted { $0.grouping < $1.grouping }
      } else {
        let itemsByGroup = Dictionary(grouping: response.items) { GroupingByDay.makeNew(for: $0) }
        var sections = [TableSection]()
        for (group, items) in itemsByGroup {
          let newSection = TableSection(grouping: group, items: items)
          sections.append(newSection)
        }
        self.content = sections.sorted { $0.grouping < $1.grouping }
      }
    }
    self.shouldShowLoadingCell = response.currentPage < response.numberOfPages
    self.tableView.refreshControl?.endRefreshing()
    self.tableView.reloadData()
  }

  func fetchNextPage() {
    currentPage += 1
    loadContent()
  }
}

struct TableSection {
  let grouping: GroupingByDay
  var items = [Item]()
  var name: String { return "\(grouping.year)-\(grouping.month)-\(grouping.day)" }
}

struct GroupingByDay: Equatable, Hashable, Comparable {
  let year: Int
  let month: Int
  let day: Int
  let calendar: Calendar

  var dateComponents: DateComponents {
    var dateComponents = DateComponents()
    dateComponents.calendar = calendar
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    return dateComponents
  }

  static func < (lhs: GroupingByDay, rhs: GroupingByDay) -> Bool {
    return lhs.dateComponents.date! < rhs.dateComponents.date!
  }
}

extension GroupingByDay {
  static func makeNew(for item: Item, using calendar: Calendar = .current) -> Self {
    let year = calendar.component(.year, from: item.date)
    let month = calendar.component(.month, from: item.date)
    let day = calendar.component(.day, from: item.date)
    return GroupingByDay(year: year, month: month, day: day, calendar: calendar)
  }
}

