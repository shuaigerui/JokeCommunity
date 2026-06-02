//
//  JC_ChatVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit

class JC_ChatVC: JC_BaseVC {

    private let users: [JC_ChatUser] = Array(
        repeating: JC_ChatUser(name: "Angela", avatar: nil),
        count: 6
    )

    private let messages: [JC_ChatMessage] = Array(
        repeating: JC_ChatMessage(
            userName: "BOOKER",
            preview: "This is my first time sharin ........",
            avatar: nil
        ),
        count: 6
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.addSubview(topView)
        view.addSubview(tableView)

        topView.addSubview(titleLabel)
        topView.addSubview(titleUnderlineView)
        topView.addSubview(searchContainerView)
        searchContainerView.addSubview(searchTextField)
        topView.addSubview(addButton)
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

        searchContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleUnderlineView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalTo(addButton.snp.leading).offset(-12)
            make.height.equalTo(44)
        }

        searchTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(searchContainerView)
            make.trailing.equalToSuperview().offset(-24)
            make.size.equalTo(44)
        }

        userCollectionView.snp.makeConstraints { make in
            make.top.equalTo(searchContainerView.snp.bottom).offset(20)
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

    private let searchContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        view.layer.masksToBounds = true
        return view
    }()

    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "search..."
        textField.font = UIFont.italicSystemFont(ofSize: 16)
        textField.textColor = UIColor(hex: "#333333")
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .jc_yellow
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hex: "#333333").cgColor
        button.layer.masksToBounds = true
        button.setTitle("+", for: .normal)
        button.setTitleColor(UIColor(hex: "#333333"), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        return button
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
        let roomVC = JC_ChatRoomVC(roomTitle: message.userName)
        navigationController?.pushViewController(roomVC, animated: true)
    }

}
