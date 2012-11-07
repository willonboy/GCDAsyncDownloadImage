//
//  GifDemoViewController.m
//  GCDDemo
//
//  Created by zhangtao on 12-11-7.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//

#import "GifDemoViewController.h"


@implementation GifCell
@synthesize imgView = _imgView, imgUrl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _imgView = [[SCGIFImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 280)];
            [self addSubview:_imgView];
        });
    }
    
    return self;
}

- (void)layoutSubviews
{
    static long imageTag = 1000000;
    [super layoutSubviews];
    
        //self.imgView.image = nil;
    _imgView.tag = imageTag++;
    
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







@interface GifDemoViewController ()

@end



@implementation GifDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, 320, 440) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
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
    GifCell *cell = (GifCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[[GifCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    }
    
    NSString *imgUrlPrefix = nil;
    NSArray *arr = [NSArray arrayWithObjects:@"http://65555655.com/wp-content/themes/themia-lite/images/slideimg.jpg",
                    @"http://willonboy.tk/wp-content/uploads/2012/02/6_84890_774c49d3192b9cc.png",
                    @"http://pic.962.net/up/2012-10/2012102210273688752.gif",
                    @"http://s1.dwstatic.com/group1/M00/61/B1/faa8a80c1af8d64e972cabc5e07497be.gif",
                    @"http://imgsrc.baidu.com/forum/pic/item/0ff41bd5ad6eddc4c8aebfb839dbb6fd52663323.gif",
                    @"http://static.7ta.cn/7ta/userfiles/vaews/photo/201204031052541.gif",
                    @"http://static.7ta.cn/7ta/userfiles/vaews/photo/201204031102471.gif",
                    @"http://s1.dwstatic.com/group1/M00/DB/EF/f9227ce4616661689401af63e2590d13.gif",
                    @"http://s1.dwstatic.com/group1/M00/BA/7F/ba6d774242e427e57309f8e324424d03.gif",//
                    @"http://hiphotos.baidu.com/michael%25D8%25BC%25BF%25A1%25BA%25D3/pic/item/b8bb02d1dfbcac90a044df12.gif",
                    nil];
    float a;
    a = rand() % 10;
    int index = a;
    NSLog(@"index is %d, rand() %d", index, rand());
    imgUrlPrefix = [arr objectAtIndex:index];
    
    NSString *imgUrl = [NSString stringWithFormat:@"%@?%ld", imgUrlPrefix, random()];
    cell.imgUrl = imgUrl;
    
    return cell;
}


@end

