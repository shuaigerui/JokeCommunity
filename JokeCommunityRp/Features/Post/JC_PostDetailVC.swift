//
//  JC_PostDetailVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit
import Toast_Swift

class JC_PostDetailVC: JC_BaseVC {

    private let post: JC_PostItem

    private var comments: [JC_PostComment] = []

    init(post: JC_PostItem) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureHeader()
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
        bindActions()
        configureHeader()
    }
    
    private func loadData() {
        comments = JC_PostStore.shared.comments(for: post.postId)
        tableView.reloadData()
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
        infoButton.addTarget(self, action: #selector(clickReport), for: .touchUpInside)
        commentInputView.onSendTapped = { [weak self] text in
            self?.appendComment(text)
        }
        headerView.onAvatarTapped = { [weak self] in
            guard let self else { return }
            let personVC = JC_PersonVC(userId: post.authorUserId)
            navigationController?.pushViewController(personVC, animated: true)
        }
        headerView.onLikeTapped = { [weak self] in
            self?.handleLikeTapped()
        }
        headerView.onDislikeTapped = { [weak self] in
            self?.handleDislikeTapped()
        }
    }

    private func configureHeader() {
        headerView.configure(with: currentPostItem())
    }

    private func currentPostItem() -> JC_PostItem {
        guard let model = JC_PostStore.shared.post(postId: post.postId) else { return post }
        return JC_PostItem(
            postId: post.postId,
            authorUserId: post.authorUserId,
            userName: post.userName,
            age: post.age,
            gender: post.gender,
            avatar: post.avatar,
            content: post.content,
            images: post.images,
            likeCount: model.likeCount,
            dislikeCount: model.dislikeCount,
            isLiked: JC_PostStore.shared.isLiked(postId: post.postId),
            isDisliked: JC_PostStore.shared.isDisliked(postId: post.postId),
            showAddFriend: post.showAddFriend
        )
    }

    private func handleLikeTapped() {
        guard let result = JC_PostStore.shared.toggleLike(postId: post.postId) else { return }
        headerView.applyLikeState(isLiked: result.isLiked, likeCount: result.likeCount)
    }

    private func handleDislikeTapped() {
        guard let result = JC_PostStore.shared.toggleDislike(postId: post.postId) else { return }
        headerView.applyDislikeState(isDisliked: result.isDisliked, dislikeCount: result.dislikeCount)
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
        let user = JC_CurrentUser.shared.user ?? JC_UserModel.current
        guard let comment = JC_PostStore.shared.addComment(
            postId: post.postId,
            userId: user.userId,
            userName: user.nickname,
            content: text
        ) else { return }

        comments.append(comment)
        let indexPath = IndexPath(row: comments.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    private func handleCommentMore(_ comment: JC_PostComment) {
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId
        if comment.userId == currentUserId {
            presentDeleteCommentConfirmation(for: comment)
        } else {
            pushReportComment(comment)
        }
    }

    private func presentDeleteCommentConfirmation(for comment: JC_PostComment) {
        let alert = UIAlertController(
            title: "Delete Comment",
            message: "Are you sure you want to delete this comment? This can't be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteComment(comment)
        })
        present(alert, animated: true)
    }

    private func deleteComment(_ comment: JC_PostComment) {
        guard JC_PostStore.shared.deleteComment(postId: post.postId, commentId: comment.commentId) else { return }
        if let index = comments.firstIndex(where: { $0.commentId == comment.commentId }) {
            comments.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        } else {
            loadData()
        }
    }

    private func pushReportComment(_ comment: JC_PostComment) {
        let reportVC = JC_ReportVC(postId: post.postId, commentId: comment.commentId)
        reportVC.onReportSubmitted = { [weak self] in
            self?.view.makeToast("Report submitted successfully")
            self?.loadData()
        }
        navigationController?.pushViewController(reportVC, animated: true)
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func clickReport() {
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId
        if post.authorUserId == currentUserId {
            presentDeletePostConfirmation()
        } else {
            pushReportPost()
        }
    }

    private func presentDeletePostConfirmation() {
        let alert = UIAlertController(
            title: "Delete Post",
            message: "Are you sure you want to delete this post? This can't be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            JC_PostStore.shared.deletePost(postId: self.post.postId)
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func pushReportPost() {
        let reportVC = JC_ReportVC(postId: post.postId)
        reportVC.onReportSubmitted = { [weak self] in
            self?.view.makeToast("Report submitted successfully")
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(reportVC, animated: true)
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
        let comment = comments[indexPath.row]
        cell.configure(with: comment)
        cell.onMoreTapped = { [weak self] in
            self?.handleCommentMore(comment)
        }
        return cell
    }

}
