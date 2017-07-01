//
//  ViewController.m
//  GCDDemo
//
//  Created by Yunis on 17/6/27.
//  Copyright © 2017年 Yunis. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self demo01];
//    [self demo02];
//    [self demo03];
//    [self demo04];
//    [self demo05];
//    [self demo06];
//    [self demo06];
}

- (void)creatQueue
{
    //1 手动创建 queue
    //串行 任务安装FIFO 执行,一个线程
    dispatch_queue_t yunisSerialQueue = dispatch_queue_create("Yunis.Demo.Queue", NULL);
    
    //并行 任务同时执行  多个线程
    dispatch_queue_t yunisConcurrentQueue = dispatch_queue_create("Yunis.Demo.Queue", DISPATCH_QUEUE_CONCURRENT);
    
    //2 使用系统提供 queue
    dispatch_queue_t mainDispatchQueue = dispatch_get_main_queue();
    
    dispatch_queue_t globalDispatchQueueHigh = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);  //高优先级
    dispatch_queue_t globalDispatchQueueDefault = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);  //默认优先级
    dispatch_queue_t globalDispatchQueueLow = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0);  //低优先级
    dispatch_queue_t globalDispatchQueueBackgroud = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);  //后台
    
    dispatch_async(globalDispatchQueueLow, ^{
        NSLog(@"Low");
    });
    
    dispatch_async(globalDispatchQueueDefault, ^{
        NSLog(@"Default");

    });
    
    dispatch_async(globalDispatchQueueHigh, ^{
        NSLog(@"High");

    });
    
    dispatch_async(globalDispatchQueueBackgroud, ^{
        NSLog(@"Backgroud");
    });
}

- (void)demo01
{
    NSLog(@"01");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //并行想要执行的代码
        NSLog(@"02");

        //在Main Dispatch Queue中执行block
        dispatch_async(dispatch_get_main_queue(),^{
            
            //想要在主线程中执行的代码 如刷新UI
            NSLog(@"03");

        });
    });
    NSLog(@"04");

}

- (void)demo02
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 3ull * NSEC_PER_SEC);
    NSLog(@"01");

    dispatch_after (time ,dispatch_get_main_queue(),^{
        
        //等待三秒之后要执行的操作
        NSLog(@"02");

    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //等待四秒之后要执行的操作
        NSLog(@"03");
    });
    NSLog(@"04");

}

- (void)demo03
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_group_t  group = dispatch_group_create();
    // 01  02  03  执行顺序是不一定的
    //如果内部执行异步代码 无法保证异步代码执行完毕后再进入 04
    dispatch_group_async(group,queue,^{
        NSLog(@"01");
    });
    dispatch_group_async(group,queue,^{
        NSLog(@"02");
    });
    dispatch_group_async(group,queue,^{
        NSLog(@"03");
    });
    
    //01 02 03  执行完毕 进入04
    dispatch_group_notify(group,dispatch_get_main_queue(),^{
        NSLog(@"04");
    });
}

- (void)demo04
{
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
        NSLog(@"执行任务00");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"任务00执行完毕");
            dispatch_group_leave(group);

        });
        
    });
    
    dispatch_group_enter(group);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^{
        NSLog(@"执行任务01");
        NSLog(@"任务01执行完毕");
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group,dispatch_get_main_queue(),^{
        NSLog(@"任务00、01 执行完毕 进入下一步流程");
    });
}

- (void)demo05
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    
    dispatch_apply(10,queue,^(size_t index){
        
        NSLog(@"index = %zu",index);
    });
    
    NSLog(@"Done\n\n\n\n\n\n");
}
- (void)demo06
{
    NSLog(@"dispatch_once");

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"生命周期 只执行一次");
    });
    NSLog(@"dispatch_once end");

}

- (void)demo07
{
    dispatch_queue_t yunisSerialQueue = dispatch_queue_create("Yunis.Demo.Queue", NULL);
    dispatch_queue_t globalDispatchQueueBackgroud = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,0);  //后台
    
    //将 yunisSerialQueue 的优先级 设置为与 globalDispatchQueueBackgroud 相同
    //如果 dispatch_set_target_queue 的第一个参数 为 Main Dispatch Queue 和 Global Dispatch Queue，不知道会出现什么情况，以为这些均不可指定，必须使用系统之前默认的优先级。
    dispatch_set_target_queue(yunisSerialQueue, globalDispatchQueueBackgroud);

    
}
@end
