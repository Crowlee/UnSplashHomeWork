//
//  ViewController.swift
//  UnsplashHomework
//
//  Created by sjju on 2021/07/20.
//

import UIKit

let netMgr = ConnectionMgr.sharedInstance()

enum webCommand:Int{
    case POST = 0
    case GET = 1
    case PUT = 2
}
//MARK: - Defines

//var cID = "alcMens3Ioz5z95cpC6sbtLMTv90BYvtUc0Rj4W3MaE"
var cID = "VUeaTPDkgaxu0n0QJCR3lIsbDMMn5HrJwMd_zfuBi1s"
var UNSPLASHID = "https://api.unsplash.com/photos?page=%@"
var UNSPLASHIDFIND = "https://api.unsplash.com/search/photos?page=%@&query=%@"
var isKeywordSearch = false
var gKeyWord:String?

//MARK: - Extension
extension ViewController:UICollectionViewDelegate, PicDetailViewControllerDelegate {
    func updateImageIdx() {
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        initialSnapshot.appendSections([.main])
        initialSnapshot.appendItems(self.resultsUrls)
        self.dataSource.apply(initialSnapshot, animatingDifferences: true)
        self.imgLists.scrollToItem(at: IndexPath(row: findUUIDIndex(), section: 0), at: .top, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let nextVc = sb.instantiateViewController(identifier: "DetailView") as PicDetailViewController
        nextVc.modalPresentationStyle = .fullScreen
        nextVc.resultsUrls = self.resultsUrls
        nextVc.pagingIdx = self.pagingIdx
        print("vertical selectedPath = \(indexPath)")
        let selectedItem = self.resultsUrls[indexPath.row]
        nextVc.lastSelectedID = selectedItem.identifier
        nextVc.delegate = self
        self.present(nextVc, animated: true) {
//            nextVc.BitPitcutreView.reloadData()
            
        }
    }
}


class ViewController: UIViewController, ConnectionMgrDelegate{
    
    
    
    
    @IBOutlet weak var imgLists: UICollectionView!
    var resultsUrls = [Item]()
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    var pagingIdx = 0
    var lastSelectedPath:UUID = UUID()

    @IBOutlet weak var txtfdSearch: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.imgLists.delegate = self
        self.findNextImage(keyword: "")
        self.imgLists.collectionViewLayout = createLayout()
        
        self.navigationController?.isNavigationBarHidden = true
        


        self.dataSource =
            UICollectionViewDiffableDataSource<Section, Item>(collectionView: self.imgLists)
            { (collectionView, indexPath, item) -> CollectionImgCell? in

            guard let customCell = self.imgLists.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as? CollectionImgCell else { preconditionFailure() }
                print(indexPath.row)
                print(self.resultsUrls[indexPath.row].url)
                customCell.imgVwBack.setImageUrl(self.resultsUrls[indexPath.row].url)

                print("horizontal indexpath =\(indexPath)")
                if(indexPath.row + 1 == self.resultsUrls.count){
                    self.pagingIdx += 1
                    DispatchQueue.main.async {
                        if(isKeywordSearch == false) {
                            self.findNextImage(keyword: "")
                        }
                        else {
                            self.findNextImage(keyword: gKeyWord!)
                        }
                        
                    }
                }
                return customCell
            }
        self.imgLists.scrollToItem(at: IndexPath(row: findUUIDIndex(), section: 0), at: .left, animated: true)
    }
    func createLayout() -> UICollectionViewLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: self.imgLists.frame.size.width * 0.8, height: self.imgLists.frame.size.width * 0.8)
        
        layout.scrollDirection = .vertical
                

        return layout

    }
    
    func findNextImage(keyword:String){
        netMgr.delegate = self
        var urlString = String()
        if(isKeywordSearch == false){
            urlString = String(format:UNSPLASHID,String(self.pagingIdx))
        }
        else {
            urlString = String(format:UNSPLASHIDFIND,String(self.pagingIdx),keyword)
            print("searchString = \(urlString)")
        }
        netMgr.setCommand(strUrl: urlString, strCmd: "GET")
    }

    func findUUIDIndex() -> Int{
        var selectedIDx = 0
        for item in self.resultsUrls {
            if self.lastSelectedPath == item.identifier{
                break;
            }
            selectedIDx += 1
        }
        return selectedIDx
    }

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
//        print(dataList)
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

    }
    @IBAction func onActionSearch(_ sender: Any) {
        var keyword = self.txtfdSearch.text
        isKeywordSearch = true
        gKeyWord = keyword
        self.resultsUrls.removeAll()
        self.findNextImage(keyword: keyword!)
    }
}


extension UIImageView {

    func setImageUrl(_ url: String) {
        let cacheKey = NSString(string: url)
                if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
                    self.image = cachedImage
                    return
                }
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: url) {
                URLSession.shared.dataTask(with: url) { (data, res, err) in
                    if let _ = err {
                        DispatchQueue.main.async {
                            self.image = UIImage()
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        if let data = data, let image = UIImage(data: data) {
                            self.image = image
                        }
                    }
                }.resume()
            }
        }
    }
 }

class ImageCacheManager {

    static let shared = NSCache<NSString, UIImage>()

    private init() {}
}


