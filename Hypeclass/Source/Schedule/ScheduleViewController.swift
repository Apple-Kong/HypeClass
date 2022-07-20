//
//  ScheduleViewController.swift
//  Hypeclass
//
//  Created by GOngTAE on 2022/07/12.
//

import UIKit

class ScheduleViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let monthNumberLabel: UILabel = {
        let label = UILabel()
        label.text = String(Date().get(.month))
        label.textColor = .white
        label.font = .systemFont(ofSize: 30.0, weight: .semibold)
        
        return label
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.text = "월"
        label.textColor = .white
        label.font = .systemFont(ofSize: 20.0, weight: .regular)
        
        return label
    }()
    
    private var selectedDate = Date()

    private let weekCellID = "week"
    
    private let weekCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 11
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .background

        return cv
    }()
    
    
    // TODO: 재사용 Separator로 교체
    private let separator: UIView = {
        let line = UIView()
        line.backgroundColor = .gray
        
        return line
    }()
    
    private let previousButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "chevron.backward")
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(fetchLastWeek), for: .touchUpInside)
        
        return btn
    }()
    
    private let nextButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "chevron.forward")
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15)
        
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(fetchNextWeek), for: .touchUpInside)
        
        return btn
    }()
    
    private let stackViews: [UIStackView] = [
        UIStackView(), UIStackView(), UIStackView(), UIStackView(), UIStackView(), UIStackView(), UIStackView()
    ]
    
    private let scheduleCellID = "schedule"
    
    private let scheduleCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        cv.backgroundColor = .background

        return cv
    }()
    
    private let myDancers: [Dancer?] = {
        let favoriteIDs = [8943430388, 5967052445, 8420831964] // TODO: User Default 사용
        let dancers = MockDataSet.dancers.filter { favoriteIDs.contains(Int($0.id)!) }
        return dancers
    }()

    private var weekSchedules: [[DanceClass]] = [
        [], [], [], [], [], [], []
    ]
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Selectors
    
    /// 지난 주 날짜의 weekdayView로 변경합니다.
    @objc func fetchLastWeek() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!
        reloadViews()
    }
    
    /// 다음 주 날짜의 weekdayView로 변경합니다.
    @objc func fetchNextWeek() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: selectedDate)!
        reloadViews()
    }
    
    /// 댄서 디테일 뷰 페이지로 이동합니다.
    @objc func pushDetailView(sender: UIButton) {
        // TODO: push detailViewController with sender.tag
        print("pushDetailView(): \(sender.tag)")
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        // 상단 month 레이블
        monthNumberLabel.text = String(selectedDate.get(.month))
        view.addSubview(monthNumberLabel)
        monthNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        monthNumberLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        monthNumberLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        
        view.addSubview(monthLabel)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.topAnchor.constraint(equalTo: monthNumberLabel.topAnchor, constant: 8).isActive = true
        monthLabel.leadingAnchor.constraint(equalTo: monthNumberLabel.trailingAnchor).isActive = true
        
        // <> 버튼
        view.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.topAnchor.constraint(equalTo: monthNumberLabel.topAnchor).isActive = true
        nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25).isActive = true
        
        view.addSubview(previousButton)
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.topAnchor.constraint(equalTo: nextButton.topAnchor).isActive = true
        previousButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -5).isActive = true
        
        // weekCollectionView
        weekCollectionView.register(WeekdayCell.self, forCellWithReuseIdentifier: weekCellID)
        weekCollectionView.dataSource = self
        weekCollectionView.delegate = self

        view.addSubview(weekCollectionView)
        weekCollectionView.translatesAutoresizingMaskIntoConstraints = false
        weekCollectionView.topAnchor.constraint(equalTo: monthNumberLabel.bottomAnchor, constant: 45).isActive = true
        weekCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        weekCollectionView.trailingAnchor.constraint(equalTo: weekCollectionView.leadingAnchor, constant: 65).isActive = true
        weekCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -130).isActive = true
        
        // 세로 구분선
        view.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.leadingAnchor.constraint(equalTo: weekCollectionView.trailingAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: weekCollectionView.topAnchor).isActive = true
        separator.bottomAnchor.constraint(equalTo: weekCollectionView.bottomAnchor).isActive = true
        separator.widthAnchor.constraint(equalToConstant: 0.5).isActive = true

        // scheduleCollectionView
        addButtonToStackView()
        scheduleCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: scheduleCellID)
        scheduleCollectionView.dataSource = self
        scheduleCollectionView.delegate = self

        view.addSubview(scheduleCollectionView)
        scheduleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        scheduleCollectionView.contentInset = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 0)
        scheduleCollectionView.topAnchor.constraint(equalTo: monthNumberLabel.bottomAnchor, constant: 40).isActive = true
        scheduleCollectionView.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: 1).isActive = true
        scheduleCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90).isActive = true
        scheduleCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
    
    /// 클래스 데이터를 이용해 StackView에 각각 해당하는 ScheduleButton을 추가합니다.
    private func addButtonToStackView() {
        fetchSchedules()
        
        stackViews.enumerated().forEach{
            let stackView = $0.1
            stackView.subviews.forEach{ subView in
                subView.removeFromSuperview()
            }
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.spacing = 20
            stackView.distribution = .equalSpacing
            
            weekSchedules[$0.0].forEach { schedule in
                let dancerName = schedule.dancerName
                let studioName = schedule.studioID
                let startTime = "\(schedule.startTime.get(.hour)):\(schedule.startTime.get(.minute))"
                let endTime = "\(schedule.endTime.get(.hour)):\(schedule.endTime.get(.minute))"
                
                let btn = ScheduleButton(frame: .zero, dancerName: dancerName, studioName: studioName, startTime: startTime, endTime: endTime)
                btn.tag = 0 // TODO: Dancer id를 Int로 변환
                btn.addTarget(self, action: #selector(pushDetailView), for: .touchUpInside)
                
                stackView.addArrangedSubview(btn)
            }
        }
    }
    
    /// ScheduleViewController에서 변경되는 뷰를 다시 로드합니다.
    private func reloadViews() {
        monthNumberLabel.text = selectedDate.monthString()
        addButtonToStackView()
        scheduleCollectionView.reloadData()
        weekCollectionView.reloadData()
    }

    /// 날짜에 맞는 DanceClass를 각각 배열에 넣어줍니다.
    private func fetchSchedules() {
        let monday = selectedDate.mondayInWeek(at: selectedDate.get(.weekday))
        let cal = Calendar.current

        for idx in 0...6 {
            let date = cal.date(byAdding: .day, value: idx, to: monday)
            weekSchedules[idx] = []

            myDancers.forEach { dancer in
                let dancerSchedules = dancer?.schedules.filter { cal.isDate(date!, inSameDayAs: $0.startTime) }
                dancerSchedules?.forEach { schedule in
                    weekSchedules[idx].append(schedule)
                }
            }
            weekSchedules[idx] = weekSchedules[idx].sorted(by: { $0.startTime < $1.startTime })
        }
    }
}

