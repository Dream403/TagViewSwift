//
//  ZLTagViewSwift.swift
//  TagViewSwift
//
//  Created by snowlu on 2018/5/11.
//  Copyright © 2018年 LittleShrimp. All rights reserved.
//
import UIKit
import Foundation

fileprivate extension UIColor {

    class func ColorFromRGBValue(_ rgbValue: Int)  -> UIColor{
        
        return UIColor(red:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green:((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0,
                       blue: ((CGFloat)(rgbValue & 0xFF)) / 255.0,
                       alpha: 1.0);
    }
   
    class func ColorFromRGBValueAlpha(_ rgbValue: Int ,_ a:CGFloat )  -> UIColor{
        
        return UIColor(red:((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green:((CGFloat)((rgbValue & 0xFF00) >> 8)) / 255.0,
                       blue: ((CGFloat)(rgbValue & 0xFF)) / 255.0,
                       alpha: a)
    }
    
}

fileprivate extension UIFont {
    
    class  func FontHelFont(_ size:CGFloat) ->UIFont {
        
        return UIFont.init(name: "Helvetica", size: size)!;
    }

    class  func FontName(_ name:String, _ size:CGFloat) ->UIFont {
        
        return UIFont.init(name:name, size: size)!;
    }
}

fileprivate extension UIImage {
    
    class func BundleImageName(_ name:String)->UIImage {
        
        return UIImage.init(named:"TagSwift.bundle/\(name)" )!
        
    }
}


//MARK TagModel
fileprivate class TagModel: NSObject {
    
    var title:String?
    var selected:Bool = false;
    var tagFont:UIFont?
    var tagContentSize:CGSize? {
        get{
            let size = CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            let dic = NSDictionary(object:self.tagFont!, forKey: NSFontAttributeName as NSCopying)
            let strSize = self.title?.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [String : AnyObject], context:nil).size
            return strSize;
        }
    }
    
    init(_ title:String?,_ font:UIFont?) {
        self.title  = title;
        self.tagFont = font;
    }
    
    
}

//MARK UICollectionViewCell
fileprivate  class TagCollectViewCell:UICollectionViewCell {
    
    typealias DeletCompeletBlock  = ((_ tagModel:TagModel?)-> Void);
    
    var  tagLabel:UILabel?;
    
    var deleBT:UIButton = UIButton.init(type: .custom);
    
    var contentInsets:UIEdgeInsets?
    
    var deletCompeletBlock:DeletCompeletBlock?
    
     var tagModel:TagModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.setupView();
        
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.setupView();
    }
    
    required init?(coder aDecoder: NSCoder) {
        
       fatalError("init(coder:) has not been implemented")
    }
    
    func setupView()  {
        
        tagLabel  = UILabel.init();
        
        tagLabel?.textAlignment = NSTextAlignment.center
        
        tagLabel?.isUserInteractionEnabled = false
        
        tagLabel?.font = self.tagModel?.tagFont;
        
        self.contentView.addSubview(tagLabel!);
    
        
         deleBT.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside);
        
         self.contentView.addSubview(deleBT);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        let bounds = self.contentView.bounds;
        
        let width  = bounds.size.width  - (self.contentInsets?.left)! - (self.contentInsets?.right)!
        
        let frame  = CGRect.init(x: 0, y: 0, width: width, height: bounds.size.height-5)
        
        tagLabel?.frame = frame;
        
         tagLabel?.center  = self.contentView.center
        
         deleBT.frame  = CGRect.init(x: width - 5, y: 0, width: 12, height: 12);
        
    }
    //TODO 子视图 超父视图无响应
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event);
        guard view != nil else {
            let newPoint = deleBT.convert(point, from: self.contentView);
            guard deleBT.bounds.contains(newPoint) else {
                return view;
            }
            return deleBT;
        }

        return view;
    }
    
}

extension  TagCollectViewCell {
    @objc fileprivate  func deleteAction(_ sender:UIButton) {
        
        if self.deletCompeletBlock != nil {
            self.deletCompeletBlock!(self.tagModel)
        }
    }
    
