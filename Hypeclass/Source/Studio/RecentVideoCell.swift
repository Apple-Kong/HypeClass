//
//  recentVideoCell.swift
//  Hypeclass
//
//  Created by Hong jeongmin on 2022/08/02.
//

import UIKit

class RecentVideoCell: UITableViewCell {
    
    //MARK: - Properties
    
    private let playImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "play.fill")
        image.tintColor = .white
        
        return image
    }()
    
    let videoThumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "유튜브 동영상 이름"
        label.textColor = .white
        
        return label
    }()

    static let recentVideoCellID = "RecentVideoCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        backgroundColor = .clear
    }
    
    required init?(coder:NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        contentView.addSubview(videoThumbnail)
        videoThumbnail.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoThumbnail.topAnchor.constraint(equalTo: contentView.topAnchor),
            videoThumbnail.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoThumbnail.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            videoThumbnail.heightAnchor.constraint(equalToConstant: 240)
        ])
        
        videoThumbnail.addSubview(playImage)
        playImage.translatesAutoresizingMaskIntoConstraints = false
        playImage.topAnchor.constraint(equalTo: videoThumbnail.topAnchor, constant: 15.96).isActive = true
        playImage.trailingAnchor.constraint(equalTo: videoThumbnail.trailingAnchor, constant: -19.23).isActive = true
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: videoThumbnail.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: videoThumbnail.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: videoThumbnail.trailingAnchor)
        ])
    }
}
