//
//  ViewController.swift
//  Hypeclass
//
//  Created by GOngTAE on 2022/07/11.
//

import UIKit
import Kingfisher
import FirebaseAuth

class MainViewController: BaseViewController {
    
    // MARK: - Properties
    
    private var mainEventModels: [Event]?
    private var studioModels: [Studio]?
    
    private let logoImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .green
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: "logo")
        
        return image
    }()
    
    private let headerTitle: UILabel = {
        let label = UILabel()
        label.text = "춤추러 가는 길, \n어려울 필요 없으니까."
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        
        return label
    }()
    
    private let highLightView: UIView = {
        let view = UIView()
        view.backgroundColor = .accent.withAlphaComponent(0.8)
        
        return view
    }()
    
    private let searchButton: UIButton = {
        var config = UIButton.Configuration.gray()
        config.baseForegroundColor = UIColor(hex: 0x7A7A7A)
        config.baseBackgroundColor = UIColor(hex: 0x2D2C38)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular, scale: .large)
        config.image = UIImage(systemName: "magnifyingglass", withConfiguration: imageConfig)
        config.imagePadding = 13
        config.imagePlacement = .leading
        
        var titleAttr = AttributedString.init("댄서, 스튜디오 무엇이든지")
        titleAttr.font = .systemFont(ofSize: 12, weight: .regular)
        config.attributedTitle = titleAttr
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 0)
        
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(searchButtonDidTap), for: .touchUpInside)
        button.contentHorizontalAlignment = .leading
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        
        return button
    }()
    
    private let imageScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.layer.cornerRadius = 10
        scrollView.clipsToBounds = true
        scrollView.showsHorizontalScrollIndicator = false
        
        return scrollView
    }()
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPage = 0
        
        return control
    }()
    
    private let scrollImageTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        
        return label
    }()
    
    private let scrollImageSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "지금 바로 춤추러 가기 >"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pageDidTap)))
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    private let studioCellID = "studio"
    
    private let studioLabel: UILabel = {
        let label = UILabel()
        label.text = "함께하는 스튜디오들"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        
        return label
    }()
    
    private let studioCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .background
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 22)
        
        return cv
    }()

    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configure()
    }
    
    // MARK: - Selectors
    
    @objc func searchButtonDidTap() {
        let searchVC = SearchViewController()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc func pageDidTap() {
        guard let event = mainEventModels?[pageControl.currentPage] else { return } // 이벤트에 따라 다른 페이지로 이동
        switch event.type {
        case .studio:
            // 네트워킹 연결 필요.
            Task {
                let studio = try? await StudioManager.shared.requestStudiosBy(studioIDs: [event.relatedID])
                let studioVC = StudioViewController()
                studioVC.studio = studio?.first
                self.navigationController?.pushViewController(studioVC, animated: true)
            }
        case .dancer:
            Task {
                let dancer = try? await DancerManager.shared.requestDancersBy(dancerIDs: [event.relatedID])
                let dancerVC = DancerDetailViewController()
                dancerVC.model = dancer?.first
                self.navigationController?.pushViewController(dancerVC, animated: true)
            }
        case .danceClass:
            print("DEBUG: 댄스 클래스 뷰 컨트롤러 이동")
        default:
            print("ERROR: 유효하지 않은 타입의 이벤트입니다.")
        }
    }
    
    // MARK: - Helpers
    
    private func configure() {
        Task {
            do {
                IndicatorView.shared.show()
                IndicatorView.shared.showIndicator()
                async let events = await EventManager.shared.requestAllEvents()
                async let studios = await StudioManager.shared.requestAllStudios()
                let result: [Any?] = try await [events, studios]
                self.mainEventModels = result[0] as? [Event]
                self.studioModels = result[1] as? [Studio]
                studioCollectionView.reloadData()
                pageControl.numberOfPages = mainEventModels?.count ?? 0
                addContentToScrollView()
                IndicatorView.shared.dismiss()
            } catch {
                presentBottomAlert(message: "데이터를 불러오지 못했어요🥲")
            }
        }
    }
    
    // 스크롤뷰에 컨텐츠를 추가합니다.
    private func addContentToScrollView() {
        scrollImageTitleLabel.text = mainEventModels?[pageControl.currentPage].title
        
        for idx in 0..<(mainEventModels?.count ?? 0) {
            guard let event = mainEventModels?[idx] else { continue }
            let imageView = UIImageView()
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pageDidTap)))
            imageView.isUserInteractionEnabled = true
            imageView.contentMode = .scaleAspectFill
            let url = URL(string: event.coverImageURL ?? "")
            imageView.kf.setImage(with: url)
            let xPos = (Device.width - 44) * CGFloat(idx)
            imageView.frame = CGRect(x: xPos, y: imageScrollView.bounds.minY, width: imageScrollView.bounds.width + 25, height: imageScrollView.bounds.height)
            imageScrollView.addSubview(imageView)
            imageScrollView.contentSize.width = imageView.frame.width * CGFloat(idx + 1)
        }
    }
    
    private func configureUI() {
        // logoImageView
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        // headerTitle
        view.addSubview(headerTitle)
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        headerTitle.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor).isActive = true
        headerTitle.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 0).isActive = true
        
        headerTitle.addSubview(highLightView)
        highLightView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            highLightView.leadingAnchor.constraint(equalTo: headerTitle.leadingAnchor),
            highLightView.trailingAnchor.constraint(equalTo: headerTitle.trailingAnchor),
            highLightView.bottomAnchor.constraint(equalTo: headerTitle.bottomAnchor),
            highLightView.heightAnchor.constraint(equalToConstant: 5)
        ])
        
        // searchButton
        view.addSubview(searchButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 30).isActive = true
        searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22).isActive = true
        searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -22).isActive = true
        
        // imageScrollView
        view.addSubview(imageScrollView)
        imageScrollView.delegate = self
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 28).isActive = true
        imageScrollView.leadingAnchor.constraint(equalTo: searchButton.leadingAnchor).isActive = true
        imageScrollView.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor).isActive = true
        imageScrollView.heightAnchor.constraint(equalToConstant: (Device.width - 40) * 0.6).isActive = true
        
        // pageControl
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor, constant: 10).isActive = true
        pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 6).isActive = true
        
        // scrollImageTitleLabel
        view.addSubview(scrollImageTitleLabel)
        scrollImageTitleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pageDidTap)))
        scrollImageTitleLabel.isUserInteractionEnabled = true
        scrollImageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollImageTitleLabel.topAnchor.constraint(equalTo: pageControl.bottomAnchor).isActive = true
        scrollImageTitleLabel.leadingAnchor.constraint(equalTo: searchButton.leadingAnchor).isActive = true
        scrollImageTitleLabel.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor).isActive = true
        
        // scrollImageSubtitleLabel
        view.addSubview(scrollImageSubtitleLabel)
        scrollImageSubtitleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pageDidTap)))
        scrollImageSubtitleLabel.isUserInteractionEnabled = true
        scrollImageSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollImageSubtitleLabel.topAnchor.constraint(equalTo: scrollImageTitleLabel.bottomAnchor, constant: 5).isActive = true
        scrollImageSubtitleLabel.leadingAnchor.constraint(equalTo: searchButton.leadingAnchor).isActive = true
        scrollImageSubtitleLabel.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor).isActive = true
        
        // studioLabel
        view.addSubview(studioLabel)
        studioLabel.translatesAutoresizingMaskIntoConstraints = false
        studioLabel.topAnchor.constraint(equalTo: scrollImageSubtitleLabel.bottomAnchor, constant: 40).isActive = true
        studioLabel.leadingAnchor.constraint(equalTo: searchButton.leadingAnchor).isActive = true
        
        // studioCollectionView
        studioCollectionView.register(MainStudioCell.self, forCellWithReuseIdentifier: studioCellID)
        studioCollectionView.dataSource = self
        studioCollectionView.delegate = self
        
        view.addSubview(studioCollectionView)
        studioCollectionView.translatesAutoresizingMaskIntoConstraints = false
        studioCollectionView.topAnchor.constraint(equalTo: studioLabel.bottomAnchor, constant: 8).isActive = true
        studioCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        studioCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        studioCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}

