//
//  JC_PersonVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_PersonVC: JC_BaseVC {

    private let userName: String

    private let headerView = JC_PersonHeaderView()

    private var posts: [JC_PersonPost] = [
        JC_PersonPost(
            date: "2026.03.05",
            content: "This is my first time sharing a joke, I .......",
            images: [nil, nil],
            likeCount: "100W"
        ),
        JC_PersonPost(
            date: "2026.03.05",
            content: "This is my first time sharing a joke, I .......",
            images: [nil, nil],
            likeCount: "100W"
        )
    ]

    init(userName: String = "Angela") {
        self.userName = userName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        configureHeader()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayout()
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(bottomBarView)
        bottomBarView.addSubview(chatButton)
        bottomBarView.addSubview(callButton)
        view.addSubview(backButton)
        view.addSubview(infoButton)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(imageDisplaySize(named: "common_back"))
        }

        infoButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.trailing.equalToSuperview().offset(-24)
            make.size.equalTo(28)
        }

        bottomBarView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(64)
        }

        chatButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(callButton.snp.leading).offset(-16)
            make.width.equalTo(callButton)
        }

        callButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JC_PersonPostCell.self, forCellReuseIdentifier: JC_PersonPostCell.reuseIdentifier)
        tableView.tableHeaderView = headerView
        tableView.contentInset.bottom = 88
        updateTableHeaderLayout()
    }

    private func bindActions() {
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(clickChat), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(clickCall), for: .touchUpInside)
    }

    private func configureHeader() {
        headerView.configure(
            name: userName,
            age: "20",
            bio: "This is my first time sharing a joke, I .......",
            avatar: nil,
            showAddFriend: true
        )
    }

    private func updateTableHeaderLayout() {
        guard tableView.tableHeaderView === headerView else { return }

        let width = tableView.bounds.width
        guard width > 0 else { return }

        headerView.frame = CGRect(x: 0, y: 0, width: width, height: JC_PersonHeaderView.headerHeight)
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func clickChat() {
        let roomVC = JC_ChatRoomVC(roomTitle: userName.uppercased())
        navigationController?.pushViewController(roomVC, animated: true)
    }

    @objc private func clickCall() {
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageView = makeImageView(named: "common_back")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        button.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return button
    }()

    private let infoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "detail_report"), for: .normal)
        return button
    }()

    private let bottomBarView = UIView()

    private lazy var chatButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "person_chat"), for: .normal)
        return button
    }()

    private lazy var callButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "person_video"), for: .normal)
        return button
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 340
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()

}

extension JC_PersonVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JC_PersonPostCell.reuseIdentifier,
            for: indexPath
        ) as? JC_PersonPostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
    }

}
