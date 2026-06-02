//
//  JC_ChatRoomVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_ChatRoomVC: JC_BaseVC {

    private let roomTitle: String

    private var messages: [JC_ChatRoomMessage] = [
        JC_ChatRoomMessage(text: "Hello!", isOutgoing: false, avatar: nil),
        JC_ChatRoomMessage(text: "Nice to meet you.", isOutgoing: true, avatar: nil)
    ]

    init(roomTitle: String = "BOOKER") {
        self.roomTitle = roomTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        scrollToBottom(animated: false)
    }

    private func setupUI() {
        titleLabel.text = roomTitle

        view.addSubview(navBarView)
        navBarView.addSubview(backButton)
        navBarView.addSubview(titleLabel)
        navBarView.addSubview(infoButton)
        view.addSubview(tableView)
        view.addSubview(chatInputView)

        navBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(imageDisplaySize(named: "common_back"))
        }

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(backButton.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(infoButton.snp.leading).offset(-12)
        }

        infoButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
            make.size.equalTo(28)
        }

        chatInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(chatInputView.snp.top)
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            JC_ChatRoomMessageCell.self,
            forCellReuseIdentifier: JC_ChatRoomMessageCell.reuseIdentifier
        )
    }

    private func bindActions() {
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        chatInputView.onSendTapped = { [weak self] text in
            self?.appendMessage(text)
        }
    }

    private func appendMessage(_ text: String) {
        messages.append(JC_ChatRoomMessage(text: text, isOutgoing: true, avatar: nil))
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        scrollToBottom(animated: true)
    }

    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }

    private let navBarView = UIView()

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

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica-BoldOblique", size: 24)
            ?? UIFont.boldSystemFont(ofSize: 24)
        label.textColor = UIColor(hex: "#333333")
        label.textAlignment = .center
        return label
    }()

    private let infoButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "detail_report"), for: .normal)
        return button
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.keyboardDismissMode = .onDrag
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()

    private let chatInputView = JC_ChatRoomInputView()

}

extension JC_ChatRoomVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JC_ChatRoomMessageCell.reuseIdentifier,
            for: indexPath
        ) as? JC_ChatRoomMessageCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }

}
