//
//  JC_ProfileVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit
import Toast_Swift

class JC_ProfileVC: JC_BaseVC {

    private let headerView = JC_ProfileHeaderView()

    private var posts: [JC_ProfilePost] = []
    private var postsObserver: NSObjectProtocol?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderCallback()
        setupTableView()
        loadData()
        if postsObserver == nil {
            postsObserver = NotificationCenter.default.addObserver(
                forName: .jcPostsDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadData()
            }
        }
    }

    private func loadData() {
        let user = JC_CurrentUser.shared.user ?? JC_UserModel.current

        headerView.configure(with: user)
        posts = JC_UserData.posts(for: user.userId).map { makeProfilePost(from: $0) }
        tableView.reloadData()
        updateTableHeaderLayout()
    }

    private func makeProfilePost(from post: JC_PostModel) -> JC_ProfilePost {
        switch post.media {
        case .images(let list):
            return JC_ProfilePost(
                postId: post.postId,
                authorUserId: post.author.userId,
                content: post.content,
                images: list.map { Optional($0) },
                likeCount: post.likeCount,
                isVideo: false
            )
        case .video(let url):
            return JC_ProfilePost(
                postId: post.postId,
                authorUserId: post.author.userId,
                content: post.content,
                images: [videoThumbnail(url: url)],
                likeCount: post.likeCount,
                isVideo: true
            )
        }
    }

    private func handleMoreTapped(for post: JC_ProfilePost) {
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId

        if post.authorUserId == currentUserId {
            presentDeleteConfirmation(for: post)
        } else {
            pushReport(for: post)
        }
    }

    private func presentDeleteConfirmation(for post: JC_ProfilePost) {
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

    private func pushReport(for post: JC_ProfilePost) {
        let reportVC = JC_ReportVC(postId: post.postId)
        reportVC.onReportSubmitted = { [weak self] in
            self?.view.makeToast("Report submitted successfully")
            self?.loadData()
        }
        navigationController?.pushViewController(reportVC, animated: true)
    }

    private func setupHeaderCallback() {
        headerView.onSettingTapped = { [weak self] in
            guard let self else { return }
            let settingVC = JC_SettingVC()
            self.navigationController?.pushViewController(settingVC, animated: true)
        }

        headerView.onEditProfileTapped = { [weak self] in
            guard let self else { return }
            let editVC = JC_EditVC()
            self.navigationController?.pushViewController(editVC, animated: true)
        }

        headerView.onCoinsTapped = { [weak self] in
            guard let self else { return }
            let coinsVC = JC_CoinsVC()
            self.navigationController?.pushViewController(coinsVC, animated: true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayout()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JC_ProfilePostCell.self, forCellReuseIdentifier: JC_ProfilePostCell.reuseIdentifier)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.tableHeaderView = headerView
        updateTableHeaderLayout()
    }

    private func updateTableHeaderLayout() {
        guard tableView.tableHeaderView === headerView else { return }

        let width = tableView.bounds.width
        guard width > 0 else { return }

        headerView.frame = CGRect(x: 0, y: 0, width: width, height: JC_ProfileHeaderView.headerHeight)
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView
    }

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 320
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()

}

extension JC_ProfileVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JC_ProfilePostCell.reuseIdentifier,
            for: indexPath
        ) as? JC_ProfilePostCell else {
            return UITableViewCell()
        }
        let profilePost = posts[indexPath.row]
        cell.configure(with: profilePost)
        cell.onMoreTapped = { [weak self] in
            self?.handleMoreTapped(for: profilePost)
        }
        return cell
    }

}
