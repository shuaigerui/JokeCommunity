//
//  JC_ReportVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/3.
//

import UIKit
import Toast_Swift

class JC_ReportVC: JC_BaseVC {

    private let postId: String
    private let commentId: String?

    var onReportSubmitted: (() -> Void)?

    private let options: [JC_ReportOption] = [
        JC_ReportOption(imageName: "report_content"),
        JC_ReportOption(imageName: "report_language"),
        JC_ReportOption(imageName: "report_relig"),
        JC_ReportOption(imageName: "report_porn"),
        JC_ReportOption(imageName: "report_gender")
    ]

    private var selectedIndex: Int?

    private var rowHeight: CGFloat {
        let width = UIScreen.main.bounds.width - 60
        guard let image = UIImage(named: "report_bg"), image.size.width > 0 else { return 56 }
        return image.size.height / image.size.width * width
    }

    init(postId: String, commentId: String? = nil) {
        self.postId = postId
        self.commentId = commentId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }

    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(JC_ReportCell.self, forCellReuseIdentifier: JC_ReportCell.reuseIdentifier)

        view.addSubview(backButton)
        view.addSubview(titleImageView)
        view.addSubview(tableView)
        view.addSubview(submitButton)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(imageDisplaySize(named: "common_back"))
        }

        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.size.equalTo(imageDisplaySize(named: "report_title", height: 28))
        }

        submitButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            make.height.equalTo(64)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalTo(submitButton.snp.top).offset(-24)
        }
    }

    private func bindActions() {
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func submitTapped() {
        guard selectedIndex != nil else {
            view.makeToast("Please select a report reason")
            return
        }

        if let commentId {
            JC_PostStore.shared.reportComment(commentId: commentId)
        } else {
            JC_PostStore.shared.reportPost(postId: postId)
        }
        onReportSubmitted?()
        navigationController?.popViewController(animated: true)
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "common_back"), for: .normal)
        return button
    }()

    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "report_title")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "report_submit"), for: .normal)
        button.backgroundColor = UIColor(hex: "#FFCC00")
        button.layer.cornerRadius = 32
        button.layer.masksToBounds = true
        return button
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        return tableView
    }()

}

extension JC_ReportVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight + 12
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: JC_ReportCell.reuseIdentifier,
            for: indexPath
        ) as? JC_ReportCell else {
            return UITableViewCell()
        }
        cell.configure(
            option: options[indexPath.row],
            isSelected: selectedIndex == indexPath.row
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previous = selectedIndex
        selectedIndex = indexPath.row

        var reloadPaths = [indexPath]
        if let previous, previous != indexPath.row {
            reloadPaths.append(IndexPath(row: previous, section: 0))
        }
        tableView.reloadRows(at: reloadPaths, with: .none)
    }

}
