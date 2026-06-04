//
//  JC_BlackListVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_BlackListVC: JC_BaseVC {

    private var items: [JC_BlackListItem] = []
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
    }
    
    private func loadData() {
        items = JC_CurrentUser.shared.blockedUserIdsList.compactMap { userId in
            let user = JC_UserData.resolvedUser(userId: userId)
            return JC_BlackListItem(
                userId: userId,
                userName: user?.nickname ?? userId,
                avatar: user?.avatar
            )
        }
        emptyView.isHidden = items.count > 0
        tableView.reloadData()
    }

    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JC_BlackListCell.self, forCellReuseIdentifier: JC_BlackListCell.reuseIdentifier)

        view.addSubview(backButton)
        view.addSubview(titleView)
        view.addSubview(tableView)
        view.addSubview(emptyView)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.leading.equalToSuperview().offset(30)
            make.width.equalTo(69)
            make.height.equalTo(29)
        }
        
        titleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(36)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }

    private func removeItem(at indexPath: IndexPath) {
        let userId = items[indexPath.row].userId
        JC_CurrentUser.shared.unblockUser(userId: userId)
        items.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        emptyView.isHidden = items.count > 0
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
    
    private let titleView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "blacklist_title")
        v.contentMode = .scaleAspectFill
        return v
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

    private var emptyView = JC_EmptyView()
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
