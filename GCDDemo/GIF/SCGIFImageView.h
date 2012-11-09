//
//  SCGIFImageView.h
//  TestGIF
//
//  Created by shichangone on 11-7-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 USE LIKE 
 SCGIFImageView* gifImageView = [[[SCGIFImageView alloc] initWithGIFFile:filePath] autorelease];
 
 OR
 
 SCGIFImageView* _imgView = [[SCGIFImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 280)];
 void (^failedCallBack)(void) = ^(void){NSLog(@"download image failed");};
 void (^successdCallBack)(void) = ^(void){NSLog(@"download image success");};
 
 [_imgView getImageWithUrl:self.imgUrl defaultImg:[UIImage imageNamed:@"splash_video_title_slide.png"] successBlock:successdCallBack failedBlock:failedCallBack];

 
 
 待修复Bug:
 1. 当UIImageView被密集重用时(如GifDemoViewController中的GifCell用法 UIImageView始终于GifCell一起被重用),会出现图片不停切换(当然也不重用UIImageView即不会出现该问题)
 2. 当整个UITableView中全部都是GIF图片并且不停的滚屏加载GIF会使用CPU和内存短期内持续上升, 最终Crash  (后期如果能实现,将会缓存解析过后的GIF图片元数据(帧图片及Frame信息和时间信息) )
 
*/
 
#import <UIKit/UIKit.h>

@interface AnimatedGifFrame : NSObject
{
	NSData *data;
	NSData *header;
	double delay;
	int disposalMethod;
	CGRect area;
}

@property (nonatomic, copy) NSData *header;
@property (nonatomic, copy) NSData *data;
@property (nonatomic) double delay;
@property (nonatomic) int disposalMethod;
@property (nonatomic) CGRect area;

@end














@interface SCGIFImageView : UIImageView
{
	NSData *GIF_pointer;
	NSMutableData *GIF_buffer;
	NSMutableData *GIF_screen;
	NSMutableData *GIF_global;
	NSMutableArray *GIF_frames;
	
	int GIF_sorted;
	int GIF_colorS;
	int GIF_colorC;
	int GIF_colorF;
	int animatedGifDelay;
	
	int dataPointer;
    
        //add by william 2012-11-8
        //防止陷入 retain Cycle
    __block NSString                *_currentDownloadingImgFilePath;
    __block UIActivityIndicatorView *indicatorView ;
    dispatch_queue_t                readCacheFileQueue;
    dispatch_queue_t                animateDisplayGifQueue;
    
        //当前正在解析的gif图片路径, 用于区别正在下载的git图片路径(在密集重用时当前正在解析的图片不一定是需要显示的图片, 有可能造成图片乱跳, 该值与_currentDownloadingImgFilePath对比以修复该bug)
    NSString                        *_showDisplayGifFilePath;
}
@property (nonatomic, retain) NSMutableArray *GIF_frames;

- (id)initWithGIFFile:(NSString*)gifFilePath;
- (id)initWithGIFData:(NSData*)gifImageData;

- (void)loadImageData;

+ (NSMutableArray*)getGifFrames:(NSData*)gifImageData;
+ (BOOL)isGifImage:(NSData*)imageData;

- (void) decodeGIF:(NSData *)GIFData;
- (void) GIFReadExtensions;
- (void) GIFReadDescriptor;
- (bool) GIFGetBytes:(int)length;
- (bool) GIFSkipBytes: (int) length;
- (NSData*) getFrameAsDataAtIndex:(int)index;
- (UIImage*) getFrameAsImageAtIndex:(int)index;


    //add by william 2012-11-8
- (id)initWithImageWithUrl:(CGRect)frame imgUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg;

    //add by william 2012-11-8
- (id)initWithImageWithUrl:(CGRect)frame imgUrl:(NSString *)urlString successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;

    //add by william 2012-11-8
- (void)getImageWithUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;

    //add by william 2012-11-8
+ (void)cancelDownload;


@end








