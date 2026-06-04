//
//  JC_PersonVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit
import Toast_Swift

class JC_PersonVC: JC_BaseVC {

    private let userId: String

    private let headerView = JC_PersonHeaderView()

    private var posts: [JC_PersonPost] = []
    private var postsObserver: NSObjectProtocol?

    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(userName: String) {
        let resolvedId = JC_UserData.allUsers.first { $0.nickname == userName }?.userId
            ?? JC_CurrentUser.shared.user?.userId
            ?? JC_UserData.testUser.userId
        self.init(userId: resolvedId)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        loadData()
        if postsObserver == nil {
            let center = NotificationCenter.default
            postsObserver = center.addObserver(
                forName: .jcPostsDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadData()
            }
            center.addObserver(
                forName: .jcBlockedUsersDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadData()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayout()
    }

    private func loadData() {
        guard let user = resolvedUser() else { return }

        let currentUser = JC_CurrentUser.shared.user ?? JC_UserModel.current
        let isSelf = user.userId == currentUser.userId
        let showAddFriend = !isSelf && !currentUser.isFollowing(userId: user.userId)

        headerView.configure(
            name: user.nickname,
            age: user.ageText,
            bio: user.bio,
            avatar: user.avatar,
            gender: user.gender,
            showAddFriend: showAddFriend
        )
        posts = JC_UserData.posts(for: user.userId).map { makePersonPost(from: $0) }
        updateSelfProfileUI(isSelf: isSelf)
        tableView.reloadData()
        updateTableHeaderLayout()
    }

    private func updateSelfProfileUI(isSelf: Bool) {
        bottomBarView.isHidden = isSelf
        infoButton.isHidden = isSelf
        tableView.contentInset.bottom = isSelf ? 20 : 88
    }

    private func resolvedUser() -> JC_UserModel? {
        JC_UserData.resolvedUser(userId: userId)
    }

    private var displayName: String {
        resolvedUser()?.nickname ?? ""
    }

    private func makePersonPost(from post: JC_PostModel) -> JC_PersonPost {
        switch post.media {
        case .images(let list):
            return JC_PersonPost(
                postId: post.postId,
                authorUserId: post.author.userId,
                date: "2026.03.05",
                content: post.content,
                images: list.map { Optional($0) },
                likeCount: post.likeCount,
                isVideo: false
            )
        case .video(let url):
            return JC_PersonPost(
                postId: post.postId,
                authorUserId: post.author.userId,
                date: "2026.03.05",
                content: post.content,
                images: [videoThumbnail(url: url)],
                likeCount: post.likeCount,
                isVideo: true
            )
        }
    }

    private func handleMoreTapped(for post: JC_PersonPost) {
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId

        if post.authorUserId == currentUserId {
            presentDeleteConfirmation(for: post)
        } else {
            pushReport(for: post)
        }
    }

    private func presentDeleteConfirmation(for post: JC_PersonPost) {
        let alert = UIAlertController(
            title: "Delete Post",
            message: "Are you sure you want to delete this post?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            JC_PostStore.shared.deletePost(postId: post.postId)
            self?.loadData()
        })
        present(alert, animated: true)
    }

    private func pushReport(for post: JC_PersonPost) {
        let reportVC = JC_ReportVC(postId: post.postId)
        reportVC.onReportSubmitted = { [weak self] in
            self?.view.makeToast("Report submitted successfully")
            self?.loadData()
        }
        navigationController?.pushViewController(reportVC, animated: true)
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
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(59)
        }

        chatButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(callButton.snp.leading).offset(-14)
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
        infoButton.addTarget(self, action: #selector(clickReport), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(clickChat), for: .touchUpInside)
        callButton.addTarget(self, action: #selector(clickCall), for: .touchUpInside)
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
    
    @objc private func clickReport() {
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId
        guard userId != currentUserId else { return }

        let alert = UIAlertController(
            title: "Block User",
            message: "Are you sure you want to block this user? Their posts will be hidden.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in
            guard let self else { return }
            JC_CurrentUser.shared.blockUser(userId: self.userId)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    @objc private func clickChat() {
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId
        guard userId != currentUserId else { return }

        if !JC_CurrentUser.shared.isFollowing(userId: userId) {
            JC_ChatAlertView.show(in: self)
            return
        }

        let roomVC = JC_ChatRoomVC(peerUserId: userId, roomTitle: displayName.uppercased())
        navigationController?.pushViewController(roomVC, animated: true)
    }

    @objc private func clickCall() {
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId
        guard userId != currentUserId else { return }

        if !JC_CurrentUser.shared.isFollowing(userId: userId) {
            JC_ChatAlertView.show(in: self)
            return
        }

        JC_VideoRoomVC.presentFrom(self, peerUserId: userId, roomTitle: displayName.uppercased())
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
        let personPost = posts[indexPath.row]
        cell.configure(with: personPost)
        cell.onMoreTapped = { [weak self] in
            self?.handleMoreTapped(for: personPost)
        }
        return cell
    }

}
