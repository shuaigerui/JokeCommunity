//
//  JC_PostDetailVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_PostDetailVC: JC_BaseVC {

    private let post: JC_PostItem

    private var comments: [JC_PostComment] = [
        JC_PostComment(userName: "Angela", content: "I really like your jokes", avatar: nil),
        JC_PostComment(userName: "Angela", content: "I really like your jokes", avatar: nil),
        JC_PostComment(userName: "Angela", content: "I really like your jokes", avatar: nil)
    ]

    init(post: JC_PostItem) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        configureHeader()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeaderLayout()
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(commentInputView)
        view.addSubview(backButton)
        view.addSubview(infoButton)

        commentInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(10)
            make.bottom.equalTo(commentInputView.snp.top)
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(imageDisplaySize(named: "common_back"))
        }

        infoButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.trailing.equalToSuperview().offset(-25)
            make.size.equalTo(30)
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JC_PostCommentCell.self, forCellReuseIdentifier: JC_PostCommentCell.reuseIdentifier)
        tableView.tableHeaderView = headerView
        updateTableHeaderLayout()
    }

    private func bindActions() {
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        commentInputView.onSendTapped = { [weak self] text in
            self?.appendComment(text)
        }
        headerView.onAvatarTapped = { [weak self] in
            guard let self else { return }
            let personVC = JC_PersonVC(userName: post.userName)
            navigationController?.pushViewController(personVC, animated: true)
        }
    }

    private func configureHeader() {
        headerView.configure(with: post)
    }

    private func updateTableHeaderLayout() {
        guard tableView.tableHeaderView === headerView else { return }

        let width = tableView.bounds.width
        guard width > 0 else { return }

        headerView.frame = CGRect(x: 0, y: 0, width: width, height: JC_PostDetailHeaderView.headerHeight)
        headerView.layoutIfNeeded()
        tableView.tableHeaderView = headerView
    }

    private func appendComment(_ text: String) {
        comments.append(JC_PostComment(userName: "Angela", content: text, avatar: nil))
        let indexPath = IndexPath(row: comments.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }

    private let headerView = JC_PostDetailHeaderView()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 110
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.keyboardDismissMode = .onDrag
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()

    private let commentInputView = JC_PostDetailInputView()

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

}

extension JC_PostDetailVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JC_PostCommentCell.reuseIdentifier,
            for: indexPath
        ) as? JC_PostCommentCell else {
            return UITableViewCell()
        }
        cell.configure(with: comments[indexPath.row])
        return cell
    }

}
