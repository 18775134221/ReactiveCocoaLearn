//
//  TowViewController.h
//  RACLearn
//
//  Created by qinfensky on 2016/10/26.
//  Copyright © 2016年 qinfensky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface TowViewController : UIViewController

@property (nonatomic, strong) RACSubject *delegateSignal;

- (IBAction)noticeClick:(id)sender;

@end
