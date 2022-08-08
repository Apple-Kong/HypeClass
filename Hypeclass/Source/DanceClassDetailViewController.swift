//
//  DanceClassDetailViewController.swift
//  Hypeclass
//
//  Created by GOngTAE on 2022/07/30.
//

import UIKit
import Kingfisher
import FirebaseAuth

class DanceClassDetailViewController: BaseViewController {
    
    //MARK: - Properties
    
    var model: DanceClass?
    var instructor: [Dancer]?
    var studio: [Studio]?
    let headerTitles = ["강사", "스튜디오"]
    private var coverImageTopAnchor: NSLayoutConstraint?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: 400, height: 800)
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 26)
        
        return label
    }()
    
    private let secondaryLabel: UILabel = {
        let label = UILabel()
        label.text = "6월 29일 수요일 18:20 ~ 21:40"
        label.font = UIFont.systemFont(ofSize: 12, weight: .light)
        label.textColor = .white
        
        return label
    }()
    
    private let aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "소개"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let aboutTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = 0
        textView.textAlignment = .left
        textView.isEditable = false
        textView.sizeToFit()
        
        return textView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 100
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.separatorColor = .clear
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        return tableView
    }()
    
    private let ctaButton: CTAButton = {
        let button = CTAButton(title: "신청하기")
        button.addTarget(self, action: #selector(ctaButtonTap), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTableView()
        configure()
        scrollView.delegate = self
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        configure()
//    }
    
    //MARK: - Selectors
    
    @objc func ctaButtonTap() {
        if AuthManager.shared.isLogin {
            // 로그인 되어 있을 시 신청 메서드 작동
            presentAlert(title: "신청하기", message: "신청 후에는 취소, 수강관련안내 문자가 회원님의 핸드폰 번호로 전송됩니다", isCancelActionIncluded: true, preferredStyle: .alert) { action in
                print("DEUBG: 신청하기 로직 연결 필요")
                self.notionCall()
                self.presentBottomAlert(message: "신청이 완료되었습니다.")
            }
        } else {
            let vc = UINavigationController(rootViewController: AuthOnboardViewController())
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: - Helpers
    private func notionCall() {
        let headers: [String: String] = [
//            "Accept": "application/json",
            "Notion-Version": "2022-06-28",
            "Content-Type": "application/json",
            "Authorization": "secret_AvjFT0QUYY5SQpjxIJ2VNBqMcxWFfFcAFmg2KeUh2Hk"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.notion.com/v1/pages")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = """
            {
                "parent": {
                    "database_id": "4b48a3ceee304cc987054fe45613f60d"
                },
                "properties": {
                    "Name": {
                        "title": [
                            {
                                "text": {
                                    "content": "\(AuthManager.shared.userName ?? "")"
                                }
                            }
                        ]
                    },
                    "isPayed": {
                        "checkbox": false
                    }
                }
            }
        """.data(using: .utf8)

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            print(error.debugDescription)
            print(response.debugDescription)
            print(data?.debugDescription)
          if (error != nil) {
              print(error.debugDescription)
         
          } else {
            let httpResponse = response as? HTTPURLResponse
              print(httpResponse.debugDescription)
          }
        })

        dataTask.resume()
        
    }
    
    func configure() {
        guard let model = model else { return }
        guard let dancerID = model.dancerID else { return }
        guard let studioID = model.studioID else { return }
        IndicatorView.shared.show()
        IndicatorView.shared.showIndicator()
        titleLabel.text = model.name
        secondaryLabel.text = "\(model.startTime?.text ?? "") \(model.startTime?.dayOfTheWeek ?? "") \(model.startTime?.hourMinText ?? "") ~ \(model.endTime?.hourMinText ?? "")"
        aboutTextView.text = model.description

        Task {
            do {
                async let dancers = DancerManager.shared.requestDancersBy(dancerIDs: [dancerID])
                async let studios = StudioManager.shared.requestStudiosBy(studioIDs: [studioID])
                let results: [Any] = try await [dancers, studios]
                self.instructor = results[0] as? [Dancer]
                self.studio = results[1] as? [Studio]
                let url = URL(string: self.model?.coverImageURL ?? "")
                coverImageView.kf.setImage(with: url)
                tableView.reloadData()
                IndicatorView.shared.dismiss()
            } catch {
                IndicatorView.shared.dismiss()
                presentBottomAlert(message: "데이터를 불러오지 못했습니다.")
            }
        }
    }
    
    func configureTableView() {
        tableView.register(ItemCell.self, forCellReuseIdentifier: "DanceClassDetailCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configureUI() {
        //레이아웃 구성
        let safeArea = view.safeAreaLayoutGuide
        let contentLayout = scrollView.contentLayoutGuide
        let frameLayout = scrollView.frameLayoutGuide
        
        view.addSubview(ctaButton)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ctaButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            ctaButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            ctaButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
            ctaButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -20)
        ])
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: contentLayout.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentLayout.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: frameLayout.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 1000)
        ])
        
        contentView.addSubview(coverImageView)
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageTopAnchor = NSLayoutConstraint(item: coverImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
        contentView.addConstraint(coverImageTopAnchor!)
        NSLayoutConstraint.activate([
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 260)
        ])
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -25)
        ])
        
        contentView.addSubview(secondaryLabel)
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secondaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            secondaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            secondaryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        
        contentView.addSubview(aboutLabel)
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aboutLabel.topAnchor.constraint(equalTo: secondaryLabel.bottomAnchor, constant: 20),
            aboutLabel.leadingAnchor.constraint(equalTo: secondaryLabel.leadingAnchor)
        ])
        
        contentView.addSubview(aboutTextView)
        aboutTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aboutTextView.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 10),
            aboutTextView.leadingAnchor.constraint(equalTo: aboutLabel.leadingAnchor),
            aboutTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -25)
        ])
        
        contentView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: aboutTextView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
}

//MARK: - UITableViewDataSource

extension DanceClassDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Section
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.text = headerTitles[section]
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        return view
    }
    
    //MARK: - ROW
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? instructor?.count ?? 0 : studio?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DanceClassDetailCell") as? ItemCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = .clear
        cell.profileImage.backgroundColor = .gray
        cell.selectionStyle = .none
        cell.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        if indexPath.section == 0 {
            guard let dancer = instructor?[indexPath.row] else { return cell }
            let url = URL(string: dancer.profileImageURL ?? "")
            cell.profileImage.kf.setImage(with: url)
            cell.titleLabel.text = dancer.name
        } else {
            guard let studio = studio?[indexPath.row] else { return cell }
            let url = URL(string: studio.profileImageURL ?? "")
            cell.profileImage.kf.setImage(with: url)
            cell.titleLabel.text = studio.name
//            cell.subtitleLabel.text = studio.description
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let dancer = instructor?[indexPath.row] else { return }
            let dancerVC = DancerDetailViewController()
            dancerVC.model = dancer
            self.navigationController?.pushViewController(dancerVC, animated: true)
        } else {
            guard let studio = studio?[indexPath.row] else { return }
            let studioVC = StudioViewController()
            studioVC.studio = studio
            self.navigationController?.pushViewController(studioVC, animated: true)
        }
    }
}

extension DanceClassDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //MARK: 커버 이미지 stick to top 애니메이션
        let offset = scrollView.contentOffset.y
        if offset < 0 {
            coverImageTopAnchor?.constant = offset
            coverImageView.heightConstraint?.constant = 260 - offset
        } else {
            coverImageView.heightConstraint?.constant = 260
        }
        
        //MARK: 네비게이션 바 Fade 애니메이션
        var proportionalOffset =  offset / 70
        
        if proportionalOffset > 1 {
            proportionalOffset = 1
            let color = UIColor.background.withAlphaComponent(1)
            self.navigationController?.navigationBar.backgroundColor = color
            UIApplication.statusBarBackgroundColor = color
        } else {
            let color = UIColor.background.withAlphaComponent(proportionalOffset)
            self.navigationController?.navigationBar.backgroundColor = color
            UIApplication.statusBarBackgroundColor = color
        }
    }
}

//MARK: - Preview
import SwiftUI

struct DanceClassDetailViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = DanceClassDetailViewController

    func makeUIViewController(context: Context) -> DanceClassDetailViewController {
        return DanceClassDetailViewController()
    }

    func updateUIViewController(_ uiViewController: DanceClassDetailViewController, context: Context) {}
}

@available(iOS 13.0.0, *)
struct DanceClassDetailViewControllerPreview: PreviewProvider {
    static var previews: some View {
        DanceClassDetailViewControllerRepresentable()
    }
}
