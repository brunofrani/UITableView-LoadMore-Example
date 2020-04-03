//
//  ItemTableViewCell.swift
//  LoadMoreDemo
//
//  Created by Alessandro Marzoli on 02/04/2020.
//  Copyright © 2020 Alessandro Marzoli. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
  static let cellID = "ItemTableViewCell"
  
  var itemNameLabel: UILabel!
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    initializeSubviews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func initializeSubviews() {
    itemNameLabel = UILabel()
    itemNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
    itemNameLabel.textColor = UIColor(white: 0.3, alpha: 1.0)
    itemNameLabel.numberOfLines = 1
    contentView.addSubview(itemNameLabel)
    
    let horizontalStack = UIStackView(arrangedSubviews: [itemNameLabel])
    horizontalStack.translatesAutoresizingMaskIntoConstraints = false
    horizontalStack.axis = .vertical
    horizontalStack.distribution = .fill
    horizontalStack.alignment = .center
    
    contentView.addSubview(horizontalStack)
    
    NSLayoutConstraint.activate([
      horizontalStack.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 8),
      horizontalStack.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -8),
      horizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      horizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
    ])
    
    
  }
}
