//
//  Main2ViewController.h
//  GCDDemo
//
//  Created by zhangtao on 12-11-6.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncDownloadImage.h"


@interface my2Cell : UITableViewCell
{
    UIImageView    *_imgView;
}
@property(nonatomic, retain)UIImageView    *imgView;
@property(nonatomic, retain)NSString       *imgUrl;

@end




@interface Main2ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    UITableView         *_tableView;
}

@end