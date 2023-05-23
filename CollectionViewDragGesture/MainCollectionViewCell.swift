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
        
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        return collectionView
    }()
    
    private var data: [String] = []
    
    private lazy var cellLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .cyan
        return label
    }()
    
    private var datasource: UICollectionViewDiffableDataSource<Int, String>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        configureDatasource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(text: String, subData: [String]) {
        data = subData
        cellLabel.text = text
    }
}

extension MainCollectionViewCell: UICollectionViewDragDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = datasource.itemIdentifier(for: indexPath)
        let itemProvider = NSItemProvider(object: item! as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
}

extension MainCollectionViewCell: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let item = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(item: item, section: section)
        }
        
        if coordinator.proposal.operation == .move {
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath)
        } else if coordinator.proposal.operation == .copy {
            //copyItems
        }
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
        datasource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InnerCollectionViewCell.identifier, for: indexPath) as? InnerCollectionViewCell else { return UICollectionViewCell() }
            
            let data = self.data[indexPath.row]
            cell.setupCell(text: "\(data)")
            
            return cell
        })
        
        applySnapshot()
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(["1","2","3","4"])
        datasource.apply(snapshot, animatingDifferences: true)
    }
    
    func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath) {
        if let item = coordinator.items.first,
           let sourceIndexPath = item.sourceIndexPath {
            var snapshot = datasource.snapshot()
            item.dragItem.itemProvider.loadObject(ofClass: NSString.self) { string, error in
                if let string = string as? String {
                    print(string)
                    
                    let sourceItem = snapshot.itemIdentifiers[sourceIndexPath.item]
                    let destinationItem = snapshot.itemIdentifiers[destinationIndexPath.item]
                    
                    if let sourceIndex = snapshot.indexOfItem(sourceItem),
                       let destinationIndex = snapshot.indexOfItem(destinationItem) {
                        if sourceIndex < destinationIndex {
                            snapshot.deleteItems([sourceItem])
                            snapshot.insertItems([sourceItem], afterItem: destinationItem)
                        } else {
                            snapshot.deleteItems([sourceItem])
                            snapshot.insertItems([sourceItem], beforeItem: destinationItem)
                        }
                        dump(snapshot)
                        DispatchQueue.main.async {
                            self.datasource.apply(snapshot, animatingDifferences: true)
                        }
                    }
                    
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            }
        }
    }
}
