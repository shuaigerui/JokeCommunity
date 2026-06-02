//
//  JC_BlackListVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_BlackListVC: JC_BaseVC {

    private var items: [JC_BlackListItem] = [
        JC_BlackListItem(userName: "Angela", avatar: nil),
        JC_BlackListItem(userName: "Angela", avatar: nil),
        JC_BlackListItem(userName: "Angela", avatar: nil),
        JC_BlackListItem(userName: "Angela", avatar: nil),
        JC_BlackListItem(userName: "Angela", avatar: nil)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
    }

    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JC_BlackListCell.self, forCellReuseIdentifier: JC_BlackListCell.reuseIdentifier)

        view.addSubview(backButton)
        view.addSubview(tableView)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.leading.equalToSuperview().offset(30)
            make.width.equalTo(69)
            make.height.equalTo(29)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(36)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }

    private func removeItem(at indexPath: IndexPath) {
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        let imageView = makeImageView(named: "common_back")
        imageView.isUserInteractionEnabled = false
        button.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return button
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 88
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()

}

extension JC_BlackListVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JC_BlackListCell.reuseIdentifier,
            for: indexPath
        ) as? JC_BlackListCell else {
            return UITableViewCell()
        }

        cell.configure(with: items[indexPath.row])
        cell.onDeleteTapped = { [weak self, weak cell] in
            guard let self, let cell, let currentIndexPath = tableView.indexPath(for: cell) else { return }
            self.removeItem(at: currentIndexPath)
        }
        return cell
    }

}
