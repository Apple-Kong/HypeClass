//
//  HistoryCell.swift
//  Hypeclass
//
//  Created by Hong jeongmin on 2022/07/17.
//

import UIKit

class HistoryCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    let chip: UIView = {
        let chip = UIView()
        chip.layer.borderColor = UIColor.gray.cgColor
        chip.layer.borderWidth = 1
        chip.layer.cornerRadius = 12.5
        chip.layer.masksToBounds = true
        
        return chip
    }()
    
    let searchHistory: UILabel = {
        let searchHistory = UILabel()
        searchHistory.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        searchHistory.textColor = .gray
        
        return searchHistory
    }()
    
    let cancelBtn: UIButton = {
        let cancelBtn = UIButton()
        cancelBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        cancelBtn.tintColor = .gray
        
        return cancelBtn
    }()
    
    //MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func configureLayout() {
        contentView.addSubview(chip)
        chip.translatesAutoresizingMaskIntoConstraints = false
        chip.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        chip.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        chip.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        chip.addSubview(searchHistory)
        searchHistory.translatesAutoresizingMaskIntoConstraints = false
        searchHistory.leadingAnchor.constraint(equalTo: chip.leadingAnchor, constant: 9).isActive = true
        searchHistory.centerXAnchor.constraint(equalTo: chip.centerXAnchor, constant: -12).isActive = true
        searchHistory.centerYAnchor.constraint(equalTo: chip.centerYAnchor).isActive = true
        
        chip.addSubview(cancelBtn)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.leadingAnchor.constraint(equalTo: searchHistory.trailingAnchor, constant: 12).isActive = true
        cancelBtn.centerYAnchor.constraint(equalTo: chip.centerYAnchor).isActive = true
        cancelBtn.trailingAnchor.constraint(equalTo: chip.trailingAnchor, constant: -9).isActive = true
    }
}
