//
//  MainViewController.h
//  GCDDemo
//
//  Created by willonboy zhang on 12-7-5.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDImageView.h"

@interface myCell : UITableViewCell
{
    GCDImageView    *_imgView;
}
@property(nonatomic, retain)GCDImageView    *imgView;
@property(nonatomic, retain)NSString        *imgUrl;

@end




@interface MainViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    UITableView         *_tableView;
}

@property(nonatomic, retain) IBOutlet UIImageView *imgView;

@end
