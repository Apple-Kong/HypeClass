//
//  DancerDetailView.swift
//  Hypeclass
//
//  Created by 이성노 on 2022/07/17.
//

import UIKit

class DancerDetailViewController: BaseViewController {
    
    //MARK: - Properties
    
    var model: Dancer?
    var recentVideos: [Item]?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInset = UIEdgeInsets(top: -(UIApplication.shared.currentUIWindow()?.safeAreaInsets.top ?? 0), left: 0, bottom: 0, right: 0)
  
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let navigationBar: UIView = {
        let view = UIView()
        
        return view
    }()
    
    private let backButtonView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.backward.circle.fill")
        view.tintColor = .white
        
        return view
    }()
    
    private let heartView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "heart")
        view.tintColor = .white
        
        return view
    }()
    
    private var remoteHeartState = false
    
    private var isHeart = false
        
    private var dancerHeaderView: HeaderView?

    private lazy var scheduleContentLabel: UILabel = {
        let label = UILabel()
        label.text = "스케줄"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var scheduleView: ScheduleItemView?

    private lazy var videoContentLabel: UILabel = {
        let label = UILabel()
        label.text = "영상"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let recentVideoTable: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 300
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        
        return tableView
    }()
    
    private lazy var introduceContentLabel: UILabel = {
        let label = UILabel()
        label.text = "소개"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var introduceContent: UILabel = {
        let label = UILabel()
        label.text = model?.description
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var selectedDate = Date()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configurerecentVideoTable()
        requestYoutube()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.contentSize = CGSize(width: Device.width, height: contentView.frame.height)
        remoteHeartState = isAlreadySubscribed()
        isHeart = remoteHeartState
    }
    
    //MARK: - Selectors
    
    @objc func backButtonDidTap() {
        self.navigationController?.popViewController(animated: true)
        if remoteHeartState != isHeart {
            if isHeart {
                addToSubscription()
                DancerManager.shared.incrementLikes(dancerName: model?.name ?? "")
            } else {
                removeFromSubscription()
                DancerManager.shared.decrementLikes(dancerName: model?.name ?? "")
            }
        }
    }
    
    @objc func heartDidTap() {
        isHeart.toggle()
        if isHeart {
            heartView.image = UIImage(systemName: "heart.fill")
            presentBottomAlert(message: "댄서를 구독하였습니다.")
        } else {
            heartView.image = UIImage(systemName: "heart")
            presentBottomAlert(message: "댄서 구독이 취소되었습니다.")
        }
    }
    
    //MARK: - Helpers
    
    func requestYoutube() {
        YoutubeManager.shared.fetchYoutubeData(channelID: "UC_9VndUJ6Z6yfEK4_EJI46Q") { result in
            switch result {
            case .success(let thumbnailDatas):
                self.recentVideos = thumbnailDatas
                DispatchQueue.main.async {
                    self.recentVideoTable.reloadData()
                }
            case .failure(let error):
                print("ERROR: \(error)")
            }
        }
    }
    
    func configurerecentVideoTable() {
        recentVideoTable.register(RecentVideoCell.self, forCellReuseIdentifier: RecentVideoCell.recentVideoCellID)
        recentVideoTable.dataSource = self
        recentVideoTable.delegate = self
    }

    private func configureUI() {
        // scrollView
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // contentView
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor).isActive = true
       
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        contentViewHeight.isActive = true
        
        // navigationBar
        view.addSubview(navigationBar)
        navigationBar.frame = CGRect(x: 0, y: 0, width: Device.width, height: 92)

        // backButtonView
        view.addSubview(backButtonView)
        backButtonView.translatesAutoresizingMaskIntoConstraints = false
        backButtonView.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 50).isActive = true
        backButtonView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 25).isActive = true
        backButtonView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButtonView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        backButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonDidTap)))
        backButtonView.isUserInteractionEnabled = true
        
        // heartView
        view.addSubview(heartView)
        if isAlreadySubscribed() { heartView.image = UIImage(systemName: "heart.fill") }
        heartView.translatesAutoresizingMaskIntoConstraints = false
        heartView.centerYAnchor.constraint(equalTo: backButtonView.centerYAnchor).isActive = true
        heartView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -25).isActive = true
        heartView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        heartView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        heartView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(heartDidTap)))
        heartView.isUserInteractionEnabled = true
        
        // dancerHeaderView
        dancerHeaderView = HeaderView(frame: .zero, coverImageURL: model?.coverImageURL, profileImageURL: model?.profileImageURL, title: "\(model?.name ?? "")", subtitle: model?.genres?[0], instagramURL: model?.instagramURL)
        contentView.addSubview(dancerHeaderView!)
        dancerHeaderView!.translatesAutoresizingMaskIntoConstraints = false
        dancerHeaderView!.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        dancerHeaderView!.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        dancerHeaderView!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        // introduceContentLabel
        contentView.addSubview(introduceContentLabel)
        introduceContentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            introduceContentLabel.topAnchor.constraint(equalTo: dancerHeaderView!.bottomAnchor),
            introduceContentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25)
        ])
        
        // introduceContent
        contentView.addSubview(introduceContent)
        introduceContent.translatesAutoresizingMaskIntoConstraints = false
        introduceContent.topAnchor.constraint(equalTo: introduceContentLabel.bottomAnchor, constant: 15).isActive = true
        introduceContent.leadingAnchor.constraint(equalTo: introduceContentLabel.leadingAnchor).isActive = true
        
        // scheduleContentLabel
        contentView.addSubview(scheduleContentLabel)
        scheduleContentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scheduleContentLabel.topAnchor.constraint(equalTo: introduceContent.bottomAnchor, constant: 30),
            scheduleContentLabel.leadingAnchor.constraint(equalTo: introduceContent.leadingAnchor)
        ])
        
        if model?.id != nil {
            // scheduleView
            scheduleView = ScheduleItemView(frame: .zero, dancerID: model!.id, date: selectedDate)
            scheduleView?.delegate = self
            contentView.addSubview(scheduleView!)
            scheduleView?.translatesAutoresizingMaskIntoConstraints = false
            scheduleView?.topAnchor.constraint(equalTo: scheduleContentLabel.bottomAnchor).isActive = true
            scheduleView?.leadingAnchor.constraint(equalTo: scheduleContentLabel.leadingAnchor).isActive = true
            scheduleView?.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25).isActive = true
        }
        
        // videoContentLabel
        contentView.addSubview(videoContentLabel)
        videoContentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoContentLabel.topAnchor.constraint(equalTo: scheduleView?.bottomAnchor ?? scheduleContentLabel.bottomAnchor, constant: 20),
            videoContentLabel.leadingAnchor.constraint(equalTo: scheduleContentLabel.leadingAnchor)
        ])
        
        contentView.addSubview(recentVideoTable)
        recentVideoTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recentVideoTable.topAnchor.constraint(equalTo: videoContentLabel.bottomAnchor, constant: 20),
            recentVideoTable.leadingAnchor.constraint(equalTo: videoContentLabel.leadingAnchor),
            recentVideoTable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25),
            recentVideoTable.heightAnchor.constraint(equalToConstant: 1500),
            contentView.bottomAnchor.constraint(equalTo: recentVideoTable.bottomAnchor)
        ])
    }
    
    private func isAlreadySubscribed() -> Bool {
        if let subscriptions = UserDefaults.standard.stringArray(forKey: "SubscribedDancers") {
            if subscriptions.contains(model!.id) {
                return true
            }
            return false
        } else {
            return false
        }
    }
    
    private func addToSubscription() {
        if isAlreadySubscribed() { return }
        
        if var subscriptions = UserDefaults.standard.stringArray(forKey: "SubscribedDancers") {
            if(subscriptions.count >= 10) {
                presentBottomAlert(message: "구독 가능한 댄서는 최대 10명입니다.")
                return
            }
            subscriptions.append(model!.id)
            DancerManager.myDancers?.append(model!)
            UserDefaults.standard.set(subscriptions, forKey: "SubscribedDancers")
        } else {
            var newList = [String]()
            newList.append(model!.id)
            UserDefaults.standard.set(newList, forKey: "SubscribedDancers")
        }
    }
    
    private func removeFromSubscription() {
        if !isAlreadySubscribed() { return }
        
        let subscriptions = UserDefaults.standard.stringArray(forKey: "SubscribedDancers")!.filter { $0 != model!.id }
        UserDefaults.standard.set(subscriptions, forKey: "SubscribedDancers")
        DancerManager.myDancers = DancerManager.myDancers?.filter{ $0.id != model!.id }
    }
}

