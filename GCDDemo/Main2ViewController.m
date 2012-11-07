//
//  Main2ViewController.m
//  GCDDemo
//
//  Created by zhangtao on 12-11-6.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//

#import "Main2ViewController.h"



@implementation my2Cell
@synthesize imgView = _imgView, imgUrl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 280)];
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







@interface Main2ViewController ()

@end



@implementation Main2ViewController

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
    my2Cell *cell = (my2Cell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[[my2Cell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
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
    int index = a;
    NSLog(@"index is %d, rand() %d", index, rand());
    imgUrlPrefix = [arr objectAtIndex:index];
    
    NSString *imgUrl = [NSString stringWithFormat:@"%@?%ld", imgUrlPrefix, random()];
    cell.imgUrl = imgUrl;
    
    return cell;
}


@end
