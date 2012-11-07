//
//  MainViewController.m
//  GCDDemo
//
//  Created by willonboy zhang on 12-7-5.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//

#import "MainViewController.h"
    //#import "GCDAsyncDownloadImage.h"



@implementation myCell
@synthesize imgView = _imgView, imgUrl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _imgView = [[GCDImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 280)];
            [self addSubview:_imgView];
        });
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
        
    void (^failedCallBack)(void) = ^(void){NSLog(@"download image failed");};
    void (^successdCallBack)(void) = ^(void){NSLog(@"download image success");};
    
    [_imgView getImageWithUrl:self.imgUrl defaultImg:[UIImage imageNamed:@"splash_video_title_slide.png"] successBlock:successdCallBack failedBlock:failedCallBack];
    [self.imgView setHidden:NO];
    
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.imgView setHidden:YES];
}


- (void)dealloc 
{
    self.imgView = nil;
    self.imgUrl = nil;
    
    [super dealloc];
}
@end












@implementation MainViewController
@synthesize imgView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, 320, 440) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
//    
//        //Call GCDAsyncDownloadImage Download Image
//    void (^failedCallBack)(void) = ^(void){NSLog(@"download image failed");};
//    void (^successdCallBack)(void) = ^(void){NSLog(@"download image success");};
//    
//    [self.imgView getImageWithUrl:@"http://willonboy.tk/wp-content/uploads/2012/02/6_84890_774c49d3192b9cc.png?aadfie" defaultImg:[UIImage imageNamed:@"splash_video_title_slide.png"] successBlock:successdCallBack failedBlock:failedCallBack];
//    
}



#pragma mark - 
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 200;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MainViewTableViewCell";
    myCell *cell = (myCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[[myCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
        
    NSString *imgUrlPrefix = nil;
    NSArray *arr = [NSArray arrayWithObjects:@"http://65555655.com/wp-content/themes/themia-lite/images/slideimg.jpg", 
                    @"http://willonboy.tk/wp-content/uploads/2012/02/6_84890_774c49d3192b9cc.png", 
                    @"http://65555655.com/wp-content/uploads/2012/07/yourQRcode-300x300.png",
                    @"http://cdn.ifanr.cn/wp-content/uploads/2012/07/Olympic.jpg",
                    @"http://cdn.ifanr.cn/wp-content/uploads/2012/07/Google-Fiber.jpg",
                    @"http://cdn.ifanr.cn/wp-content/uploads/2012/07/0DSC_9939.jpg",
                    @"http://cdn.ifanr.cn/wp-content/uploads/2012/07/Eye-Fi-Yuyal.jpg",
                    @"http://cdn.ifanr.cn/wp-content/uploads/2012/07/facebook1.jpg",
                    @"http://cdn.ifanr.cn/wp-content/uploads/2012/07/icloud_meitu_1.jpg",
                    @"http://65555655.com/wp-content/themes/themia-lite/images/featureimg-1.png",
                    nil];
    float a;
    a = rand() % 10;
    int index = a;//(int)a % 10;
    NSLog(@"index is %d, rand() %d", index, rand()); 
    imgUrlPrefix = [arr objectAtIndex:index];
    
    NSString *imgUrl = [NSString stringWithFormat:@"%@?%ld", imgUrlPrefix, random()];
    cell.imgUrl = imgUrl;
    
//        //这里只是示例, 让每次重用Cell都添加一次imgView
//    UIImageView *imgView_ = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 300, 280)];
//    
//        //Call GCDAsyncDownloadImage Download Image
//    void (^failedCallBack)(void) = ^(void){NSLog(@"download image failed");};
//    void (^successdCallBack)(void) = ^(void){NSLog(@"download image success");};
//
//    [imgView_ getImageWithUrl:imgUrl defaultImg:[UIImage imageNamed:@"splash_video_title_slide.png"] successBlock:successdCallBack failedBlock:failedCallBack];
//    
//    [cell addSubview:imgView_];
//    [imgView_ release];
    
    return cell;
}


@end
