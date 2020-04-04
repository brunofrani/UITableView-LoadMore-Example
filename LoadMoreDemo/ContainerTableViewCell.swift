//
//  ContainerTableViewCell.swift
//  LoadMoreDemo
//
//  Created by Alessandro Marzoli on 03/04/2020.
//  Copyright © 2020 Alessandro Marzoli. All rights reserved.
//

import UIKit

public final class ContainerTableViewCell<V: UIView>: UITableViewCell {
  public lazy var view: V = {
    return V()
  }()

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  private func setup() {
    view.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(view)

    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      view.topAnchor.constraint(equalTo: contentView.topAnchor),
      view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
    ])
  }
}
