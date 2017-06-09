//
//  TowViewController.m
//  RACLearn
//
//  Created by qinfensky on 2016/10/26.
//  Copyright © 2016年 qinfensky. All rights reserved.
//

#import "TowViewController.h"

@interface TowViewController ()

@end

@implementation TowViewController

#pragma mark: - lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark: - event response
- (IBAction)noticeClick:(id)sender {
    
    if (self.delegateSignal) {
        [self.delegateSignal sendNext:@"点击咯"];
    }
    
}



@end
