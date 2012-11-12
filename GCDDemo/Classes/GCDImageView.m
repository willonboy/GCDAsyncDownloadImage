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

Class object_getClass(id object);

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
        [pool drain];
        return;
    }
    
    self.image = defaultImg;
    
    NSString *imageFilePath = [self getCacheFile:[self MD5Value:urlString]];
    UIImage *cachedImg = [[[UIImage alloc] initWithContentsOfFile:imageFilePath] autorelease];
    
        //读取缓存时不加风火轮
    if (cachedImg)
    {
        self.image = cachedImg;
        
        if (successBlock != NULL) 
        {
            NSLog(@"read cached img");
            successBlock();
        }
    }
    else
    {
        if (_currentDownloadingImgFilePath)
        {
            [_currentDownloadingImgFilePath release];
            _currentDownloadingImgFilePath = nil;
        }
        _currentDownloadingImgFilePath = [imageFilePath copy];
        
        if (!indicatorView) 
        {
            indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicatorView.center = self.center;
            [self addSubview:indicatorView];
            [indicatorView startAnimating];
        }
        
            //避免retain self
        __block UIImageView *selfImgView = self;
        
        dispatch_queue_t downloadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        void (^downloadBlock)(void) = ^(void){
            
            NSString *blockUseCurrentDownloadingImgPath = [imageFilePath copy];
            
            if (GCDAsyncDownloadImageCancel) 
            {
                [blockUseCurrentDownloadingImgPath release];
                NSLog(@"Download Canceled");
                return;
            }
            
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                    //下载结束 停止风火轮
                [indicatorView removeFromSuperview];
                [indicatorView stopAnimating];
                [indicatorView release];
                indicatorView = nil;
            });
            
            if (img) 
            { 
                [UIImagePNGRepresentation(img) writeToFile:imageFilePath atomically:YES];
                
                NSLog(@"currentDownloadingImgFilePath %@, imageFilePath %@", blockUseCurrentDownloadingImgPath, _currentDownloadingImgFilePath);
                    //当UIImageView被重用时,_currentDownloadingImgFilePath将会被重新赋值并且在block有体显(值发生改变),但blockUseCurrentDownloadingImgPath是block变量,它一直不变
                    //所以用此来判断是否被重用了,下载的图是否是当前重用时要下载的图
                if (!_currentDownloadingImgFilePath || [_currentDownloadingImgFilePath isEqualToString:blockUseCurrentDownloadingImgPath]) 
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (selfImgView && selfClass == object_getClass(selfImgView))
                        {
                            [UIView animateWithDuration:0.4 animations:^{selfImgView.alpha = 0.0f;} completion:^(BOOL finished){
                                
                                selfImgView.image = img;
                                [UIView animateWithDuration:0.4 animations:^{
                                    
                                    selfImgView.alpha = 1.0f;
                                }];
                            }];
                        }
                        else
                        {
                            NSLog(@"imgview released");
                        }
                    });
                }                
                    //嵌套的block会被copy
                if (successBlock != NULL) 
                {
                    dispatch_async(dispatch_get_main_queue(), successBlock); 
                }
            }
            else
            {       
                    //嵌套的block会被copy       
                if (failedBlock != NULL) 
                {
                    dispatch_async(dispatch_get_main_queue(), failedBlock); 
                }
            }
            
            [blockUseCurrentDownloadingImgPath release];
        };
            //开始下载
        dispatch_async(downloadQueue, downloadBlock);
    }
    
    [pool drain];
    pool = nil;
}


    //add by william 2012-11-7
+ (void)initGCDAsyncDownloadFlag;
{
    GCDAsyncDownloadImageCancel = NO;
}

+ (void)cancelDownload;
{
    GCDAsyncDownloadImageCancel = YES;
}

@end

