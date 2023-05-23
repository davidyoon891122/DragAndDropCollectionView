//
//  MainCollectionViewCell.swift
//  CollectionViewDragGesture
//
//  Created by jiwon Yoon on 2023/05/23.
//

import UIKit
import SnapKit

final class MainCollectionViewCell: UICollectionViewCell {
    static let identifier = "MainCollectionViewCell"
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            InnerCollectionViewCell.self,
            forCellWithReuseIdentifier: InnerCollectionViewCell.identifier
        )
        
        return collectionView
    }()
    
    private var data: [Int] = []
    
    private lazy var cellLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .cyan
        return label
    }()
    
    private var datasource: UICollectionViewDiffableDataSource<Int, Int>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureDatasource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(text: String) {
        cellLabel.text = text
    }
}

private extension MainCollectionViewCell {
    func setupViews() {
        contentView.backgroundColor = .red
        
        [
            collectionView,
            cellLabel
        ]
            .forEach {
                contentView.addSubview($0)
            }
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8.0)
        }
        
        cellLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, layoutEnvironment in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 2), heightDimension: .fractionalHeight(1.0)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0 / 2)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
        }, configuration: configuration)
        
        return layout
    }
    
    func configureDatasource() {
        datasource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InnerCollectionViewCell.identifier, for: indexPath) as? InnerCollectionViewCell else { return UICollectionViewCell() }
            let result = item * Int(self.cellLabel.text!)!
            cell.setupCell(text: "\(result)")
            
            return cell
        })
        
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([1])
        snapshot.appendItems([1,2,3,4])
        datasource.apply(snapshot, animatingDifferences: true)
    }
}
