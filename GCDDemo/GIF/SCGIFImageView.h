//
//  SCGIFImageView.h
//  TestGIF
//
//  Created by shichangone on 11-7-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*
 USE LIKE 
 SCGIFImageView* gifImageView = [[[SCGIFImageView alloc] initWithGIFDataOrGifPath:nil gifFilePath:filePath] autorelease];
 
 OR
 
 SCGIFImageView* _imgView = [[SCGIFImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 280)];
 void (^failedCallBack)(void) = ^(void){NSLog(@"download image failed");};
 void (^successdCallBack)(void) = ^(void){NSLog(@"download image success");};
 
 [_imgView getImageWithUrl:self.imgUrl defaultImg:[UIImage imageNamed:@"splash_video_title_slide.png"] successBlock:successdCallBack failedBlock:failedCallBack];
 
 
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
    
    Class       selfClass;
}

+ (BOOL) isGifImage:(NSData*)imageData;
- (id) initWithGIFDataOrGifPath:(NSData*)gifImageData gifFilePath:(NSString*)gifFilePath;



    //add by william 2012-11-8
- (id)initWithImageWithUrl:(CGRect)frame imgUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg;

    //add by william 2012-11-8
- (id)initWithImageWithUrl:(CGRect)frame imgUrl:(NSString *)urlString successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;

    //add by william 2012-11-8
- (void)getImageWithUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;

    //add by william 2012-11-8
+ (void)cancelDownload;

+ (void)initGCDAsyncDownloadFlag;

+ (UIImage *)loadCacheImg:(NSString *)imgUrl defaultImg:(UIImage *)defaultImg;

+ (NSString *)loadCacheImgPath:(NSString *)imgUrl;

@end








