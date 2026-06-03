//
//  JC_ProfileVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit

class JC_ProfileVC: JC_BaseVC {

    private let headerView = JC_ProfileHeaderView()

    private var posts: [JC_ProfilePost] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderCallback()
        setupTableView()
        loadData()
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
                content: post.content,
                images: list.map { Optional($0) },
                likeCount: post.likeCount,
                isVideo: false
            )
        case .video(let url):
            return JC_ProfilePost(
                content: post.content,
                images: [videoThumbnail(url: url)],
                likeCount: post.likeCount,
                isVideo: true
            )
        }
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
        cell.configure(with: posts[indexPath.row])
        return cell
    }

}