    func deleteComplete(_ deletCompelet: @escaping DeletCompeletBlock ) {
        
        self.deletCompeletBlock  = deletCompelet;
    }
}

//MARK SLTagSpaceFlowLayout
fileprivate class SLTagSpaceFlowLayout:UICollectionViewFlowLayout{
    
    var itemAttributes:NSMutableArray?
    
    var contentHeight:CGFloat? = 0;
    
    weak var delegate:UICollectionViewDelegateFlowLayout?
    
    override init() {
        
        super.init()
        
        self.scrollDirection = .vertical;
        
        self.minimumLineSpacing  = 5;
        
        self.minimumInteritemSpacing  = 5;
        
        self.sectionInset   = UIEdgeInsetsMake(5, 5, 5, 5);
        
    }
    
    override func prepare() {

        super.prepare();
    
        contentHeight = 0 ;

        let itemCount  = self.collectionView?.numberOfItems(inSection:0)

        self.itemAttributes = NSMutableArray.init(capacity: itemCount!);

        let  minimumInteritemSpacing: CGFloat  = self.minimumInteritemSpacingAtSection(0);

        let  minimumLineSpacing  = self.minimumLineSpacingAtSection(0);

        let sectionInset:UIEdgeInsets = self.sectionInsetAtSection(0);

        var sectionXOffset = sectionInset.left

        var sectionYOffset = sectionInset.top;

        var  sectionxNextOffset  = sectionInset.left;

        for idx in 0  ..< itemCount!  {

            let indexPath = NSIndexPath.init(item: idx, section: 0);

            let  itemSize = self.delegate?.collectionView!(self.collectionView!, layout: self, sizeForItemAt: indexPath as IndexPath)

            sectionxNextOffset += minimumInteritemSpacing + (itemSize?.width)!;

            if sectionxNextOffset - minimumInteritemSpacing > (self.collectionView?.bounds.size.width)! - sectionInset.right  {

                sectionXOffset = sectionInset.left;
                sectionxNextOffset = (sectionInset.left + minimumInteritemSpacing + (itemSize?.width)!);
                sectionYOffset += ((itemSize?.height)! + minimumLineSpacing);

            } else {

                sectionXOffset = sectionxNextOffset - (minimumInteritemSpacing + (itemSize?.width)!);

            }
            let layoutAttributes  = UICollectionViewLayoutAttributes.init(forCellWith: indexPath as IndexPath)

            layoutAttributes.frame   = CGRect.init(x: sectionXOffset, y: sectionYOffset, width: (itemSize?.width)!, height: (itemSize?.height)!)

            self.itemAttributes?.add(layoutAttributes);

            contentHeight = max(contentHeight!, layoutAttributes.frame.maxY);

        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func minimumInteritemSpacingAtSection(_ section:NSInteger) -> CGFloat {
        
        guard self.delegate != nil  && (self.delegate?.responds(to: #selector(self.delegate?.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))))! else {
            return self.minimumInteritemSpacing;
        }
        
        return  (self.delegate?.collectionView!(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAt: section))!;
    }
    
    func minimumLineSpacingAtSection(_ section:NSInteger) -> CGFloat {
    
        guard self.delegate != nil  && (self.delegate?.responds(to: #selector(self.delegate?.collectionView(_:layout:minimumLineSpacingForSectionAt:))))! else {
            return self.minimumLineSpacing;
        }
        
        return  (self.delegate?.collectionView!(self.collectionView!, layout: self, minimumLineSpacingForSectionAt: section))!;
        
    }
    
    func sectionInsetAtSection(_ section:NSInteger) -> UIEdgeInsets {
        
        guard self.delegate != nil && (self.delegate?.responds(to: #selector(self.delegate?.collectionView(_:layout:insetForSectionAt:))))! else {
            
            return self.sectionInset;
        }
        return (self.delegate?.collectionView!(self.collectionView!, layout: self, insetForSectionAt: section))!
        
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        return itemAttributes?.object(at: indexPath.item) as? UICollectionViewLayoutAttributes;
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return itemAttributes?.filtered(using: NSPredicate.init(block: { (evaluatedObject, bindings) -> Bool in
            
            let tempEvaluatedObject  = evaluatedObject as! UICollectionViewLayoutAttributes;
            
            return rect.intersects(tempEvaluatedObject.frame)
            
        })) as? [UICollectionViewLayoutAttributes]
        
    }
    
    
    override var collectionViewContentSize: CGSize{

        self.prepare()

        let  contentSize = CGSize.init(width: (self.collectionView?.frame.size.width)!, height: contentHeight!);

        return contentSize

    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        
        let oldBounds = self.collectionView?.bounds;
        
        guard __CGSizeEqualToSize((oldBounds?.size)!, newBounds.size) else {
            
            return false
        }
        return  true
    }
    
}

//MARK
@objc public protocol TagViewDelegate : NSObjectProtocol{

    /// 将要选择
    ///
    /// - Parameters:
    ///   - tagView:
    ///   - shouldSelectItemAtIndex: <#shouldSelectItemAtIndex description#>
    @objc  optional  func tagViewShouldSelectItem(_ tagView: ZLTagView ,_ shouldSelectItemAtIndex:Int);

    /// 选择
    ///
    /// - Parameters:
    ///   - tagView: <#tagView description#>
    ///   - didSelectItemAt: <#didSelectItemAt description#>
    @objc  optional  func tagViewSelectItem(_ tagView: ZLTagView ,_ didSelectItemAt:Int) ;
    
    
    /// 将要取消
    ///
    /// - Parameters:
    ///   - tagView:
    ///   - shouldDeselectItemAtIndex: <#shouldDeselectItemAtIndex description#>
    @objc  optional  func tagViewShouldDeselectItem(_ tagView: ZLTagView ,_ shouldDeselectItemAtIndex:Int);
    
    /// 取消
    ///
    /// - Parameters:
    ///   - tagView: <#tagView description#>
    ///   - didDeselectItemAt: <#didDeselectItemAt description#>
    @objc  optional  func tagViewDidDeselectItem(_ tagView: ZLTagView ,_ didDeselectItemAt:Int);
    
     /// 移动
     ///
     /// - Parameters:
     ///   - tagView: <#tagView description#>
     ///   - moveItemAtSoucreIndex: <#moveItemAtSoucreIndex description#>
     ///   - toIndex: <#toIndex description#>
     @objc  optional  func tagViewMoveItem(_ tagView: ZLTagView ,_ moveItemAtSoucreIndex:Int ,_ toIndex:Int);
}



@IBDesignable open class  ZLTagView:UIView{
    
    open var contentInsets:UIEdgeInsets? = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5);
    
    open var lineSpacing:CGFloat? =  5.0;
    
   open  var elementSpacing:CGFloat? = 5.0;
    
    
    fileprivate var tagModels:[TagModel]?
    
    @IBInspectable  open var tags:[String]?{
        
        willSet{
            tagModels = [TagModel]();
            for  string in newValue! {
                let model:TagModel = TagModel.init(string, tagFont);
                tagModels?.append(model);
            }
           collectionView?.reloadData();
        }
    }
    @IBInspectable  open var  contenBGColor:UIColor? = UIColor.white{
        didSet{
            collectionView?.backgroundColor = contenBGColor;
        }
    }
    
    @IBInspectable  open var tagNormaBackgroundlColor:UIColor? = UIColor.ColorFromRGBValue(0xa9a9a9);
    
    @IBInspectable  open var tagSelectedBackgroundColor:UIColor? = UIColor.ColorFromRGBValue(0xdc143c);
    
    @IBInspectable  open var tagNormaTextColor:UIColor? = UIColor.ColorFromRGBValue(0xff8c00);
    
    @IBInspectable  open var tagSelectedTextColor:UIColor?  = UIColor.ColorFromRGBValue(0xffffff);
    
    @IBInspectable   open var tagSelectedBoaderColor:UIColor? = UIColor.ColorFromRGBValue(0xffffff);
    
    @IBInspectable  open var tagNormalBoaderColor:UIColor? = UIColor.ColorFromRGBValue(0xff8c00);
    
    @IBInspectable  open var tagFont:UIFont?  = UIFont.FontHelFont(12);
    
    @IBInspectable  open var tagSelectedFont:UIFont? = UIFont.FontHelFont(12);
    
    open var tagInsets:UIEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1);
    
    open var tagBorderWidth:CGFloat = 0.0;
    
    open var tagcornerRadius:CGFloat = 0.0;
    
     open var deleteImage:UIImage = UIImage.BundleImageName("img-guanbi");
    
    open var tagHeight:CGFloat  = 28;
    
      open var mininumTagWidth:CGFloat = 0

    open var maximumTagWidth:CGFloat  = UIScreen.main.bounds.size.width ;
    
     open var allowsSelection:Bool  = true;
    
     open var allowsMultipleSelection:Bool = false;
    
     open var allowEmptySelection:Bool = true;
    
      open  weak var delegate:TagViewDelegate?
    
     open var longPressMove:Bool = false{
         didSet{
            if longPressMove {
                let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(lonePressMoving(_ :)))
                self.collectionView?.addGestureRecognizer(longPress);
            }
        }
    }
    open var  contentHeigth:CGFloat?{
        get{
            return collectionView?.collectionViewLayout.collectionViewContentSize.height;
        }
    }
    open var selectedIndex:Int{
        get{
            return (collectionView?.indexPathsForSelectedItems?.first?.row)!;
        }
    }
    fileprivate lazy var layout:SLTagSpaceFlowLayout? = { [unowned self] in
        let  layout  = SLTagSpaceFlowLayout.init()
        return layout;
        }()
    
    fileprivate lazy var collectionView:UICollectionView? = { [unowned self] in
        let  collectionView:UICollectionView = UICollectionView.init(frame:CGRect.zero, collectionViewLayout:self.layout!)
        collectionView.showsVerticalScrollIndicator = false;
        collectionView.showsHorizontalScrollIndicator  = false;
        collectionView.isScrollEnabled = false;
        collectionView.backgroundColor = self.contenBGColor;
        return collectionView;
        }()
    
 
    
    open var selectedTags:[String]?{
        get{
            guard allowsMultipleSelection else {
                return nil
            }
            var selectedTag:[String]? = [String]();
            for var indexPath:IndexPath? in (collectionView?.indexPathsForSelectedItems)! {
                let item:Int  = (indexPath?.item)!;
                let tagModel = tagModels![item];
                selectedTag?.append(tagModel.title!);
            }
            return selectedTag;
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame);
        self.setup();
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.setup();
    }
    open override func layoutSubviews() {
        super.layoutSubviews();
        collectionView?.translatesAutoresizingMaskIntoConstraints = false;
        let letf:NSLayoutConstraint = NSLayoutConstraint.init(item: collectionView!, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0);
        let right:NSLayoutConstraint = NSLayoutConstraint.init(item: collectionView!, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0);
         let top:NSLayoutConstraint = NSLayoutConstraint.init(item: collectionView!, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0);
         let bottom:NSLayoutConstraint = NSLayoutConstraint.init(item: collectionView!, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0);
        self.addConstraints([letf,right,top,bottom]);

    }
}

//UICollectionViewDelegateFlowLayout
extension ZLTagView:UICollectionViewDelegateFlowLayout{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return  lineSpacing!;
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return  elementSpacing!;
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return  contentInsets!;
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let tagModel:TagModel? = tagModels?[indexPath.item];
        
        var width:CGFloat = (tagModel?.tagContentSize?.width)! + tagInsets.left + tagInsets.right;
        
        if width < mininumTagWidth {
            width = mininumTagWidth;
        }
        if (width > maximumTagWidth) {
            
            width = maximumTagWidth;
        }
        
        return CGSize.init(width: width, height: tagHeight);
    }
    
}

//MARK UICollectionViewDataSource UICollectionViewDelegate
extension ZLTagView:UICollectionViewDataSource,UICollectionViewDelegate{
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return (tagModels?.count)!;
        
    }
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1;
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let  cell:TagCollectViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TagCollectViewCell.self), for: indexPath) as! TagCollectViewCell;
        
        let  tagModel:TagModel? = tagModels![indexPath.item];
        
        cell.tagModel = tagModel;
        
        cell.tagLabel?.text  = tagModel?.title;
        
        cell.tagLabel?.layer.masksToBounds = tagcornerRadius > 0;
        
        cell.tagLabel?.layer.cornerRadius = tagBorderWidth;
        
        cell.deleBT.isHidden = true;
        
        cell.contentInsets = tagInsets;
        
        cell.tagLabel?.layer.borderWidth = tagBorderWidth;
        
        cell.deleBT.setBackgroundImage(deleteImage, for: .normal);
        cell.deleBT.setBackgroundImage(deleteImage, for: .selected);
        cell.deleBT.setBackgroundImage(deleteImage, for: .highlighted);
        cell.deleBT.setBackgroundImage(deleteImage, for: .disabled);
        //
        cell.deleteComplete { [unowned self] (model:TagModel?) -> Void in
            self.removeWithTitle(model?.title);
        }
        self.setCell(cell, tagModel?.selected);
        
        return cell;
        
    }
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
     
        return true;
    }
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        exchange(&tagModels![sourceIndexPath.item], &tagModels![destinationIndexPath.item]);
        
        collectionView .reloadData();
        
        guard(delegate?.responds(to: #selector(delegate?.tagViewMoveItem(_:_:_:))))!else {
            return;
        }
        delegate?.tagViewMoveItem!(self, sourceIndexPath.item, destinationIndexPath.item);
        

    }
    //FIXME BUG
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard(delegate?.responds(to: #selector(delegate?.tagViewShouldSelectItem(_:_:))))!else {
            return self.allowsSelection;
        }
        delegate?.tagViewShouldSelectItem!(self, indexPath.item);
        return self.allowsSelection;
    }
    
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard (delegate?.responds(to: #selector(delegate?.tagViewShouldDeselectItem(_:_:))))!else {
            return true
        }
        
        delegate?.tagViewShouldDeselectItem!(self, indexPath.item);
        return true;
    }
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = tagModels?[indexPath.item];
        
        let cell:TagCollectViewCell = collectionView.cellForItem(at: indexPath) as!TagCollectViewCell;
        cell.deleBT.isHidden = true;
        guard allowsMultipleSelection else {
            guard (model?.selected)! else {
                model?.selected = true;
                self .setCell(cell, model?.selected);
                return;
            }
            guard !allowEmptySelection && collectionView.indexPathsForSelectedItems?.count == 1 else {
                cell.isSelected  = false;
                collectionView.deselectItem(at: indexPath, animated: false);
                self.collectionView(collectionView, didDeselectItemAt: indexPath);
                collectionView.allowsMultipleSelection = false;
                return;
            }
            return;
        }
        model?.selected = true;
        self .setCell(cell, model?.selected);
        guard (delegate?.responds(to: #selector(delegate?.tagViewSelectItem(_:_:))))!else {
            return ;
        }
        
        delegate?.tagViewSelectItem!(self, indexPath.item);
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let model = tagModels?[indexPath.item];
        
        let cell:TagCollectViewCell = collectionView.cellForItem(at: indexPath) as!TagCollectViewCell;
        
        model?.selected = false;
        self.setCell(cell,model?.selected);
        
        guard (delegate?.responds(to: #selector(delegate?.tagViewDidDeselectItem(_:_:))))!else {
            return ;
        }
        delegate?.tagViewDidDeselectItem!(self, indexPath.item);
    }
    
    
}

