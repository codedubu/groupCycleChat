//
//  GroupTableViewCell.swift
//  groupCycle
//
//  Created by River McCaine on 3/18/21.
//

import UIKit
import SDWebImage

class GroupTableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "GroupTableViewCell"
    
    // MARK: - View Items
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    

    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 100,
                                     height: 100)
        usernameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height - 20) / 2)
        userMessageLabel.frame = CGRect(x: userImageView.right + 10,
                                        y: usernameLabel.bottom + 10,
                                     width: contentView.width - 20 - userImageView.width,
                                     height: (contentView.height - 20) / 2)
    }
  
    // MARK: - Helper Methods
    public func configure(with model: Group) {
        userMessageLabel.text = model.latestMessage.text
        usernameLabel.text = model.name
        
        let path = "images\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] (result) in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("Failed to get image URL: \(error)")
            }
        })
        
        
    }
 
} // END OF CLASS
