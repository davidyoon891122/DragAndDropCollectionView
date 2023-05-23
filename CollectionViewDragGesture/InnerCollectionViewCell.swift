//
//  InnerCollectionViewCell.swift
//  CollectionViewDragGesture
//
//  Created by jiwon Yoon on 2023/05/23.
//

import UIKit
import SnapKit

final class InnerCollectionViewCell: UICollectionViewCell {
    static let identifier = "InnerCollectionViewCell"
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        
        [
            textLabel
        ]
            .forEach {
                view.addSubview($0)
            }
        
        textLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        return view
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(text: String) {
        textLabel.text = text
    }
}

private extension InnerCollectionViewCell {
    func setupViews() {
        contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4.0)
        }
    }
}
