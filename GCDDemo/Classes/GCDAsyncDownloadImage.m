//
//  GCDAsynDownload.m
//  GCDDemo
//
//  Created by willonboy zhang on 12-7-5.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//

#import "GCDAsyncDownloadImage.h"
#import <CommonCrypto/CommonDigest.h>

@implementation UIImageView(GCDImgViewExt)
static  BOOL GCDAsyncDownloadImageCancel = NO;

static NSCache *_memCache = nil;

+ (void)initialize
{
    if (self == [UIImageView class]) {
        
        _memCache = [NSCache new];
    }
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


- (void)getImageWithUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg;
{
    [self getImageWithUrl:urlString defaultImg:defaultImg successBlock:NULL failedBlock:NULL];
}


- (void)getImageWithUrl:(NSString *)urlString successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;
{
     [self getImageWithUrl:urlString defaultImg:NULL successBlock:successBlock failedBlock:failedBlock];
}


- (void)getImageWithUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    self.image = defaultImg;
    if (!urlString || urlString.length < 1)
    {
            //嵌套的block会被copy
        if (failedBlock != NULL)
        {
            dispatch_async(dispatch_get_main_queue(), failedBlock);
        }
        
        [pool drain];
        return;
    }
    
    NSString *imageFilePath = [self getCacheFile:[self MD5Value:urlString]];
        //本地图片
    if ([urlString hasPrefix:@"/var/mobile/"] || [urlString hasPrefix:@"/Users/"])
    {
        imageFilePath = urlString;
    }
    UIImage *cachedImg = [_memCache objectForKey:imageFilePath];
    
    if (!cachedImg)
    {
        cachedImg = [[[UIImage alloc] initWithContentsOfFile:imageFilePath] autorelease];
    }
    
        //读取缓存时不加风火轮
    if (cachedImg)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.4 animations:^{self.alpha = 0.0f;} completion:^(BOOL finished){
                
                self.image = cachedImg;
                [UIView animateWithDuration:0.4 animations:^{
                    
                    self.alpha = 1.0f;
                }];
            }];
            
            if (successBlock != NULL)
            {
                successBlock();
            }
        });
    }
    else
    {
        for (UIView *view in self.subviews)
        {
            if ([view isKindOfClass:[UIActivityIndicatorView class]])
            {
                [view removeFromSuperview];
            }
        }
        
        __block UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        [self addSubview:indicatorView];
        [indicatorView startAnimating];
        
            //避免retain self
        __block UIImageView *_self = self;
            //主要是用于区别多次重用的UIImageView(如果UIImageView频繁重用请在重用时重新设置tag属性值)
        long imageViewTag = self.tag;
        
        dispatch_queue_t downloadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        void (^downloadBlock)(void) = ^(void){
            
            if (GCDAsyncDownloadImageCancel) 
            {
                NSLog(@"Download Canceled");
                return;
            }
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
                 
            dispatch_async(dispatch_get_main_queue(), ^{
                    //下载结束 停止风火轮
                [indicatorView removeFromSuperview];
                [indicatorView stopAnimating];
                [indicatorView release];
                indicatorView = nil;
            });
            
            UIImage *img = [UIImage imageWithData:imageData];
            if (imageData && img)
            { 
                [imageData writeToFile:imageFilePath atomically:YES];
                if (_self && _self.tag == imageViewTag)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [UIView animateWithDuration:0.4 animations:^{_self.alpha = 0.0f;} completion:^(BOOL finished){
                            
                            _self.image = img;
                            [UIView animateWithDuration:0.4 animations:^{
                                
                                _self.alpha = 1.0f;
                            }];
                        }];
                        
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


- (UIImage *)loadCacheImg:(NSString *)imgUrl defaultImg:(UIImage *)defaultImg;
{
    if (imgUrl.length < 1)
    {
        return defaultImg;
    }
    
    NSString *imageFilePath = [NSString stringWithFormat:@"%@/Library/Caches/%@", NSHomeDirectory(),[self MD5Value:imgUrl]];
    UIImage *img = [_memCache objectForKey:imageFilePath];
    if (!img)
    {
        NSData *cacheImgData = [NSData dataWithContentsOfFile:imageFilePath options:NSDataReadingMappedIfSafe error:nil];
            //读取缓存时不加风火轮
        if (cacheImgData)
        {
            img = [UIImage imageWithData:cacheImgData];
            [_memCache setObject:img forKey:imageFilePath];
        }
    }
    
    return !img ? defaultImg : img;
}

- (NSString *)loadCacheImgPath:(NSString *)imgUrl;
{
    if (imgUrl.length < 1)
    {
        return nil;
    }
    
    NSString *imageFilePath = [NSString stringWithFormat:@"%@/Library/Caches/%@", NSHomeDirectory(),[self MD5Value:imgUrl]];
    
    return imageFilePath;
}

@end