// MARK: - UICollectionView Extension

extension ScheduleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.scheduleCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: scheduleCellID, for: indexPath)
            cell.contentView.addSubview(stackViews[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: weekCellID, for: indexPath) as! WeekdayCell
            cell.weekdayLabel.text = Weekday.allCases[indexPath.item].rawValue
            cell.dayLabel.text = cell.dayString(date: selectedDate, dayNum: indexPath.item)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
}

extension ScheduleViewController: UICollectionViewDelegate {
}

extension ScheduleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.scheduleCollectionView {
            // TODO: width -> 가장 많은 아이템을 가진 스택 뷰의 width
            let width: CGFloat = 200 * 4
            let height: CGFloat = (collectionView.frame.height / 8)

            return CGSize(width: width, height: height)
        } else {
            return CGSize(width: 30, height: (collectionView.frame.height / 8))
        }
   }
}

// MARK: - Preview

import SwiftUI

struct ScheduleViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = ScheduleViewController

    func makeUIViewController(context: Context) -> ScheduleViewController {
        return ScheduleViewController()
    }

    func updateUIViewController(_ uiViewController: ScheduleViewController, context: Context) {}
}

@available(iOS 13.0.0, *)
struct ScheduleViewControllerPreview: PreviewProvider {
    static var previews: some View {
        ScheduleViewControllerRepresentable()
    }
}
