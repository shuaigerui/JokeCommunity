//
//  JC_FriendsVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/4.
//

import UIKit

class JC_FriendsVC: JC_BaseVC {

    private var allSections: [JC_FriendSection] = []
    private var displayedSections: [JC_FriendSection] = []
    private var profileObserver: NSObjectProtocol?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        JS_NetworkTool.shared.post { result in
            switch result {
            case .success(_):
                self.loadData()
            case .failure(_):
                self.loadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()

        if profileObserver == nil {
            profileObserver = NotificationCenter.default.addObserver(
                forName: .jcUserProfileDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadData()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    private func loadData() {
        let currentUser = JC_CurrentUser.shared.user ?? JC_UserModel.current
        let friends: [JC_FriendItem] = currentUser.followingUserIds.compactMap { userId in
            guard let user = JC_UserData.resolvedUser(userId: userId) else { return nil }
            return JC_FriendItem(userId: userId, name: user.nickname, avatar: user.avatar)
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        var grouped: [String: [JC_FriendItem]] = [:]
        friends.forEach { friend in
            let key = sectionKey(for: friend.name)
            grouped[key, default: []].append(friend)
        }

        allSections = grouped.keys
            .sorted()
            .map { JC_FriendSection(title: $0, items: grouped[$0] ?? []) }

        displayedSections = allSections
        let letters = displayedSections.map(\.title)
        indexBar.configure(letters: letters)

        let isEmpty = displayedSections.isEmpty
        emptyView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        indexBar.isHidden = isEmpty
        tableView.reloadData()
    }

    private func sectionKey(for name: String) -> String {
        guard let first = name.trimmingCharacters(in: .whitespacesAndNewlines).first else {
            return "#"
        }
        let letter = String(first).uppercased()
        return letter.first?.isLetter == true ? letter : "#"
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(listContainerView)
        listContainerView.addSubview(tableView)
        listContainerView.addSubview(indexBar)
        view.addSubview(emptyView)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(imageDisplaySize(named: "common_back"))
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        listContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(25)
            make.leading.trailing.bottom.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(indexBar.snp.leading).offset(-4)
        }

        indexBar.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.top.bottom.equalToSuperview().inset(12)
            make.width.equalTo(24)
        }

        emptyView.snp.makeConstraints { make in
            make.center.equalTo(listContainerView)
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JC_FriendCell.self, forCellReuseIdentifier: JC_FriendCell.reuseIdentifier)
        tableView.register(
            JC_FriendsSectionHeaderView.self,
            forHeaderFooterViewReuseIdentifier: JC_FriendsSectionHeaderView.reuseIdentifier
        )
    }

    private func bindActions() {
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        indexBar.onSelectLetter = { [weak self] letter in
            self?.scrollToSection(letter: letter)
        }
    }

    private func scrollToSection(letter: String) {
        guard let index = displayedSections.firstIndex(where: { $0.title == letter }) else { return }
        let indexPath = IndexPath(row: 0, section: index)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    private func openChat(with item: JC_FriendItem) {
        let roomVC = JC_ChatRoomVC(peerUserId: item.userId, roomTitle: item.name.uppercased())
        navigationController?.pushViewController(roomVC, animated: true)
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Friends"
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 26)
            ?? UIFont.boldSystemFont(ofSize: 26)
        label.textColor = UIColor(hex: "#333333")
        label.textAlignment = .center
        return label
    }()

    private let listContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 72
        tableView.sectionHeaderHeight = 28
        tableView.sectionFooterHeight = 0
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()

    private let indexBar = JC_FriendsIndexBar()

    private let emptyView = JC_EmptyView()
}

extension JC_FriendsVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        displayedSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedSections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JC_FriendCell.reuseIdentifier,
            for: indexPath
        ) as? JC_FriendCell else {
            return UITableViewCell()
        }
        let item = displayedSections[indexPath.section].items[indexPath.row]
        cell.configure(with: item)
        cell.onChatTapped = { [weak self] in
            self?.openChat(with: item)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: JC_FriendsSectionHeaderView.reuseIdentifier
        ) as? JC_FriendsSectionHeaderView else {
            return nil
        }
        header.configure(title: displayedSections[section].title)
        return header
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = displayedSections[indexPath.section].items[indexPath.row]
        openChat(with: item)
    }
}
