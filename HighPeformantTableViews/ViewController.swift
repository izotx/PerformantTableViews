//
//  ViewController.swift
//  HighPeformantTableViews
//
//  Created by Janusz Chudzynski on 4/7/16.
//  Copyright © 2016 Janusz Chudzynski. All rights reserved.
//  http://stackoverflow.com/questions/33493602/swift-load-images-async-in-uitableviewcell
//  http://stackoverflow.com/questions/33493602/swift-load-images-async-in-uitableviewcell
//http://stackoverflow.com/questions/10408611/in-a-uitableview-best-method-to-cancel-gcd-operations-for-cells-that-have-gone

import UIKit

class CustomCell:UITableViewCell{
    let mainImageView = UIImageView()
    var generation: Int = 0
    
    func setupCell(){
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
       // contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(mainImageView)
 
        mainImageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 1).active = true
        mainImageView.bottomAnchor.constraintEqualToAnchor(self.contentView.bottomAnchor).active = true
        mainImageView.leadingAnchor.constraintEqualToAnchor(self.imageView?.trailingAnchor).active = true
        mainImageView.trailingAnchor.constraintEqualToAnchor(self.contentView.trailingAnchor).active = true
        
        mainImageView.layer.borderWidth = 2.0
        mainImageView.layer.borderColor = UIColor.redColor().CGColor
        mainImageView.contentMode = .ScaleAspectFit
        mainImageView.image = UIImage(named: "placeholder")
        imageView?.image = UIImage(named: "placeholder")
        
    }
    
//    -(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    for (NSIndexPath *indexPath in [self.tableView indexPathsForVisibleRows]) {
//    [self loadImageForCellAtPath:indexPath];
//    }
//    }
    

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupCell()
        
    }

    
    override func awakeFromNib() {
        setupCell()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let donwloadInCell = false
    
    
    let downloadHelper = DownloadHelper()
    var cache = [String:UIImage]()
    func generateURLS(count:Int){
        for _ in 0...count {
            let image = "http://dummyimage.com/100/\(arc4random() % 0xFFFFFF)/\(arc4random() % 0xFFFFFF)"
            items.append(image)
        }
    }
    
    var items = [String]()
    let tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        generateURLS(50)
        view.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        tableView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 44.0;
        
        
        tableView.registerClass(CustomCell.self, forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
        
        
    
}

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !donwloadInCell
        {
            loadVisible()
        }
       

    }
    
    
    /**If we want to display only the cells when we end up scrolling*/
    func loadVisible(){
        tableView.visibleCells
        if let visible = tableView.indexPathsForVisibleRows{
            
            for index in visible{
                if self.cache[self.items[index.row]] != nil {
                    continue
                }
                
                downloadHelper.betterDownload(items[index.row], index: index, callback:{
                     (image, index) in
                        //get cell 
                    if let cell = self.tableView.cellForRowAtIndexPath(index) as? CustomCell{
                        cell.imageView?.image = image
                        cell.mainImageView.image = image
                        self.cache[self.items[index.row]] = image
                        self.tableView.reloadRowsAtIndexPaths([index], withRowAnimation: .Automatic)
                    }
                }
            )}
        }
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        //load visible
        loadVisible()
    }
 
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CustomCell
        //downloadHelper.dumbDownload(items[indexPath.row], cell: cell, index: indexPath)
       // cell.imageView?.image = nil
       // cell.mainImageView.image = nil
        
        
        if let image = cache[items[indexPath.row]]{
            cell.mainImageView.image = image
            cell.imageView?.image = image
        }
        else{
            cell.mainImageView.image = UIImage(named: "placeholder")
            cell.imageView?.image = UIImage(named: "placeholder")

            
           // cell.mainImageView.image = nil //NilLiteralConvertible
           // cell.imageView?.image = nil
          //  print("table view background \(items[indexPath.row]) \(indexPath)")
            if donwloadInCell{
            downloadHelper.betterDownload(items[indexPath.row], index: indexPath, callback:{
                (image, index) in
                self.cache[self.items[index.row]] = image
                cell.mainImageView.image = image
                cell.imageView?.image = image
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                cell.contentView.layoutSubviews()
                
            } )
            }
        
        }
        
//        cell.contentView.layoutSubviews()
        
      //  cell.contentView.setNeedsLayout(); // autolayout bug solution
      //  cell.contentView.layoutIfNeeded(); // autolayout bug solution

        return cell
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class DownloadHelper {
    let queue:dispatch_queue_t  = dispatch_queue_create("My Queue",nil);
    
    func dumbDownload(urlString:String , cell:CustomCell, index:NSIndexPath ){
        if let url = NSURL(string: urlString)
        {
            if let data = NSData(contentsOfURL: url)
            {   let image = UIImage(data: data)
                cell.mainImageView.image = image
                cell.imageView!.image = image
               

            }
        }
    }
    
    func betterDownload(urlString:String , index:NSIndexPath, callback:((image:UIImage, indexPath:NSIndexPath) -> Void)){
        
        
        
        dispatch_async(queue) { () -> Void in
            if let url = NSURL(string: urlString)
            {
                if let data = NSData(contentsOfURL: url), image = UIImage(data: data)
                {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        callback(image: image, indexPath: index)
                        print("inside background \(urlString) \(index)")
                        
                    })
                }
            }
        }
    }
    
}


