//
//  JC_HomeVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/1.
//

import UIKit
import AVFoundation

class JC_HomeVC: JC_BaseVC {

    private var items: [JC_HomeVideoItem] = []
    private var currentPlayingIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.isHidden = true
        view.backgroundColor = .black
        configureAudioSession()
        items = JC_HomeVideoProvider.loadItems()
        setupCollectionView()
        setupTopBar()
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
            make.width.height.equalTo(44)
        }

        coinImageView.snp.makeConstraints { make in
            make.trailing.equalTo(addButton.snp.leading).offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
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
        sheet.onRelease = { text, media in
            _ = (text, media)
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
        imageView.contentMode = .scaleAspectFit
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
        cell.configure(with: items[indexPath.item])
        return cell
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