//MARK: - UITableViewDataSource

extension DancerDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentVideos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = recentVideoTable.dequeueReusableCell(withIdentifier: RecentVideoCell.recentVideoCellID, for:indexPath) as! RecentVideoCell
        guard let youtubeItem = recentVideos?[indexPath.row] else { return cell }
        let url = URL(string: youtubeItem.snippet.thumbnails.high.url)
        cell.videoThumbnail.kf.setImage(with: url)
        cell.titleLabel.text = youtubeItem.snippet.title
        cell.selectionStyle = .none
        return cell
    }
}

//MARK: - UITableViewDelegate

extension DancerDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let youtubeItem = recentVideos?[indexPath.row] else { return }
        let videoID = youtubeItem.id.videoID
        if let url = URL(string: "https://www.youtube.com/watch?v=\(videoID)") {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

// MARK: - UIScrollViewDelegate Extension

extension DancerDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y - (UIApplication.shared.currentUIWindow()?.safeAreaInsets.top ?? 0)

        //MARK: 네비게이션 바 Fade 애니메이션
        var proportionalOffset =  offset / 70
        
        if proportionalOffset > 1 {
            proportionalOffset = 1
            let color = UIColor.background.withAlphaComponent(1)
            DispatchQueue.main.async {
                UIApplication.statusBarView?.backgroundColor = color
                self.navigationBar.backgroundColor = color
            }
        } else {
            let color = UIColor.background.withAlphaComponent(proportionalOffset)
            let temp = proportionalOffset + 0.55
            let tempColor = UIColor.background.withAlphaComponent(temp)
            DispatchQueue.main.async {
                UIApplication.statusBarView?.backgroundColor = color
                self.navigationBar.backgroundColor = tempColor
            }
        }
    }
}

// MARK: - ScheduleItemDelegate extension

extension DancerDetailViewController: ScheduleItemDelegate {
    func scheduleDidSelect(schedule: DanceClass) {
        let vc = DanceClassDetailViewController()
        vc.model = schedule
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Preview

import SwiftUI

struct DancerDetailViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = DancerDetailViewController

    func makeUIViewController(context: Context) -> DancerDetailViewController {
        return DancerDetailViewController()
    }

    func updateUIViewController(_ uiViewController: DancerDetailViewController, context: Context) {}
}

@available(iOS 13.0.0, *)
struct DancerDetailViewControllerPreview: PreviewProvider {
    static var previews: some View {
        DancerDetailViewControllerRepresentable()
    }
}
