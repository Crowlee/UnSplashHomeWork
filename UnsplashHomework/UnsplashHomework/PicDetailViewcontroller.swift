//
//  PicDetailViewcontroller.swift
//  UnsplashHomework
//
//  Created by sjju on 2021/07/24.
//

import Foundation
import UIKit


protocol PicDetailViewControllerDelegate {
    func updateImageIdx() ->Void
}

extension PicDetailViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let selectedItem = self.resultsUrls[indexPath.row]
        return .zero
    }
}
class PicDetailViewController: UIViewController, ConnectionMgrDelegate {
    
    @IBOutlet weak var BitPitcutreView: UICollectionView!
    var resultsUrls = [Item]()
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    var pagingIdx = 0
    var lastSelectedID:UUID = UUID()
    var delegate:PicDetailViewControllerDelegate?
//    func displayResult(data: Dictionary<String, Any>) {
    func displayResult(data: Array<Any>) {
        for dataObj in data {
            let urls = (dataObj as! NSDictionary)["urls"]
            let small = (urls as! NSDictionary)["small"]

            self.resultsUrls.append(Item(image: UIImage.init(), url: small as! String))
            print(resultsUrls.count)
            
        }
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        initialSnapshot.appendSections([.main])
        initialSnapshot.appendItems(self.resultsUrls)
        self.dataSource.apply(initialSnapshot, animatingDifferences: true)


    }
    
    func displayResultWithSearch(data: Dictionary<String, Any>) {
        let dataList = data["results"]
        print(dataList)
        for dataObj in dataList as! Array<Any> {
            let urls = (dataObj as! NSDictionary)["urls"]
            let small = (urls as! NSDictionary)["small"]
            self.resultsUrls.append(Item(image: UIImage.init(), url: small as! String))
            print(resultsUrls.count)

        }
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        initialSnapshot.appendSections([.main])
        initialSnapshot.appendItems(self.resultsUrls)
        self.dataSource.apply(initialSnapshot, animatingDifferences: true)
        DispatchQueue.main.async {
            self.BitPitcutreView.reloadData()
        }


    }

    

    @IBAction func onActionClose(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.updateImageIdx()
        }
    }
    func findUUIDIndex() -> Int{
        var selectedIDx = 0
        for item in self.resultsUrls {
            if self.lastSelectedID == item.identifier{
                break;
            }
            selectedIDx += 1
        }
        return selectedIDx
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.BitPitcutreView.collectionViewLayout = createLayout()
        
        self.dataSource =
            UICollectionViewDiffableDataSource<Section, Item>(collectionView: self.BitPitcutreView)
            { (collectionView, indexPath, item) -> CollectionImgCell? in

            guard let customCell = self.BitPitcutreView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CollectionImgCell else { preconditionFailure() }
                print(indexPath.row)
                print(self.resultsUrls[indexPath.row].url)
                let selectItem = self.resultsUrls[indexPath.row]
                self.lastSelectedID = selectItem.identifier
                customCell.imgVwBack.setImageUrl(self.resultsUrls[indexPath.row].url)
                print("horizontal selectedPath = \(indexPath)")
                if(indexPath.row + 1 == self.resultsUrls.count){
                    self.pagingIdx += 1
                    DispatchQueue.main.async {
                        self.findNextImage(keyword: "")
                    }
                }
                
                return customCell
            }
        
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        initialSnapshot.appendSections([.main])
        initialSnapshot.appendItems(self.resultsUrls)
        self.dataSource.apply(initialSnapshot, animatingDifferences: true)
        print("selected \(self.lastSelectedID)")
        self.BitPitcutreView.scrollToItem(at: IndexPath(row: findUUIDIndex(), section: 0), at: .left, animated: true)

    }
    func findNextImage(keyword:String){
        netMgr.delegate = self
        var urlString = String()
        if(isKeywordSearch == false){
            urlString = String(format:UNSPLASHID,String(self.pagingIdx))
        }
        else {
            urlString = String(format:UNSPLASHIDFIND,String(self.pagingIdx),keyword)
        }
        netMgr.setCommand(strUrl: urlString, strCmd: "GET")
    }

    override func didReceiveMemoryWarning() {
        
    }
    func createLayout() -> UICollectionViewLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = self.BitPitcutreView.frame.size
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        return layout
    }
    
}


