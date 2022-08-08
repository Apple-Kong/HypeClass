//
//  IntroduceViewController.swift
//  Hypeclass
//
//  Created by Hong jeongmin on 2022/07/30.
//

import UIKit
import Kingfisher

class IntroduceViewController: BaseViewController {
    
    //MARK: - Properties
    
    // 데이터 연결 되면 PR 올라오면 데이터 받아서 처리 ( 샘플 코드 )
    var model: Studio?
    private var instrutors: [Dancer]?
    private var youtubeItems: [Item]?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "스튜디오 소개"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        return label
    }()
    
    private let introduceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.sizeToFit()
        label.numberOfLines = 0
        
        return label
    }()
    
    private let InstructorsLabel: UILabel = {
        let label = UILabel()
        label.text = "Instructors"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        return label
    }()
    
    private let instructorsCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 9.06
        layout.minimumInteritemSpacing = 9.06
        layout.itemSize = CGSize(width: 80, height: 100)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        
        return collection
    }()
    
    private let recentVideoLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 영상"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        return label
    }()
    
    private let recentVideoTable: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 300
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        
        return tableView
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureInstructorsCollection()
        configurerecentVideoTable()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        instructorsCollection.reloadData()
        recentVideoTable.reloadData()
        requestYoutube()
    }
    
    //MARK: - Selectors
    
    //MARK: - Helpers
    func configure() {
        introduceLabel.text = model?.description
        guard let studioName = model?.name else {
            return
        }
        Task {
            let dancers = try await DancerManager.shared.requestDancersBy(studioName: studioName)
            self.instrutors = dancers
            if instrutors?.isEmpty ?? true {
                InstructorsLabel.isHidden = true
                instructorsCollection.isHidden = true
                InstructorsLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
                instructorsCollection.heightAnchor.constraint(equalToConstant: 0).isActive = true
            } else {
                instructorsCollection.reloadData()
            }
            recentVideoTable.reloadData()
        }
    }
    
    func requestYoutube() {
        YoutubeManager.shared.fetchYoutubeData(channelID: "UC_9VndUJ6Z6yfEK4_EJI46Q") { result in
            switch result {
            case .success(let thumbnailDatas):
                self.youtubeItems = thumbnailDatas
                DispatchQueue.main.async {
                    self.recentVideoTable.reloadData()
                }
            case .failure(let error):
                print("ERROR: \(error)")
            }
        }
    }
    
    func configureUI() {
        self.view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 31).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        
        self.view.addSubview(introduceLabel)
        introduceLabel.translatesAutoresizingMaskIntoConstraints = false
        introduceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
        introduceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        introduceLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        
        self.view.addSubview(InstructorsLabel)
        InstructorsLabel.translatesAutoresizingMaskIntoConstraints = false
        InstructorsLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        InstructorsLabel.topAnchor.constraint(equalTo: introduceLabel.bottomAnchor, constant: 27).isActive = true
        
        self.view.addSubview(instructorsCollection)
        instructorsCollection.translatesAutoresizingMaskIntoConstraints = false
        instructorsCollection.topAnchor.constraint(equalTo: InstructorsLabel.bottomAnchor, constant: 10).isActive = true
        instructorsCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        instructorsCollection.heightAnchor.constraint(equalToConstant: 120).isActive = true
        instructorsCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        instructorsCollection.contentInset = UIEdgeInsets(top: 0, left: 31, bottom: 0, right: 0)
        
        self.view.addSubview(recentVideoLabel)
        recentVideoLabel.translatesAutoresizingMaskIntoConstraints = false
        recentVideoLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        recentVideoLabel.topAnchor.constraint(equalTo: instructorsCollection.bottomAnchor, constant: 27).isActive = true
        
        self.view.addSubview(recentVideoTable)
        recentVideoTable.translatesAutoresizingMaskIntoConstraints = false
        recentVideoTable.topAnchor.constraint(equalTo: recentVideoLabel.bottomAnchor, constant: 14).isActive = true
        recentVideoTable.leadingAnchor.constraint(equalTo: introduceLabel.leadingAnchor).isActive = true
        recentVideoTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        recentVideoTable.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func configureInstructorsCollection() {
        instructorsCollection.register(IntroduceDancerCell.self, forCellWithReuseIdentifier: IntroduceDancerCell.id)
        instructorsCollection.dataSource = self
        instructorsCollection.delegate = self
    }
    
    func configurerecentVideoTable() {
        recentVideoTable.register(RecentVideoCell.self, forCellReuseIdentifier: RecentVideoCell.recentVideoCellID)
        recentVideoTable.dataSource = self
        recentVideoTable.delegate = self
    }
}

// MARK: - UICollectionView Extension

extension IntroduceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dancer = instrutors?[indexPath.row] else { return }
        let dancerVC = DancerDetailViewController()
        dancerVC.model = dancer
        self.navigationController?.pushViewController(dancerVC, animated: true)
    }
}

extension IntroduceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("DEBUG: instructors : \(instrutors?.count)")
        return instrutors?.count ?? 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IntroduceDancerCell.id, for: indexPath) as! IntroduceDancerCell
        guard let dancer = instrutors?[indexPath.row] else { return cell }
        let url = URL(string: dancer.profileImageURL ?? "")
        cell.imageView.kf.setImage(with: url)
        cell.titleLabel.text = dancer.name
        return cell
    }
}

//MARK: - UITableView Extension

extension IntroduceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let youtubeItem = youtubeItems?[indexPath.row] else { return }
        let videoID = youtubeItem.id.videoID
        if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

extension IntroduceViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return youtubeItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recentVideoTable.dequeueReusableCell(withIdentifier: RecentVideoCell.recentVideoCellID, for:indexPath) as! RecentVideoCell
        guard let youtubeItem = youtubeItems?[indexPath.row] else { return cell }
        let url = URL(string: youtubeItem.snippet.thumbnails.high.url)
        cell.videoThumbnail.kf.setImage(with: url)
        cell.titleLabel.text = youtubeItem.snippet.title
        cell.selectionStyle = .none
        return cell
    }
}

//MARK: - Preview
import SwiftUI

struct IntroduceViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = IntroduceViewController
    
    func makeUIViewController(context: Context) -> IntroduceViewController {
        return IntroduceViewController()
    }
    
    func updateUIViewController(_ uiViewController: IntroduceViewController, context: Context) {}
}

@available(iOS 13.0.0, *)
struct IntroduceViewControllerPreview: PreviewProvider {
    static var previews: some View {
        IntroduceViewControllerRepresentable()
    }
}
