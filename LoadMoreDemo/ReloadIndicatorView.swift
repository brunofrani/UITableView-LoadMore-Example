//
//  LoadingTableViewCell.swift
//  LoadMoreDemo
//
//  Created by Alessandro Marzoli on 02/04/2020.
//  Copyright © 2020 Alessandro Marzoli. All rights reserved.
//

import UIKit

class ReloadIndicatorView: UIView {
  enum State {
    case loading
    case reload
  }

  var onReload: (() -> Void)?

  var state: State = .loading {
    didSet {
      activityIndicator.isHidden = state != .loading
      reloadStack.isHidden = state == .loading
    }
  }

  private lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView()
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.style = .medium
    indicator.hidesWhenStopped = true
    return indicator
  }()

  private lazy var reloadButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Tap to reload", for: .normal)
    button.titleLabel?.font = .preferredFont(forTextStyle: .title2)
    //let image = UIImage(systemName: "arrow.counterclockwise.icloud.fill")
    //button.setImage(image, for: .normal)
    button.addTarget(self, action:  #selector(ReloadIndicatorView.reloadTapped), for: .touchUpInside)
    return button
  }()

  private lazy var reloadStack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [reloadButton, errorLabel])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.distribution = .fill
    stack.alignment = .center
    return stack
  }()

  private lazy var errorLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = .preferredFont(forTextStyle: .caption1)
    label.text = "An error occurred 😢"
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  @objc
  private func reloadTapped() {
    self.state = .loading
    self.onReload?()
  }

  private func setup() {
    state = .loading // trigger the didSet
    self.addSubview(activityIndicator)
    self.addSubview(reloadStack)

    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      reloadStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      reloadStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
    ])

    activityIndicator.startAnimating()
  }
}

extension ContainerTableViewCell where V: ReloadIndicatorView {
  static var cellID: String { return "ContainerTableViewCell<ReloadIndicatorView>" }
}

