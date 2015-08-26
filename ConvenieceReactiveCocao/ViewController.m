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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