// MARK: - UICollectionViewDataSource, Delegate

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return studioModels?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: studioCellID, for: indexPath) as? MainStudioCell else { return UICollectionViewCell() }
        // TODO: url Image
        guard let studio = studioModels?[indexPath.row] else { return cell }
        let url = URL(string: studio.profileImageURL ?? "")
        cell.studioImage.kf.setImage(with: url)
        cell.studioNameLabel.text = studio.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: StudioViewController 이동
        guard let studio = studioModels?[indexPath.row] else { return }
        let studioVC = StudioViewController()
        studioVC.studio = studio
        self.navigationController?.pushViewController(studioVC, animated: true)
    }
}

extension MainViewController: UICollectionViewDelegate {
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 58, height: 80)
    }
}

// MARK: - UIScrollViewDelegate Extension

extension MainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == imageScrollView {
            let value = scrollView.contentOffset.x / scrollView.frame.size.width
            if value > CGFloat(pageControl.numberOfPages - 1) {
                imageScrollView.setContentOffset(CGPoint(x: 0, y: .zero), animated: true)
            } else if value < 0 {
                imageScrollView.setContentOffset(CGPoint(x: imageScrollView.contentSize.width - (Device.width - 44) , y: .zero), animated: true)
            } else {
                pageControl.currentPage = Int(round(value))
            }
            scrollImageTitleLabel.text = mainEventModels?[pageControl.currentPage].title
        }
    }
}

// MARK: - Preview

import SwiftUI

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = MainViewController

    func makeUIViewController(context: Context) -> MainViewController {
        return MainViewController()
    }

    func updateUIViewController(_ uiViewController: MainViewController, context: Context) {
    }
}

@available(iOS 13.0.0, *)
struct ViewControllerPreview: PreviewProvider {
    static var previews: some View {
        ViewControllerRepresentable()
    }
}
