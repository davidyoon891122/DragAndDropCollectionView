//
//  ViewController.swift
//  CollectionViewDragGesture
//
//  Created by jiwon Yoon on 2023/05/23.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private lazy var mainCollectionView: UICollectionView = {
        let layout = createLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.identifier)
        
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        return collectionView
    }()
    
    private var datasource: UICollectionViewDiffableDataSource<Int,String>!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureDatasource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}


extension ViewController: UICollectionViewDragDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = datasource.itemIdentifier(for: indexPath)
        let itemProvider = NSItemProvider(object: item! as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
}

extension ViewController: UICollectionViewDropDelegate {
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

private extension ViewController {
    func setupViews() {
        [
            mainCollectionView
        ]
            .forEach {
                view.addSubview($0)
            }
        
        mainCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, layoutEnvironment in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 2), heightDimension: .fractionalHeight(1.0)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0 / 5)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
        })
        
        return layout
    }
    
    func configureDatasource() {
        datasource = UICollectionViewDiffableDataSource<Int, String>(collectionView: mainCollectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.identifier, for: indexPath) as? MainCollectionViewCell else { return UICollectionViewCell() }
            
            cell.setupCell(text: item)
            return cell
        })
        
        applyDatasource()
    }
    
    func applyDatasource() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([1])
        snapshot.appendItems(["1","2","3","4","5","6", "7", "8", "9", "10"])
        
        datasource.apply(snapshot, animatingDifferences: true)
    }
    
    func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath) {
        if let item = coordinator.items.first,
           let sourceIndexPath = item.sourceIndexPath {
            var snapshot = datasource.snapshot()
            item.dragItem.itemProvider.loadObject(ofClass: NSString.self) { string, error in
                if let string = string as? String {
                    print(string)
                    snapshot.deleteItems([string])
                    snapshot.insertItems([string], beforeItem: snapshot.itemIdentifiers[destinationIndexPath.item])
                    DispatchQueue.main.async {
                        self.datasource.apply(snapshot, animatingDifferences: false)
                    }
                }
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        }
    }
}

