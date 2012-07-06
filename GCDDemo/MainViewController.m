//
//  MainViewController.m
//  GCDDemo
//
//  Created by willonboy zhang on 12-7-5.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//

#import "MainViewController.h"
#import "GCDAsyncDownloadImage.h"

@implementation MainViewController
@synthesize imgView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        //Call GCDAsyncDownloadImage Download Image
    void (^failedCallBack)(void) = ^(void){NSLog(@"download image failed");};
    void (^successdCallBack)(void) = ^(void){NSLog(@"download image success");};
    
    [self.imgView getImageWithUrl:@"http://willonboy.tk/wp-content/uploads/2012/02/6_84890_774c49d3192b9cc.png" defaultImg:[UIImage imageNamed:@"splash_video_title_slide.png"] successBlock:successdCallBack failedBlock:failedCallBack];
    
}

@end
