//
//  JC_PostVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit

enum JC_PostPageType {
    case square
    case friends
}

class JC_PostVC: JC_BaseVC {

    private var pageType: JC_PostPageType = .square

    private let squarePosts: [JC_PostItem] = [
        JC_PostItem(
            userName: "Angela",
            age: "20",
            avatar: nil,
            content: "This is my first time sharing a joke, I .......",
            images: [nil, nil],
            likeCount: "100W",
            showAddFriend: true
        ),
        JC_PostItem(
            userName: "Angela",
            age: "20",
            avatar: nil,
            content: "This is my first time sharing a joke, I .......",
            images: [nil, nil],
            likeCount: "100W",
            showAddFriend: true
        ),
        JC_PostItem(
            userName: "Angela",
            age: "20",
            avatar: nil,
            content: "This is my first time sharing a joke, I .......",
            images: [nil, nil],
            likeCount: "100W",
            showAddFriend: true
        )
    ]

    private let friendPosts: [JC_PostItem] = [
        JC_PostItem(
            userName: "Angela",
            age: "20",
            avatar: nil,
            content: "This is my first time sharing a joke, I .......",
            images: [nil, nil],
            likeCount: "100W",
            showAddFriend: false
        ),
        JC_PostItem(
            userName: "Angela",
            age: "20",
            avatar: nil,
            content: "This is my first time sharing a joke, I .......",
            images: [nil, nil],
            likeCount: "100W",
            showAddFriend: false
        )
    ]

    private var currentPosts: [JC_PostItem] {
        pageType == .square ? squarePosts : friendPosts
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        setupTableView()
        updateHeaderSelection()
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
            make.height.equalTo(44)
            make.width.equalTo(180)
        }

        friendsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
            make.width.equalTo(140)
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
        cell.configure(with: currentPosts[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = JC_PostDetailVC(post: currentPosts[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }

}
