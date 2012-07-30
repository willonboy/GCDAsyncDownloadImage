//
//  GCDImageView.m
//  GCDDemo
//
//  Created by willonboy zhang on 12-7-30.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//

#import "GCDImageView.h"
#import <CommonCrypto/CommonDigest.h>


@implementation GCDImageView
static  BOOL GCDAsyncDownloadImageCancel = NO;


- (void)dealloc 
{
    if (_currentDownloadingImgFilePath)
    {
        [_currentDownloadingImgFilePath release];
        _currentDownloadingImgFilePath = nil;
    }

    [super dealloc];
}

    //对要请求的图片路径进行MD5签名
- (NSString *)MD5Value:(NSString *)str
{
	if (str==nil) 
    {
		return nil;
	}
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), result );
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

    //获取Caches目录下的文件
- (NSString *)getCacheFile:(NSString *)file
{
	return [NSString stringWithFormat:@"%@/Library/Caches/%@", NSHomeDirectory(),file];
}


- (id)initWithImageWithUrl:(CGRect)frame imgUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self getImageWithUrl:urlString defaultImg:defaultImg successBlock:NULL failedBlock:NULL];
    }
    
    return self;
}


- (id)initWithImageWithUrl:(CGRect)frame imgUrl:(NSString *)urlString successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self getImageWithUrl:urlString defaultImg:NULL successBlock:successBlock failedBlock:failedBlock];
    }
    
    return self;
}


    //函数中完善self被密集重用时导致图片加载后显示错乱
- (void)getImageWithUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if (!urlString || urlString.length < 1) 
    {
        return;
    }
    
    if (defaultImg)
    {
        self.image = defaultImg;
    }
    
        //important 被block实例引用的__block对象不自动增加引用次数 需手动增加引用计数 但像参数urlString是全局的非__block的Objective-C对象就会自动增加引用次数
    __block NSString *imageFilePath = [[self getCacheFile:[self MD5Value:urlString]] retain];
    UIImage *cachedImg = [[[UIImage alloc] initWithContentsOfFile:imageFilePath] autorelease];
    _currentDownloadingImgFilePath = [imageFilePath copy];
    
    if (cachedImg)
    {
        [imageFilePath release];
        self.image = cachedImg;
        
        if (successBlock != NULL) 
        {
            NSLog(@"read cached img");
            dispatch_async(dispatch_get_main_queue(), successBlock); 
        }
    }
    else
    {
        
        __block UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.center = self.center;
        [self addSubview:indicatorView];
        [indicatorView startAnimating];
        
        
        dispatch_queue_t downloadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        void (^downloadBlock)(void) = ^(void){
            
            if (GCDAsyncDownloadImageCancel) 
            {
                NSLog(@"Download Canceled");
                return;
            }
            
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
            
                //下载结束 停止风火轮
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [indicatorView removeFromSuperview];
                [indicatorView stopAnimating];
                [indicatorView release];
                indicatorView = nil;
            });

            if (img) 
            { 
                [UIImagePNGRepresentation(img) writeToFile:imageFilePath atomically:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!_currentDownloadingImgFilePath || [_currentDownloadingImgFilePath isEqualToString:imageFilePath]) 
                    {
                        self.image = img;
                    }
                    else
                    {
                        NSLog(@"currentDownloadingImgFilePath %@, imageFilePath %@", _currentDownloadingImgFilePath, imageFilePath);
                    }
                });
                
                if (successBlock != NULL) 
                {
                    dispatch_async(dispatch_get_main_queue(), successBlock); 
                }
            }
            else
            {              
                if (failedBlock != NULL) 
                {
                    dispatch_async(dispatch_get_main_queue(), failedBlock); 
                }
            }
            
            [imageFilePath release];
        };
        
        dispatch_async(downloadQueue, downloadBlock);
        
        [pool drain];
        pool = nil;
    }
}


+ (void)cancelDownload;
{
    GCDAsyncDownloadImageCancel = YES;
}

@end

