//
//  JC_CoinsVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

class JC_CoinsVC: JC_BaseVC {

    private let products: [JC_CoinProduct] = Array(
        repeating: JC_CoinProduct(coins: "10", price: "$4.99"),
        count: 9
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            (tabBarController as? JC_TabbarVC)?.setCustomTabBarHidden(false)
        }
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(headerView)
        view.addSubview(collectionView)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(imageDisplaySize(named: "common_back"))
        }

        headerView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(JC_CoinsHeaderView.headerHeight)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    @objc private func clickBack() {
        navigationController?.popViewController(animated: true)
    }

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

    private let headerView = JC_CoinsHeaderView()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            JC_CoinProductCell.self,
            forCellWithReuseIdentifier: JC_CoinProductCell.reuseIdentifier
        )
        return collectionView
    }()

}

extension JC_CoinsVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        products.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: JC_CoinProductCell.reuseIdentifier,
            for: indexPath
        ) as? JC_CoinProductCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: products[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let spacing: CGFloat = 12
        let columns: CGFloat = 3
        let totalSpacing = spacing * (columns - 1)
        let width = (collectionView.bounds.width - totalSpacing) / columns
        return CGSize(width: floor(width), height: width * 1.08)
    }

}
