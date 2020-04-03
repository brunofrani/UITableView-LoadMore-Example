//
//  LoadingTableViewCell.swift
//  LoadMoreDemo
//
//  Created by Alessandro Marzoli on 02/04/2020.
//  Copyright © 2020 Alessandro Marzoli. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
  static let cellID = "LoadingTableViewCell"

  var onReload: (() -> Void)?

  enum State {
    case loading
    case reload
  }

  var state: State = .loading {
    didSet {
        activityIndicator.isHidden = state != .loading
        button.isHidden = state == .loading
    }
  }

  lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.style = .medium
    indicator.hidesWhenStopped = true
    return indicator
  }()

  lazy var button: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Tap to reload", for: .normal)
    button.titleLabel?.font = .preferredFont(forTextStyle: .title2)
    //let image = UIImage(systemName: "arrow.counterclockwise.icloud.fill")
    //button.setImage(image, for: .normal)
    button.addTarget(self, action:  #selector(LoadingTableViewCell.reloadTapped), for: .touchUpInside)
    return button

  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupSubviews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  @objc
  private func reloadTapped() {
    self.state = .loading
    self.onReload?()
  }

  private func setupSubviews() {
    selectionStyle = .none
    state = .loading // trigger the didSet
    contentView.addSubview(activityIndicator)
    contentView.addSubview(button)

    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
    ])

    activityIndicator.startAnimating()
  }
}
