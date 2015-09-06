//
//  ViewController.m
//  ConvenieceReactiveCocao
//
//  Created by ssdd on 15/8/26.
//  Copyright (c) 2015年 ssdd. All rights reserved.
//

#import "ViewController.h"
#import "ReactiveCocoa.h"
#import "Masonry.h"
#import "RACDisposable.h"

@protocol ViewControllerDelegate <NSObject>

- (void)makeAnApp;

@end

@interface ViewController ()<ViewControllerDelegate>
@property (nonatomic,copy) NSString *strValue;
@property (nonatomic,copy) NSString *valueA;
@property (weak, nonatomic) IBOutlet UIButton *postNotification;
@property (nonatomic,copy) NSString *valueB;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self observeValue];
    
    [self singleInfluence];
    
    [self reverseInfluence];
    
    [self racDelegate];
    
    [self connectTwoSignal];
    
    [self mergeSignals];
    
    [self combinationSignals];
    
    [self zipSignals];
    
    [self mapSignal];
    
    [self twoSignalsAdded];
    
    [self filterSiganl];
    
    [self flattenMap];
    
    [self order];
    
    [self delay];
    
    [self anchor];
    
    [self timing];
    
    [self overTime];
    
    [self tryAgainAndAgain];
    
    [self limit];
    
    [self condition];
    
    self.postNotification.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"代码之道频道" object:nil userInfo:@{@"技巧":@"用心写"}];
        return [RACSignal empty];
    }];
}
- (IBAction)clicked:(UIButton *)sender {
    [self command];

}

/**
 *  观察某个值
 */
- (void)observeValue {
    @weakify(self);
    [[RACObserve(self, strValue) filter:^BOOL(NSString *value) {
        return value ? YES:NO;
    }]subscribeNext:^(NSString *x) {
        @strongify(self);
        NSLog(@"strValueChanged: %@",x);
    }];
    
    self.strValue = @"1";

}
/**
 *  单边影响
 */
- (void)singleInfluence {
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"唱歌"];
        [subscriber sendCompleted];
        return nil;
    }];
    RAC(self, strValue) = [signalA map:^id(NSString* value) {
        if ([value isEqualToString:@"唱歌"]) {
            return @"跳舞";
        }
        return @"";
    }];

}
/**
 *  反向影响
 */
- (void)reverseInfluence {
    RACChannelTerminal *channelA = RACChannelTo(self, valueA);
    RACChannelTerminal *channelB = RACChannelTo(self, valueB);
    [[channelA map:^id(id value) {
        if ([value isEqualToString:@"西"]) {
            return @"东";
        }
        return value;
    }] subscribe:channelB];
    
    [[channelB map:^id(id value) {
        if ([value isEqualToString:@"左"]) {
            return @"右";
        }
        return value;
    }] subscribe:channelA];
    
    [[RACObserve(self, valueA) filter:^BOOL(id value) {
        return value ? YES : NO;
    }] subscribeNext:^(NSString* x) {
        NSLog(@"你向%@", x);
    }];
    [[RACObserve(self, valueB) filter:^BOOL(id value) {
        return value ? YES : NO;
    }] subscribeNext:^(NSString* x) {
        NSLog(@"他向%@", x);
    }];
    
    self.valueA = @"东";
    self.valueB = @"左";
    
}
/**
 *  代理模式
 */
- (void)racDelegate {
    RACSignal *programmerSignal = [self rac_signalForSelector:@selector(makeAnApp) fromProtocol:@protocol(ViewControllerDelegate)];
    [programmerSignal subscribeNext:^(RACTuple *x) {
        NSLog(@"花了一个小时写个了app，666");
    }];
    
    [self makeAnApp];
    
}
/**
 *  连接
 */
- (void)connectTwoSignal {
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"买房了"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"日狗了"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [[signalA concat:signalB]subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}
/**
 *  合并
 */
- (void)mergeSignals {
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"垃圾袋"];
        [subscriber sendCompleted];

        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"吸管"];
        [subscriber sendCompleted];

        return nil;
    }];
    
    [[RACSignal merge:@[signalA,signalB]]subscribeNext:^(id x) {
        NSLog(@"处理%@",x);
    }];

}
/**
 *  组合,你是红的，我是黄的，我们就是红黄的，你是白的，我没变，我们是白黄的。一个去跟另一个组合起来
 */
- (void)combinationSignals {
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"红"];
        [subscriber sendNext:@"白"];
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"黄"];
//        [subscriber sendNext:@"白"];
        return nil;
    }];
    [[RACSignal combineLatest:@[signalA, signalB]] subscribeNext:^(RACTuple* x) {
        RACTupleUnpack(NSString *stringA, NSString *stringB) = x;
        NSLog(@"我们是%@%@的", stringA, stringB);
    }];
}
/**
 *  压缩,你是红的，我是黄的，我们就是红黄的，你是白的，我没变，哦，那就等我变了再说吧,B再发一个对应A中的下一个
 */
- (void)zipSignals {
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"红"];

        [subscriber sendNext:@"白"];
        
        [subscriber sendNext:@"绿"];


        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"黄"];
        [subscriber sendNext:@"白"];
        [subscriber sendNext:@"橙"];

        return nil;
    }];
    [[signalA zipWith:signalB] subscribeNext:^(id x) {
        RACTupleUnpack(NSString *stringA,NSString *stringB) = x;
        NSLog(@"我们是%@%@",stringA,stringB);
    }];
    
}
/**
 *  映射,我可以点石成金。
 */
