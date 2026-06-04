//
//  JC_EmptyView.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/4.
//

import UIKit

class JC_EmptyView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleImageView)
        
        titleImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "common_empty")
        return imageView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
