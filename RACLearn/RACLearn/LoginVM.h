//
//  LoginVM.h
//  RACLearn
//
//  Created by qinfensky on 2016/10/27.
//  Copyright © 2016年 qinfensky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Account.h"

@interface LoginVM : NSObject

@property (nonatomic, strong) Account *account;

@property (nonatomic, strong) RACSignal *loginEnableSignal;
@property (nonatomic, strong) RACCommand *loginCommand;

@end