//公共方法
public  extension ZLTagView{
  
    func tagViewDidSelectedAt(_ index:Int , _ animated:Bool) {
        collectionView?.selectItem(at:IndexPath.init(item: index, section: 0) , animated: animated, scrollPosition:UICollectionViewScrollPosition.centeredVertically);
    }
    func tagViewDeselectAt(_ index:Int , _ animated:Bool) {
          collectionView?.deselectItem(at:IndexPath.init(item: index, section: 0) , animated: animated);
    }
    
    func TagViewIndex(_ title:String?) -> Int {
        for (index,value) in tagModels!.enumerated() {
            if value.title  == title {
                return index as Int;
            }
        }
        return  NSNotFound;
    }
    
    func addTag(_ title:String?) {
            let tagModel:TagModel = TagModel.init(title, self.tagFont);
            tagModels?.append(tagModel);
            collectionView?.reloadData();
            self.invalidateIntrinsicContentSize();
    }
    func addTagAtIndex(_ title:String?,_ atIndex:Int) {
        guard atIndex >= (tagModels?.count)!  else {
            let tagModel:TagModel = TagModel.init(title, self.tagFont);
            tagModels?.insert(tagModel, at: atIndex);
            collectionView?.reloadData();
            self.invalidateIntrinsicContentSize();
            return;
        }
        print("输入下标有错误");
    }
    
