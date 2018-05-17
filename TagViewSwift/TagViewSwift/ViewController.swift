//
//  ViewController.swift
//  TagViewSwift
//
//  Created by snowlu on 2017/8/22.
//  Copyright © 2017年 LittleShrimp. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,TagViewDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tagView = ZLTagView.init(frame: CGRect.init(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 400));
        
        self.view .addSubview(tagView);
        
        tagView.tags = ["42","kfahk","9809","9999","hhd发水电费；卡世纪东方；埃里克森减肥；国营临海农场；田中芳树是；hdh"];
        
        tagView.delegate = self;
        tagView.longPressMove = true;

        tagView.addTag("88");
        
        tagView.addTagAtIndex("77", 2);
        
        tagView.removeWithIndex(2);
        
        tagView.tagHeight = 44;
       
        
         
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

