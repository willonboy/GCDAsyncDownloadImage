//
//  GCDImageView.h
//  GCDDemo
//
//  Created by willonboy zhang on 12-7-30.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//


/*
 引用方式:
 #import "GCDImageView.h"
 
 GCDImageView    *_imgView = [[GCDImageView alloc] initWithFrame:CGRectMake(10, 10, 300, 280)];
 void (^failedCallBack)(void) = ^(void){NSLog(@"download image failed");};
 void (^successdCallBack)(void)  = ^(void){NSLog(@"download image success");};
 [_imgView getImageWithUrl:self.imgUrl defaultImg:[UIImage imageNamed:@"default.png"] successBlock:successdCallBack failedBlock:failedCallBack];
 
 */




#import <UIKit/UIKit.h>

@interface GCDImageView : UIImageView
{
        //防止陷入 retain Cycle
    __block NSString    *_currentDownloadingImgFilePath;
}


- (id)initWithImageWithUrl:(CGRect)frame imgUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg;

- (id)initWithImageWithUrl:(CGRect)frame imgUrl:(NSString *)urlString successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;

- (void)getImageWithUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;

+ (void)cancelDownload;



@end
