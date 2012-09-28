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
    
    if (!urlString || urlString.length < 1) 
    {
        return;
    }
    
    if (defaultImg)
    {
        self.image = defaultImg;
    }
    
    NSString *imageFilePath = [self getCacheFile:[self MD5Value:urlString]];
    UIImage *cachedImg = [[[UIImage alloc] initWithContentsOfFile:imageFilePath] autorelease];
    
    if (cachedImg)
    {
        self.image = cachedImg;
        
        if (successBlock != NULL) 
        {
            successBlock();
        }
    }
    else
    {
        __block UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicatorView.center = self.center;
        [self addSubview:indicatorView];
        [indicatorView startAnimating];
        
            //避免retain self
        __block UIImageView *selfImgView = self;
        
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
                if (selfImgView)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        selfImgView.image = img;
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


+ (void)cancelDownload;
{
    GCDAsyncDownloadImageCancel = YES;
}

@end










