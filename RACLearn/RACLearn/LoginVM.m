//
//  LoginVM.m
//  RACLearn
//
//  Created by qinfensky on 2016/10/27.
//  Copyright © 2016年 qinfensky. All rights reserved.
//

#import "LoginVM.h"
#import "RACSignal.h"

@implementation LoginVM

- (instancetype)init {
    if (self = [super init]) {
        [self initBind];
    }
    return self;
}

#pragma mark: - private Methods
- (void)initBind {
    
    // 按钮点击状态是否能点击
    self.loginEnableSignal = [RACSignal combineLatest:@[RACObserve(self.account, account), RACObserve(self.account, psw)] reduce:^id(NSString *v1, NSString *v2){
        return @(v1.length && v2.length);
    }];
    
    
    // 按钮事件
    [self.loginCommand.executionSignals.switchToLatest subscribeNext:^(NSString *x) {
        if ([x isEqualToString:@"登录完毕"]) {
            
            NSLog(@"%@", x);
            
        }
    }];
    
    [[self.loginCommand.executing skip:1] subscribeNext:^(id x) {
        
        if ([x boolValue]) {
            NSLog(@"登录中…………");
        } else {
            NSLog(@"登录状态完毕");
        }
        
    }];
}

#pragma mark: - getter and setter
- (RACCommand *)loginCommand {
    if (! _loginCommand) {
        _loginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            NSLog(@"按钮点击");
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [subscriber sendNext:@"登录完毕"];
                    [subscriber sendCompleted];
                });
                return nil;
            }];
        }];
    }
    return _loginCommand;
}

- (Account *)account {
    if (!_account) {
        _account = [[Account alloc] init];
    }
    return _account;
}


@end