    func removeWithTitle( _ title:String?) {
        tagModels?.remove(at: TagViewIndex(title));
        collectionView?.reloadData();
        self.invalidateIntrinsicContentSize();
    }
    func removeWithIndex( _ index:Int) {
        guard index >= (tagModels?.count)!  else {
            tagModels?.remove(at: index);
            collectionView?.reloadData();
            self.invalidateIntrinsicContentSize();
            return;
        }
         print("输入下标有错误");
    }
    func removeAllTags() {
        tagModels?.removeAll();
        collectionView?.reloadData();
        self.invalidateIntrinsicContentSize();
    }
    
}
//MARK 初始化视图
fileprivate extension ZLTagView{
    func setup() {
        layout?.delegate = self;
        collectionView?.delegate = self;
        collectionView?.dataSource = self;
        collectionView?.register(TagCollectViewCell.self, forCellWithReuseIdentifier:String(describing: TagCollectViewCell.self));
        self.addSubview(collectionView!);
        
        guard maximumTagWidth >= UIScreen.main.bounds.size.width else {
            return;
        }
        maximumTagWidth  = maximumTagWidth - ((contentInsets?.left)! + (contentInsets?.right)!)
    }
}
//MARK 事件
 fileprivate extension ZLTagView{
    func setCell(_ cell:TagCollectViewCell , _ selected:Bool?) {
        
        guard selected! else {
            cell.tagLabel?.backgroundColor = tagNormaBackgroundlColor;
            cell.tagLabel?.font = tagFont!;
            cell.tagLabel?.textColor  = tagNormaTextColor;
            cell.tagLabel?.layer.borderColor = tagNormalBoaderColor?.cgColor;
            
            return;
        }
        cell.tagLabel?.backgroundColor = tagSelectedBackgroundColor;
        cell.tagLabel?.font = tagSelectedFont!;
        cell.tagLabel?.textColor  = tagSelectedTextColor;
        cell.tagLabel?.layer.borderColor = tagSelectedBoaderColor?.cgColor;
    }
    
   @objc func lonePressMoving(_ longPress:UILongPressGestureRecognizer ) {
    switch longPress.state {
    case .began:
        let indexpPath = collectionView?.indexPathForItem(at: longPress.location(in:collectionView));
        let tagCollectViewCell:TagCollectViewCell = collectionView?.cellForItem(at: indexpPath!)  as! TagCollectViewCell;
        tagCollectViewCell.deleBT.isHidden = false;
        collectionView?.beginInteractiveMovementForItem(at: indexpPath!);
    case.changed:
        collectionView?.updateInteractiveMovementTargetPosition(longPress.location(in: collectionView));
    case .ended:
        collectionView?.endInteractiveMovement();
    default:
        collectionView?.cancelInteractiveMovement();
        
    }
    
    }
    
    //交换方法
    func exchange<T>(_ obj1 : inout T, _ obj2 : inout T){
        
        let temp = obj1
        
         obj1 = obj2
        
        obj2 = temp
    }
    
}

