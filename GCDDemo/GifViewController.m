//
//  GifViewController.m
//  GCDDemo
//
//  Created by zhangtao on 12-11-7.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//

#import "GifViewController.h"
#import "SCGIFImageView.h"

@interface GifViewController ()

@end

@implementation GifViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    SCGIFImageView *img = [[SCGIFImageView alloc] initWithImageWithUrl:CGRectMake(0, 0, 320, 480) imgUrl:@"http://s1.dwstatic.com/group1/M00/BA/7F/ba6d774242e427e57309f8e324424d03.gif" defaultImg:nil];
    [self.view addSubview:img];
    [img release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
