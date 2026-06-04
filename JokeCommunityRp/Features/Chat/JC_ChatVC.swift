//
//  JC_ChatVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit

class JC_ChatVC: JC_BaseVC {

    private var users: [JC_ChatUser] = []
    private var messages: [JC_ChatMessage] = []
    private var chatObserver: NSObjectProtocol?
    private var profileObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if chatObserver == nil {
            let center = NotificationCenter.default
            chatObserver = center.addObserver(
                forName: .jcChatDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadMessages()
            }
            profileObserver = center.addObserver(
                forName: .jcUserProfileDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadFollowingUsers()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        JS_NetworkTool.shared.post { result in
            switch result {
            case .success(_):
                self.loadData()
            case .failure(_):
                self.loadData()
            }
        }
    }

    private func loadData() {
        loadFollowingUsers()
        loadMessages()
    }

    private func loadFollowingUsers() {
        let currentUser = JC_CurrentUser.shared.user ?? JC_UserModel.current
        users = currentUser.followingUserIds.compactMap { userId in
            guard let user = JC_UserData.resolvedUser(userId: userId) else { return nil }
            return JC_ChatUser(userId: userId, name: user.nickname, avatar: user.avatar)
        }
        updateUserCollectionVisibility()
        userCollectionView.reloadData()
    }

    private func updateUserCollectionVisibility() {
        let hasFollowing = !users.isEmpty
        userCollectionView.isHidden = !hasFollowing
        userCollectionView.snp.updateConstraints { make in
            make.height.equalTo(hasFollowing ? 88 : 0)
        }
        sectionTitleLabel.snp.remakeConstraints { make in
            if hasFollowing {
                make.top.equalTo(userCollectionView.snp.bottom).offset(20)
            } else {
                make.top.equalTo(titleUnderlineView.snp.bottom).offset(20)
            }
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    private func loadMessages() {
        messages = JC_ChatStore.shared.conversationListItems()
        tableView.reloadData()
    }

    private func setupUI() {
        view.addSubview(topView)
        view.addSubview(tableView)
        view.addSubview(emptyView)

        topView.addSubview(titleLabel)
        topView.addSubview(titleUnderlineView)
        topView.addSubview(userCollectionView)
        topView.addSubview(sectionTitleLabel)

        topView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
        }

        titleUnderlineView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.width.equalTo(80)
            make.height.equalTo(4)
        }

        userCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleUnderlineView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(88)
        }

        sectionTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(userCollectionView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().offset(-12)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(40)
        }

        userCollectionView.dataSource = self
        userCollectionView.delegate = self
        userCollectionView.register(JC_ChatUserCell.self, forCellWithReuseIdentifier: JC_ChatUserCell.reuseIdentifier)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JC_ChatMessageCell.self, forCellReuseIdentifier: JC_ChatMessageCell.reuseIdentifier)
    }

    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "CHAT"
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 28)
            ?? UIFont.boldSystemFont(ofSize: 28)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let titleUnderlineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#D4FF00")
        view.layer.cornerRadius = 2
        return view
    }()

    private lazy var userCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Massages"
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 22)
            ?? UIFont.boldSystemFont(ofSize: 22)
        label.textColor = UIColor(hex: "#333333")
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 84
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()
    
    private var emptyView = JC_EmptyView()

}

extension JC_ChatVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        users.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: JC_ChatUserCell.reuseIdentifier,
            for: indexPath
        ) as? JC_ChatUserCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: users[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: 64, height: 88)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.item]
        let roomVC = JC_ChatRoomVC(peerUserId: user.userId, roomTitle: user.name.uppercased())
        navigationController?.pushViewController(roomVC, animated: true)
    }

}

extension JC_ChatVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JC_ChatMessageCell.reuseIdentifier,
            for: indexPath
        ) as? JC_ChatMessageCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let message = messages[indexPath.row]
        let roomVC = JC_ChatRoomVC(peerUserId: message.peerUserId, roomTitle: message.userName)
        navigationController?.pushViewController(roomVC, animated: true)
    }

}
