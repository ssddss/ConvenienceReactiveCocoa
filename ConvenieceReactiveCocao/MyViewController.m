//
//  MyViewController.m
//  ConvenieceReactiveCocao
//
//  Created by ssdd on 15/8/26.
//  Copyright (c) 2015年 ssdd. All rights reserved.
//

#import "MyViewController.h"
#import "ReactiveCocoa.h"
@interface MyViewController ()
@property (weak, nonatomic) IBOutlet UIButton *commandButon;
@property (nonatomic,copy) NSString *str;
@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self registerNotification];
    @weakify(self)
   __block NSString *strl = @"abc";
    self.commandButon.rac_command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"click");
        @strongify(self)
        self.str = @"abc";
        strl = @"111";
        return [RACSignal empty];
    }];
    
    [[RACSignal interval:5 onScheduler:[RACScheduler mainThreadScheduler] withLeeway:0] subscribeNext:^(id x) {
        NSLog(@"吃药了你");
    }];
}
- (void)dealloc {
    NSLog(@"内存清了");
    [[NSNotificationCenter defaultCenter]removeObserver:self];    
}

- (void)registerNotification {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"代码之道频道" object:nil] subscribeNext:^(NSNotification* x) {
        NSLog(@"技巧：%@", x.userInfo[@"技巧"]);
    }];
}
- (IBAction)clicked:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"代码之道频道" object:nil userInfo:@{@"技巧":@"用心写"}];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
