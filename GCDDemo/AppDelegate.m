//
//  AppDelegate.m
//  GCDDemo
//
//  Created by willonboy zhang on 12-7-5.
//  Copyright (c) 2012年 willonboy.tk. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    MainViewController *mainVC = [[MainViewController alloc] init];
    self.window.rootViewController = mainVC;
    [mainVC release];
    mainVC = nil;
    
    
//    dispatch_queue_t queue = dispatch_queue_create("demoqueue", NULL);
//        //将其资源初始值设置为 0 (不能少于 0)
//    dispatch_semaphore_t semaphoreDemo = dispatch_semaphore_create(0);
//    
//    
//    void(^demoBlock)(void) =  ^(void){
//        for (int i=0; i<20000; i++)
//        {
//            NSLog(@"queue print %d", i);
//            if (i==4000) 
//            {
//                    //使用 dispatch_semaphore_signal 增加 semaphore 计数（可理解为资源数）表明任务完成，有资源可用主线程可以做事情了
//                dispatch_semaphore_signal(semaphoreDemo);
//            }
//        }
//        
//    };
//    
//    dispatch_async(queue, demoBlock);
//    
//        //sleep(1);
//    NSLog(@"this print from main threed");
//        //dispatch_semaphore_wait 就是减少 semaphore 的计数，如果资源数少于 0，则表明资源还可不得
//    dispatch_semaphore_wait(semaphoreDemo, 0);
//    dispatch_release(queue);
    

    
    return YES;
}



@end
