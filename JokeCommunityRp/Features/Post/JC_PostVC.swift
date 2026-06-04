//
//  JC_PostVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit
import Toast_Swift

enum JC_PostPageType {
    case square
    case friends
}

class JC_PostVC: JC_BaseVC {

    private var pageType: JC_PostPageType = .square

    private var squarePosts: [JC_PostItem] = []
    private var friendPosts: [JC_PostItem] = []
    private var postsObserver: NSObjectProtocol?

    private var currentPosts: [JC_PostItem] {
        pageType == .square ? squarePosts : friendPosts
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        setupTableView()
        updateHeaderSelection()
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
                forName: .jcUserProfileDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadData()
            }
        }
    }

    private func loadData() {
        let currentUser = JC_CurrentUser.shared.user ?? JC_UserModel.current
        let followingIds = Set(currentUser.followingUserIds)

        squarePosts = JC_UserData.imagePosts.map { makePostItem(from: $0, currentUser: currentUser) }
        friendPosts = JC_UserData.imagePosts
            .filter { followingIds.contains($0.author.userId) }
            .map { makePostItem(from: $0, currentUser: currentUser) }

        tableView.reloadData()
    }

    private func makePostItem(from post: JC_PostModel, currentUser: JC_UserModel) -> JC_PostItem {
        let author = JC_UserData.resolvedAuthor(for: post)
        let images: [UIImage?]
        switch post.media {
        case .images(let list):
            images = list.map { Optional($0) }
        case .video:
            images = []
        }

        let isSelf = author.userId == currentUser.userId
        let isFollowing = currentUser.isFollowing(userId: author.userId)

        return JC_PostItem(
            postId: post.postId,
            authorUserId: author.userId,
            userName: author.nickname,
            age: author.ageText,
            gender: author.gender,
            avatar: author.avatar,
            content: post.content,
            images: images,
            likeCount: post.likeCount,
            showAddFriend: !isSelf && !isFollowing
        )
    }

    private func handlePostAction(for post: JC_PostItem) {
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId

        if post.authorUserId == currentUserId {
            presentDeleteConfirmation(for: post)
        } else {
            pushReport(for: post)
        }
    }

    private func presentDeleteConfirmation(for post: JC_PostItem) {
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

    private func pushReport(for post: JC_PostItem) {
        let reportVC = JC_ReportVC(postId: post.postId)
        reportVC.onReportSubmitted = { [weak self] in
            self?.view.makeToast("Report submitted successfully")
            self?.loadData()
        }
        navigationController?.pushViewController(reportVC, animated: true)
    }

    private func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubview(squareButton)
        headerView.addSubview(friendsButton)

        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(56)
        }

        squareButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.width.equalTo(205)
            make.height.equalTo(27)
        }

        friendsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
            make.width.equalTo(102)
            make.height.equalTo(16)
        }

        squareButton.addTarget(self, action: #selector(squareTapped), for: .touchUpInside)
        friendsButton.addTarget(self, action: #selector(friendsTapped), for: .touchUpInside)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JC_PostCell.self, forCellReuseIdentifier: JC_PostCell.reuseIdentifier)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func updateHeaderSelection() {
        let isSquare = pageType == .square
        squareButtonImageView.image = UIImage(named: isSquare ? "post_squaer_sel" : "post_squaer")
        friendsButtonImageView.image = UIImage(named: isSquare ? "post_friends" : "post_friends_sel")

        let squareSize = isSquare ? CGSize(width: 205, height: 27) : CGSize(width: 102, height: 16)
        let friendsSize = isSquare ? CGSize(width: 102, height: 16) : CGSize(width: 229, height: 22)

        squareButton.snp.updateConstraints { make in
            make.width.equalTo(squareSize.width)
            make.height.equalTo(squareSize.height)
        }

        friendsButton.snp.updateConstraints { make in
            make.width.equalTo(friendsSize.width)
            make.height.equalTo(friendsSize.height)
        }

        UIView.animate(withDuration: 0.2) {
            self.headerView.layoutIfNeeded()
        }
    }

    @objc private func squareTapped() {
        guard pageType != .square else { return }
        pageType = .square
        updateHeaderSelection()
        tableView.reloadData()
    }

    @objc private func friendsTapped() {
        guard pageType != .friends else { return }
        pageType = .friends
        updateHeaderSelection()
        tableView.reloadData()
    }

    private func makeTabButton(imageView: inout UIImageView) -> UIButton {
        let button = UIButton(type: .custom)
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.isUserInteractionEnabled = false
        button.addSubview(image)
        image.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageView = image
        return button
    }

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private lazy var squareButton: UIButton = makeTabButton(imageView: &squareButtonImageView)
    private lazy var friendsButton: UIButton = makeTabButton(imageView: &friendsButtonImageView)
    private var squareButtonImageView = UIImageView()
    private var friendsButtonImageView = UIImageView()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 380
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()

}

extension JC_PostVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentPosts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JC_PostCell.reuseIdentifier,
            for: indexPath
        ) as? JC_PostCell else {
            return UITableViewCell()
        }
        let postItem = currentPosts[indexPath.row]
        cell.configure(with: postItem)
        cell.onMenuTapped = { [weak self] in
            self?.handlePostAction(for: postItem)
        }
        cell.onReportTapped = { [weak self] in
            self?.handlePostAction(for: postItem)
        }
        cell.onAvatarTapped = { [weak self] in
            let personVC = JC_PersonVC(userId: postItem.authorUserId)
            self?.navigationController?.pushViewController(personVC, animated: true)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = JC_PostDetailVC(post: currentPosts[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }

}
