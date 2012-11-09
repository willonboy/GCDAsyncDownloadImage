//
//  GifDemoViewController.h
//  GCDDemo
//
//  Created by zhangtao on 12-11-7.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCGIFImageView.h"

@interface GifCell : UITableViewCell
{
    SCGIFImageView    *_imgView;
}
@property(nonatomic, retain)SCGIFImageView *imgView;
@property(nonatomic, retain)NSString       *imgUrl;

- (void)startLoadGif;

@end




@interface GifDemoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    UITableView         *_tableView;
}

@end