- (void)mapSignal {
    RACSignal *signalA = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"fufe"];
        return nil;
    }]map:^id(id value) {
        if ([value isEqualToString:@"石"]) {
            return @"金";
        }
        return value;
    }];
    [signalA subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}
/**
 *  归约
 
 糖加水变成糖水。
 */
- (void)twoSignalsAdded {
    RACSignal *sugarSignal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"糖"];
        return nil;
    }];
    RACSignal *waterSignal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"水"];
        return nil;
    }];
    [[RACSignal combineLatest:@[sugarSignal,waterSignal] reduce:^id(NSString *sugar,NSString *water){
        return [sugar stringByAppendingString:water];
    }]subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}
/**
 *  过滤
 */
- (void)filterSiganl {
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@10];
        [subscriber sendNext:@15];
        [subscriber sendNext:@40];
        [subscriber sendNext:@20];
        return nil;
    }]filter:^BOOL(id value) {
        return [value integerValue] < 19;
    }]subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}
/**
 *  扁平
 
 打蛋液，煎鸡蛋，上盘。
 */
- (void)flattenMap {
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"打蛋液");
        [subscriber sendNext:@"蛋液"];
        [subscriber sendCompleted];
        return nil;
    }] flattenMap:^RACStream *(id value) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"把%@倒进锅里",value);
            [subscriber sendNext:@"煎蛋"];
            [subscriber sendCompleted];
            return nil;
        }];
    }] flattenMap:^RACStream *(id value) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"把%@装到盘里",value);
            [subscriber sendNext:@"上菜"];
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}
/**
 *  秩序 把大象塞进冰箱只需要三步：打开冰箱门，把大象塞进冰箱，关上冰箱门。
 */
- (void)order {
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"打开冰箱门");
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"把大象塞进冰箱");
            [subscriber sendCompleted];
            return nil;
        }];
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"关上冰箱门");
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeCompleted:^{
        NSLog(@"把大象塞进冰箱了");
    }];
}
/**
 *  命令
 */
- (void)command {
    RACCommand *aCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"我投降了");
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    [aCommand execute:nil];
}
/**
 *  延迟
 */
- (void)delay {
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"等5秒");
        [subscriber sendNext:@"ssdd"];
        [subscriber sendCompleted];
        return nil;
    }] delay:5] subscribeNext:^(id x) {
        NSLog(@"%@到了",x);
    }];
}
/**
 *  重放
 */
- (void)anchor {
    RACSignal *replaySignal = [[RACSignal createSignal:^RACDisposable *(id subscriber) {
        NSLog(@"大导演拍了一部电影《我的男票是程序员》");
        [subscriber sendNext:@"《我的男票是程序员》"];
        return nil;
    }] replay];
    [replaySignal subscribeNext:^(id x) {
        NSLog(@"小明看了%@", x);
    }];
    [replaySignal subscribeNext:^(id x) {
        NSLog(@"小红也看了%@", x);
    }];
}
/**
 *  定时
 */
- (void)timing {
    
    [[RACSignal interval:5 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        NSLog(@"吃药");
    }];
}
/**
 *  超时
 */
- (void)overTime {
    [[[RACSignal createSignal:^RACDisposable *(id subscriber) {
        [[[RACSignal createSignal:^RACDisposable *(id subscriber) {
            NSLog(@"我快到了");
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
            return nil;
        }] delay:5] subscribeNext:^(id x) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        return nil;
    }] timeout:3 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        NSLog(@"我按时到达了");

    } error:^(NSError *error) {
        NSLog(@"等了你一个小时了，你还没来，我走了");

    }];
    
}
/**
 *  重试
 */
- (void)tryAgainAndAgain {
    __block int failedCount = 1;
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (failedCount < 5) {
            NSLog(@"失败第%d次",failedCount);
            failedCount++;
            [subscriber sendError:nil];
        }
        else {
            NSLog(@"经历了%d次后",failedCount);
            [subscriber sendNext:nil];
        }
        return nil;
        
    }] retry] subscribeNext:^(id x) {
        NSLog(@"终于成功了");
    }];
}
/**
 *  节流 不好意思，这里一秒钟只能通过一个人。
 */
- (void)limit {
    [[[RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"旅客A"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"旅客B"];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"旅客C"];
            [subscriber sendNext:@"旅客D"];
            [subscriber sendNext:@"旅客E"];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"旅客F"];
        });
        return nil;
    }] throttle:1] subscribeNext:^(id x) {
        NSLog(@"%@通过了",x);
    }];
}
/**
 *  条件
 */
- (void)condition {
    [[[RACSignal createSignal:^RACDisposable *(id subscriber) {
        [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            [subscriber sendNext:@"直到世界的尽头才能把我们分开"];
        }];
        return nil;
    }] takeUntil:[RACSignal createSignal:^RACDisposable *(id subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"世界的尽头到了");
            [subscriber sendNext:@"世界的尽头到了"];
        });
        return nil;
    }]] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
