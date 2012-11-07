//
//  SCGIFImageView.m
//  TestGIF
//
//  Created by shichangone on 11-7-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SCGIFImageView.h"

@implementation AnimatedGifFrame

@synthesize data, delay, disposalMethod, area, header;

- (void) dealloc
{
	[data release];
	[header release];
	[super dealloc];
}

@end

@implementation SCGIFImageView
@synthesize GIF_frames;

    //add by william 2012-11-7
static  BOOL GCDAsyncDownloadImageCancel = NO;

- (void)initAnimateDisplayGifDispathQueue
{
    if (!animateDisplayGifQueue)
    {
        animateDisplayGifQueue = dispatch_queue_create("www.willonboy.tk.animateDisplayGifQueue", 0);
    }
}

    //add by william 2012-11-7
- (id)init
{
    self = [super init];
    if (self)
    {
        [self initAnimateDisplayGifDispathQueue];
    }
    return self;
}

    //add by william 2012-11-7
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initAnimateDisplayGifDispathQueue];
    }
    return self;
}

    //add by william 2012-11-7
- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self)
    {
        [self initAnimateDisplayGifDispathQueue];
    }
    return self;
}

    //add by william 2012-11-7
- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    if (self)
    {
        [self initAnimateDisplayGifDispathQueue];
    }
    return self;
}

+ (BOOL)isGifImage:(NSData*)imageData
{
	const char* buf = (const char*)[imageData bytes];
	if (buf[0] == 0x47 && buf[1] == 0x49 && buf[2] == 0x46 && buf[3] == 0x38)
    {
		return YES;
	}
	return NO;
}

+ (NSMutableArray*)getGifFrames:(NSData*)gifImageData
{
	SCGIFImageView* gifImageView = [[SCGIFImageView alloc] initWithGIFData:gifImageData];
	if (!gifImageView)
    {
		return nil;
	}
	
	NSMutableArray* gifFrames = gifImageView.GIF_frames;
	[[gifFrames retain] autorelease];
	[gifImageView release];
	return gifFrames;
}

- (id)initWithGIFFile:(NSString*)gifFilePath
{
	NSData* imageData = [NSData dataWithContentsOfFile:gifFilePath];
	return [self initWithGIFData:imageData];
}

    //changed by william 2012-11-7
- (id)initWithGIFData:(NSData*)gifImageData
{
    if (gifImageData.length < 4)
    {
        return nil;
    }
    
    if (![SCGIFImageView isGifImage:gifImageData])
    {
        UIImage* image = [UIImage imageWithData:gifImageData];
        return [super initWithImage:image];
    }
    
	self = [super init];
	if (self)
    {
        [self initAnimateDisplayGifDispathQueue];
        
        [self decodeGIF:gifImageData];
        
        if (GIF_frames.count <= 0)
        {
            UIImage* image = [UIImage imageWithData:gifImageData];
            return [super initWithImage:image];
        }
        
        [self loadImageData];
	}
	
	return self;
}

    //add by william 2012-11-7
- (void)loadImageByImageData:(NSData *)gifImageData
{
    if (gifImageData.length < 4)
    {
        return;
    }
    
    if (![SCGIFImageView isGifImage:gifImageData])
    {
        UIImage* image = [UIImage imageWithData:gifImageData];
        self.image = image;
        return;
    }
    
    [self decodeGIF:gifImageData];
    
    if (GIF_frames.count <= 0)
    {
        UIImage* image = [UIImage imageWithData:gifImageData];
        self.image = image;
        return;
    }
    
    [self loadImageData];
    
}

- (void)setGIF_frames:(NSMutableArray *)gifFrames
{
	[gifFrames retain];
	
	if (GIF_frames)
    {
		[GIF_frames release];
	}
	GIF_frames = gifFrames;
	
    [self loadImageData];
}

