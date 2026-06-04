//
//  JC_CoinsVC.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit
import SVProgressHUD
import Toast_Swift

class JC_CoinsVC: JC_BaseVC {

    private var products: [JC_CoinProduct] = JC_CoinCatalog.products
    private var profileObserver: NSObjectProtocol?
    private var isPurchasing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        refreshBalance()
        loadStoreProducts()
        observeProfileChanges()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard isMovingFromParent || isBeingDismissed, let profileObserver else { return }
        NotificationCenter.default.removeObserver(profileObserver)
        self.profileObserver = nil
    }

    private func bindActions() {
        backButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
    }

    private func observeProfileChanges() {
        profileObserver = NotificationCenter.default.addObserver(
            forName: .jcUserProfileDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshBalance()
        }
    }

    private func refreshBalance() {
        let balance = JC_CurrentUser.shared.user?.coinCount ?? JC_UserModel.current.coinCount
        headerView.configure(balance: "\(balance)")
    }

    private func loadStoreProducts() {
        Task { @MainActor in
            do {
                products = try await JC_IAPManager.shared.loadProducts()
                collectionView.reloadData()
            } catch {
                products = JC_CoinCatalog.products
                collectionView.reloadData()
            }
        }
    }

    private func purchaseProduct(at indexPath: IndexPath) {
        guard !isPurchasing else { return }
        guard JC_CurrentUser.shared.isLoggedIn else {
            view.makeToast("Please sign in before purchasing")
            return
        }

        let product = products[indexPath.item]
        isPurchasing = true
        SVProgressHUD.show()

        Task { @MainActor in
            defer {
                isPurchasing = false
                SVProgressHUD.dismiss()
            }

            do {
                let diamonds = try await JC_IAPManager.shared.purchase(productId: product.productId)
                refreshBalance()
                view.makeToast("+\(diamonds) diamonds added")
            } catch let error as JC_IAPError {
                if case .userCancelled = error { return }
                if let message = error.errorDescription {
                    view.makeToast(message)
                }
            } catch {
                view.makeToast("Purchase failed. Please try again.")
            }
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
            make.top.equalTo(backButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(JC_CoinsHeaderView.headerHeight)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(24)
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
        layout.sectionInset = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)

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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        purchaseProduct(at: indexPath)
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
        return CGSize(width: floor(width), height: 135)
    }

}
