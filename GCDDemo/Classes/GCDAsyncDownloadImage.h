//
//  GCDAsynDownload.h
//  GCDDemo
//
//  Created by willonboy zhang on 12-7-5.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//


/*******
 引用方式
 
 void (^failedCallBack)(void) = ^(void){NSLog(@"download dailydish image failed");};
 void (^successdCallBack)(void) = ^(void){NSLog(@"download dailydish image success");};
 
 [self.imgView getImageWithUrl:@"http://dailydish.typepad.com/.a/6a00d83451c45669e2016768168795970b-800wi" defaultImg:[UIImage imageNamed:@"xxx.png"] successBlock:successdCallBack failedBlock:failedCallBack];
 
 ******/

#ifndef __IPHONE_4_0
#warning "This project uses features only available in iOS SDK 4.0 and later."
#endif

#import <Foundation/Foundation.h>

@interface UIImageView(GCDImgViewExt)

- (void)getImageWithUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg;

- (void)getImageWithUrl:(NSString *)urlString successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;

- (void)getImageWithUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;

+ (void)cancelDownload;

+ (void)initGCDAsyncDownloadFlag;

@end
