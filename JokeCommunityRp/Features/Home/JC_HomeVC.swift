//
//  JC_HomeVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit
import AVFoundation
import Toast_Swift

class JC_HomeVC: JC_BaseVC {

    private var items: [JC_HomeVideoItem] = []
    private var currentPlayingIndexPath: IndexPath?
    private var postsObserver: NSObjectProtocol?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.isHidden = true
        view.backgroundColor = .black
        configureAudioSession()
        setupCollectionView()
        setupTopBar()
        loadData()
        if postsObserver == nil {
            let center = NotificationCenter.default
            postsObserver = center.addObserver(
                forName: .jcPostsDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadData()
            }
            center.addObserver(
                forName: .jcUserProfileDidChange,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.loadData()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
           layout.itemSize != collectionView.bounds.size,
           collectionView.bounds.width > 0,
           collectionView.bounds.height > 0 {
            layout.itemSize = collectionView.bounds.size
            layout.invalidateLayout()
        }
    }
    
    private func loadData() {
        pauseCurrentVideo()
        items = JC_HomeVideoProvider.loadItems()
        collectionView.reloadData()
        currentPlayingIndexPath = nil

        guard isViewLoaded, view.window != nil else { return }
        DispatchQueue.main.async { [weak self] in
            self?.playVideoInVisibleCell()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.playVideoInVisibleCell()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseCurrentVideo()
    }

    private func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupTopBar() {
        view.addSubview(topBarView)
        topBarView.addSubview(titleImageView)
        topBarView.addSubview(coinImageView)
        topBarView.addSubview(addButton)

        topBarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        titleImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.height.equalTo(28)
        }

        addButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.equalTo(69)
            make.height.equalTo(29)
        }

        coinImageView.snp.makeConstraints { make in
            make.trailing.equalTo(addButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(33)
        }

        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }

    @objc private func addButtonTapped() {
        pauseCurrentVideo()
        showPostSheet()
    }

    private func showPostSheet() {
        guard postView == nil else { return }

        (tabBarController as? JC_TabbarVC)?.setCustomTabBarHidden(true)

        let sheet = JC_HomePostView()
        sheet.hostViewController = self
        sheet.onDismiss = { [weak self] in
            self?.postView = nil
            (self?.tabBarController as? JC_TabbarVC)?.setCustomTabBarHidden(false)
            self?.playVideoInVisibleCell()
        }
        sheet.onRelease = { [weak self] text, media in
            guard let self else { return }
            if JC_CurrentUser.shared.publishPost(content: text, media: media) {
                self.view.makeToast("Posted successfully")
                self.postView?.dismiss()
                self.loadData()
            } else {
                self.view.makeToast("Failed to post. Please try again.")
            }
        }
        postView = sheet
        sheet.present(in: view, animated: true)
    }

    private var postView: JC_HomePostView?

    private func playVideoInVisibleCell() {
        let centerPoint = CGPoint(
            x: collectionView.bounds.midX,
            y: collectionView.contentOffset.y + collectionView.bounds.height * 0.5
        )
        guard let indexPath = collectionView.indexPathForItem(at: centerPoint) else { return }
        playVideo(at: indexPath)
    }

    private func playVideo(at indexPath: IndexPath) {
        guard currentPlayingIndexPath != indexPath else { return }

        pauseCurrentVideo()
        currentPlayingIndexPath = indexPath

        if let cell = collectionView.cellForItem(at: indexPath) as? JC_HomeVideoCell {
            cell.play()
        }
    }

    private func pauseCurrentVideo() {
        guard let indexPath = currentPlayingIndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? JC_HomeVideoCell else {
            currentPlayingIndexPath = nil
            return
        }
        cell.pause()
        currentPlayingIndexPath = nil
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(JC_HomeVideoCell.self, forCellWithReuseIdentifier: JC_HomeVideoCell.reuseIdentifier)
        return collectionView
    }()

    private let topBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()

    private let titleImageView: UIImageView = {
        let imageView = makeImageView(named: "home_title")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let coinImageView: UIImageView = {
        let imageView = makeImageView(named: "home_coin")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "home_add"), for: .normal)
        return button
    }()

}

extension JC_HomeVC: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: JC_HomeVideoCell.reuseIdentifier,
            for: indexPath
        ) as? JC_HomeVideoCell else {
            return UICollectionViewCell()
        }
        let item = items[indexPath.item]
        cell.configure(with: item)
        cell.onLikeTapped = { [weak self] postId in
            self?.handleLikeTapped(postId: postId)
        }
        cell.onReportTapped = { [weak self] postId in
            self?.handleReportTapped(postId: postId)
        }
        return cell
    }

    private func handleLikeTapped(postId: String) {
        guard let result = JC_PostStore.shared.toggleLike(postId: postId),
              let index = items.firstIndex(where: { $0.postId == postId }) else { return }

        let old = items[index]
        items[index] = JC_HomeVideoItem(
            postId: old.postId,
            authorUserId: old.authorUserId,
            avatar: old.avatar,
            videoURL: old.videoURL,
            jokeText: old.jokeText,
            likeCount: result.likeCount,
            commentCount: old.commentCount,
            isLiked: result.isLiked
        )

        let indexPath = IndexPath(item: index, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? JC_HomeVideoCell {
            cell.applyLikeState(isLiked: result.isLiked, likeCount: result.likeCount)
        }
    }

    private func handleReportTapped(postId: String) {
        guard let item = items.first(where: { $0.postId == postId }) else { return }
        let currentUserId = JC_CurrentUser.shared.user?.userId ?? JC_UserModel.current.userId

        if item.authorUserId == currentUserId {
            presentDeleteConfirmation(for: postId)
        } else {
            pushReport(for: postId)
        }
    }

    private func presentDeleteConfirmation(for postId: String) {
        let alert = UIAlertController(
            title: "Delete Post",
            message: "Are you sure you want to delete this post?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            JC_PostStore.shared.deletePost(postId: postId)
            self?.loadData()
        })
        present(alert, animated: true)
    }

    private func pushReport(for postId: String) {
        let reportVC = JC_ReportVC(postId: postId)
        reportVC.onReportSubmitted = { [weak self] in
            self?.view.makeToast("Report submitted successfully")
            self?.loadData()
        }
        navigationController?.pushViewController(reportVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath == currentPlayingIndexPath else { return }
        (cell as? JC_HomeVideoCell)?.play()
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? JC_HomeVideoCell)?.pause()
        if indexPath == currentPlayingIndexPath {
            currentPlayingIndexPath = nil
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playVideoInVisibleCell()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            playVideoInVisibleCell()
        }
    }

}
