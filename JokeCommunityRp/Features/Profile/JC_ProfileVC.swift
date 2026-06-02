//
//  JC_ProfileVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit

class JC_ProfileVC: JC_BaseVC {

    private let headerView = JC_ProfileHeaderView()

    private var posts: [JC_ProfilePost] = [
        JC_ProfilePost(
            content: "This is my first time sharing a joke, I .......",
            images: [nil, nil],
            likeCount: "100W"
        ),
        JC_ProfilePost(
            content: "This is my first time sharing a joke, I .......",
            images: [nil, nil],
            likeCount: "100W"
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
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
