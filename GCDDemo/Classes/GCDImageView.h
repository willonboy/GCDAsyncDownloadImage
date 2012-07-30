//
//  GCDImageView.h
//  GCDDemo
//
//  Created by willonboy zhang on 12-7-30.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GCDImageView : UIImageView
{
    NSString    *_currentDownloadingImgFilePath;
}


- (id)initWithImageWithUrl:(CGRect)frame imgUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg;

- (id)initWithImageWithUrll:(CGRect)frame imgUrl:(NSString *)urlString successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;

- (void)getImageWithUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;

+ (void)cancelDownload;



@end