- (void)loadImageData
{
	// Add all subframes to the animation
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (NSUInteger i = 0; i < [GIF_frames count]; i++)
	{
            //changed by william 2012-11-7
            //[array addObject: [self getFrameAsImageAtIndex:i]];
        if ([self getFrameAsImageAtIndex:i])
        {
            [array addObject: [self getFrameAsImageAtIndex:i]];
        }
        
	}
        //add by william 2012-11-7
    if ([array count] < 1)
    {
        return;
    }
	
	NSMutableArray *overlayArray = [[NSMutableArray alloc] init];
	UIImage *firstImage = [array objectAtIndex:0];
	CGSize size = firstImage.size;
	CGRect rect = CGRectZero;
	rect.size = size;
	
	UIGraphicsBeginImageContext(size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	int i = 0;
	AnimatedGifFrame *lastFrame = nil;
	for (UIImage *image in array)
	{
		// Get Frame
		AnimatedGifFrame *frame = [GIF_frames objectAtIndex:i];
		
		// Initialize Flag
		UIImage *previousCanvas = nil;
		
		// Save Context
		CGContextSaveGState(ctx);
		// Change CTM
		CGContextScaleCTM(ctx, 1.0, -1.0);
		CGContextTranslateCTM(ctx, 0.0, -size.height);
		
		// Check if lastFrame exists
		CGRect clipRect;
		
		// Disposal Method (Operations before draw frame)
		switch (frame.disposalMethod)
		{
			case 1: // Do not dispose (draw over context)
                    // Create Rect (y inverted) to clipping
				clipRect = CGRectMake(frame.area.origin.x, size.height - frame.area.size.height - frame.area.origin.y, frame.area.size.width, frame.area.size.height);
				// Clip Context
				CGContextClipToRect(ctx, clipRect);
				break;
			case 2: // Restore to background the rect when the actual frame will go to be drawed
                    // Create Rect (y inverted) to clipping
				clipRect = CGRectMake(frame.area.origin.x, size.height - frame.area.size.height - frame.area.origin.y, frame.area.size.width, frame.area.size.height);
				// Clip Context
				CGContextClipToRect(ctx, clipRect);
				break;
			case 3: // Restore to Previous
                    // Get Canvas
				previousCanvas = UIGraphicsGetImageFromCurrentImageContext();
				
				// Create Rect (y inverted) to clipping
				clipRect = CGRectMake(frame.area.origin.x, size.height - frame.area.size.height - frame.area.origin.y, frame.area.size.width, frame.area.size.height);
				// Clip Context
				CGContextClipToRect(ctx, clipRect);
				break;
		}
		
		// Draw Actual Frame
		CGContextDrawImage(ctx, rect, image.CGImage);
		// Restore State
		CGContextRestoreGState(ctx);
		
		//delay must larger than 0, the minimum delay in firefox is 10.
		if (frame.delay <= 0)
        {
			frame.delay = 10;
		}
		[overlayArray addObject:UIGraphicsGetImageFromCurrentImageContext()];
		
		// Set Last Frame
		lastFrame = frame;
		
		// Disposal Method (Operations afte draw frame)
		switch (frame.disposalMethod)
		{
			case 2: // Restore to background color the zone of the actual frame
                    // Save Context
				CGContextSaveGState(ctx);
				// Change CTM
				CGContextScaleCTM(ctx, 1.0, -1.0);
				CGContextTranslateCTM(ctx, 0.0, -size.height);
				// Clear Context
				CGContextClearRect(ctx, clipRect);
				// Restore Context
				CGContextRestoreGState(ctx);
				break;
			case 3: // Restore to Previous Canvas
                    // Save Context
				CGContextSaveGState(ctx);
				// Change CTM
				CGContextScaleCTM(ctx, 1.0, -1.0);
				CGContextTranslateCTM(ctx, 0.0, -size.height);
				// Clear Context
				CGContextClearRect(ctx, lastFrame.area);
				// Draw previous frame
				CGContextDrawImage(ctx, rect, previousCanvas.CGImage);
				// Restore State
				CGContextRestoreGState(ctx);
				break;
		}
		
		// Increment counter
		i++;
	}
	UIGraphicsEndImageContext();
    
	[self setImage:[overlayArray objectAtIndex:0]];
    [self setAnimationImages:overlayArray];
    
    [overlayArray release];
    [array release];
    
        // Count up the total delay, since Cocoa doesn't do per frame delays.
    double total = 0;
    for (AnimatedGifFrame *frame in GIF_frames)
    {
        total += frame.delay;
    }
    
        // GIFs store the delays as 1/100th of a second,
        // UIImageViews want it in seconds.
    [self setAnimationDuration:total/100];
    
        // Repeat infinite
    [self setAnimationRepeatCount:0];
    
    [self startAnimating];
    
}

- (void)dealloc
{
    if (GIF_buffer != nil)
    {
	    [GIF_buffer release];
    }
    
    if (GIF_screen != nil)
    {
		[GIF_screen release];
    }
    
    if (GIF_global != nil)
    {
        [GIF_global release];
    }
    
	[GIF_frames release];
    
    dispatch_release(animateDisplayGifQueue);
	
	[super dealloc];
}
	 
- (void) decodeGIF:(NSData *)GIFData
{
	GIF_pointer = GIFData;
    
    if (GIF_buffer != nil)
    {
        [GIF_buffer release];
    }
    
    if (GIF_global != nil)
    {
        [GIF_global release];
    }
    
    if (GIF_screen != nil)
    {
        [GIF_screen release];
    }
    
	[GIF_frames release];
	
    GIF_buffer = [[NSMutableData alloc] init];
	GIF_global = [[NSMutableData alloc] init];
	GIF_screen = [[NSMutableData alloc] init];
	GIF_frames = [[NSMutableArray alloc] init];
	
    // Reset file counters to 0
	dataPointer = 0;
	
	[self GIFSkipBytes: 6]; // GIF89a, throw away
	[self GIFGetBytes: 7]; // Logical Screen Descriptor
	
    // Deep copy
	[GIF_screen setData: GIF_buffer];
	
    // Copy the read bytes into a local buffer on the stack
    // For easy byte access in the following lines.
    int length = [GIF_buffer length];
	unsigned char aBuffer[length];
	[GIF_buffer getBytes:aBuffer length:length];
	
	if (aBuffer[4] & 0x80) GIF_colorF = 1; else GIF_colorF = 0; 
	if (aBuffer[4] & 0x08) GIF_sorted = 1; else GIF_sorted = 0;
	GIF_colorC = (aBuffer[4] & 0x07);
	GIF_colorS = 2 << GIF_colorC;
	
	if (GIF_colorF == 1)
    {
		[self GIFGetBytes: (3 * GIF_colorS)];
        
        // Deep copy
		[GIF_global setData:GIF_buffer];
	}
	
	unsigned char bBuffer[1];
	while ([self GIFGetBytes:1] == YES)
    {
        [GIF_buffer getBytes:bBuffer length:1];
        
        if (bBuffer[0] == 0x3B)
        { // This is the end
            break;
        }
        
        switch (bBuffer[0])
        {
            case 0x21:
                // Graphic Control Extension (#n of n)
                [self GIFReadExtensions];
                break;
            case 0x2C:
                // Image Descriptor (#n of n)
                [self GIFReadDescriptor];
                break;
        }
	}
	
	// clean up stuff
	[GIF_buffer release];
    GIF_buffer = nil;
    
	[GIF_screen release];
    GIF_screen = nil;
    
	[GIF_global release];	
    GIF_global = nil;
}

- (void) GIFReadExtensions
{
	// 21! But we still could have an Application Extension,
	// so we want to check for the full signature.
	unsigned char cur[1], prev[1];
    [self GIFGetBytes:1];
    [GIF_buffer getBytes:cur length:1];
    
	while (cur[0] != 0x00)
    {
		
		// TODO: Known bug, the sequence F9 04 could occur in the Application Extension, we
		//       should check whether this combo follows directly after the 21.
		if (cur[0] == 0x04 && prev[0] == 0xF9)
		{
			[self GIFGetBytes:5];
            
			AnimatedGifFrame *frame = [[AnimatedGifFrame alloc] init];
			
			unsigned char buffer[5];
			[GIF_buffer getBytes:buffer length:5];
			frame.disposalMethod = (buffer[0] & 0x1c) >> 2;
			//NSLog(@"flags=%x, dm=%x", (int)(buffer[0]), frame.disposalMethod);
			
			// We save the delays for easy access.
			frame.delay = (buffer[1] | buffer[2] << 8);
			
			unsigned char board[8];
			board[0] = 0x21;
			board[1] = 0xF9;
			board[2] = 0x04;
			
			for(int i = 3, a = 0; a < 5; i++, a++)
			{
				board[i] = buffer[a];
			}
			
			frame.header = [NSData dataWithBytes:board length:8];
            
			[GIF_frames addObject:frame];
			[frame release];
			break;
		}
		
		prev[0] = cur[0];
        [self GIFGetBytes:1];
		[GIF_buffer getBytes:cur length:1];
	}	
}

- (void) GIFReadDescriptor
{
	[self GIFGetBytes:9];
    
    // Deep copy
	NSMutableData *GIF_screenTmp = [NSMutableData dataWithData:GIF_buffer];
	
	unsigned char aBuffer[9];
	[GIF_buffer getBytes:aBuffer length:9];
	
	CGRect rect;
	rect.origin.x = ((int)aBuffer[1] << 8) | aBuffer[0];
	rect.origin.y = ((int)aBuffer[3] << 8) | aBuffer[2];
	rect.size.width = ((int)aBuffer[5] << 8) | aBuffer[4];
	rect.size.height = ((int)aBuffer[7] << 8) | aBuffer[6];
    
	AnimatedGifFrame *frame = [GIF_frames lastObject];
	frame.area = rect;
	
	if (aBuffer[8] & 0x80) GIF_colorF = 1; else GIF_colorF = 0;
	
	unsigned char GIF_code = GIF_colorC, GIF_sort = GIF_sorted;
	
	if (GIF_colorF == 1)
    {
		GIF_code = (aBuffer[8] & 0x07);
        
		if (aBuffer[8] & 0x20)
        {
            GIF_sort = 1;
        }
        else
        {
        	GIF_sort = 0;
        }
	}
	
	int GIF_size = (2 << GIF_code);
	
	size_t blength = [GIF_screen length];
	unsigned char bBuffer[blength];
	[GIF_screen getBytes:bBuffer length:blength];
	
	bBuffer[4] = (bBuffer[4] & 0x70);
	bBuffer[4] = (bBuffer[4] | 0x80);
	bBuffer[4] = (bBuffer[4] | GIF_code);
	
	if (GIF_sort)
    {
		bBuffer[4] |= 0x08;
	}
	
    NSMutableData *GIF_string = [NSMutableData dataWithData:[[NSString stringWithString:@"GIF89a"] dataUsingEncoding: NSUTF8StringEncoding]];
	[GIF_screen setData:[NSData dataWithBytes:bBuffer length:blength]];
    [GIF_string appendData: GIF_screen];
    
	if (GIF_colorF == 1)
    {
		[self GIFGetBytes:(3 * GIF_size)];
		[GIF_string appendData:GIF_buffer];
	}
    else
    {
		[GIF_string appendData:GIF_global];
	}
	
	// Add Graphic Control Extension Frame (for transparancy)
	[GIF_string appendData:frame.header];
	
	char endC = 0x2c;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	size_t clength = [GIF_screenTmp length];
	unsigned char cBuffer[clength];
	[GIF_screenTmp getBytes:cBuffer length:clength];
	
	cBuffer[8] &= 0x40;
	
	[GIF_screenTmp setData:[NSData dataWithBytes:cBuffer length:clength]];
	
	[GIF_string appendData: GIF_screenTmp];
	[self GIFGetBytes:1];
	[GIF_string appendData: GIF_buffer];
	
	while (true)
    {
		[self GIFGetBytes:1];
		[GIF_string appendData: GIF_buffer];
		
		unsigned char dBuffer[1];
		[GIF_buffer getBytes:dBuffer length:1];
		
		long u = (long) dBuffer[0];
        
		if (u != 0x00)
        {
			[self GIFGetBytes:u];
			[GIF_string appendData: GIF_buffer];
        }
        else
        {
            break;
        }
        
	}
	
	endC = 0x3b;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	// save the frame into the array of frames
	frame.data = GIF_string;
}

- (bool) GIFGetBytes:(int)length
{
    if (GIF_buffer != nil)
    {
        [GIF_buffer release]; // Release old buffer
        GIF_buffer = nil;
    }
    
	if ((NSInteger)[GIF_pointer length] >= dataPointer + length) // Don't read across the edge of the file..
    {
		GIF_buffer = [[GIF_pointer subdataWithRange:NSMakeRange(dataPointer, length)] retain];
        dataPointer += length;
		return YES;
	}
    else
    {
        return NO;
	}
}

- (bool) GIFSkipBytes: (int) length
{
    if ((NSInteger)[GIF_pointer length] >= dataPointer + length)
    {
        dataPointer += length;
        return YES;
    }
    else
    {
    	return NO;
    }
}

- (NSData*) getFrameAsDataAtIndex:(int)index
{
	if (index < (NSInteger)[GIF_frames count])
	{
		return ((AnimatedGifFrame *)[GIF_frames objectAtIndex:index]).data;
	}
	else
	{
		return nil;
	}
}

- (UIImage*) getFrameAsImageAtIndex:(int)index
{
    NSData *frameData = [self getFrameAsDataAtIndex: index];
    UIImage *image = nil;
    
    if (frameData != nil)
    {
		image = [UIImage imageWithData:frameData];
    }
    
    return image;
}



    //add by william 2012-11-7
    //函数中完善self被密集重用时导致图片加载后显示错乱
- (void)getImageWithUrl:(NSString *)urlString defaultImg:(UIImage *)defaultImg successBlock:(void(^)(void)) successBlock failedBlock:(void(^)(void)) failedBlock;
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    
    if (!urlString || urlString.length < 1)
    {
        return;
    }
    
    self.image = defaultImg;
    
    NSString *imageFilePath = [self getCacheFile:[self MD5Value:urlString]];
    NSData *cacheImgData = [NSData dataWithContentsOfFile:imageFilePath];
    _currentDownloadingImgFilePath = [imageFilePath copy];
    
    if (cacheImgData)
    {
        NSLog(@"isGifImage %@", [SCGIFImageView isGifImage:cacheImgData] ? @"YES" : @"NO");
        if (![SCGIFImageView isGifImage:cacheImgData])
        {
            UIImage *cachedImg = [UIImage imageWithData:cacheImgData];
            self.image = cachedImg;
        }
        else
        {
            [self loadImageByImageData:cacheImgData];
        }
        
        if (successBlock != NULL)
        {
            NSLog(@"read cached img");
            successBlock();
        }
    }
    else
    {
        if (!indicatorView)
        {
            indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            indicatorView.center = self.center;
            [self addSubview:indicatorView];
            [indicatorView startAnimating];
        }
        
            //避免retain self
        __block SCGIFImageView *selfImgView = self;
        
        dispatch_queue_t downloadQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        void (^downloadBlock)(void) = ^(void){
            
            NSString *blockUseCurrentDownloadingImgPath = [imageFilePath copy];
            
            if (GCDAsyncDownloadImageCancel)
            {
                [blockUseCurrentDownloadingImgPath release];
                NSLog(@"Download Canceled");
                return;
            }
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            UIImage *img = nil;
            
            if (imageData)
            {
                BOOL isGifImg = [SCGIFImageView isGifImage:imageData];
                    //if it's not gif image
                if (!isGifImg)
                {
                    img = [UIImage imageWithData:imageData];
                    if (img)
                    {
                        [UIImagePNGRepresentation(img) writeToFile:imageFilePath atomically:YES];
                    }
                }
                else
                {
                    [imageData writeToFile:imageFilePath atomically:YES];
                }
                
                NSLog(@"currentDownloadingImgFilePath %@, imageFilePath %@", blockUseCurrentDownloadingImgPath, _currentDownloadingImgFilePath);
                    //当UIImageView被重用时,_currentDownloadingImgFilePath将会被重新赋值并且在block有体显(值发生改变),但blockUseCurrentDownloadingImgPath是block变量,它一直不变
                    //所以用此来判断是否被重用了,下载的图是否是当前重用时要下载的图
                if (!_currentDownloadingImgFilePath || [_currentDownloadingImgFilePath isEqualToString:blockUseCurrentDownloadingImgPath])
                {
                    if (selfImgView)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                                //下载结束 停止风火轮
                            [indicatorView removeFromSuperview];
                            [indicatorView stopAnimating];
                            [indicatorView release];
                            indicatorView = nil;
                            
                            if (!isGifImg)
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
                                [UIView animateWithDuration:0.4 animations:^{selfImgView.alpha = 0.0f;} completion:^(BOOL finished){
                                    
                                    [selfImgView loadImageByImageData:imageData];
                                    [UIView animateWithDuration:0.4 animations:^{
                                        
                                        selfImgView.alpha = 1.0f;
                                    }];
                                }];
                            }
                            
                        });
                    }
                    else
                    {
                        NSLog(@"imgview released");
                    }
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


@end
