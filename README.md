#####  一、简介
ReactiveCocoa（简称为RAC）,是由Github开源的一个应用于iOS和OS开发的新框架,Cocoa是苹果整套框架的简称，因此很多苹果框架喜欢以Cocoa结尾。

##### 二、 作用
在我们iOS开发过程中，当某些事件响应的时候，需要处理某些业务逻辑,这些事件都用不同的方式来处理。比如Delegate、KVO 、通知等等使用系统的方式，其实这些都可以使用RAC来实现。RAC可以在一定的程度减少我们开发的工作量，好处我就不在这里多说了，这不是今天的重点。那么让我来总结一下一些开发中常用的方法。

##### 三、基本的用法
###### 1.处理按钮点击事件
> 
1.1 使用系统的方法处理
```
[button addTarget:self action:@selector(testClick:) forControlEvents:UIControlEventTouchUpInside];
- (void) testClick:(UIButton *) sender {
}
```
1.2 使用RAC
```
 [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
    }];
```
# 

###### 2.手势监听
> 
```
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]init];
    [button addGestureRecognizer:tapGes];
    button.userInteractionEnabled = YES;
    [[tapGes rac_gestureSignal] subscribeNext:^(id x) {
        NSLog(@"按钮被点击了");
    }];
```

# 

###### 3.代理（Delegate）和 KVO
>  发送 
delegateSignal 为RACSubject的对象
```
- (IBAction)noticeClick:(id)sender {
    if (self.delegateSignal) {
        [self.delegateSignal sendNext:@"点击咯"];
    }
}
```

> 接收
```
 // KVO
    [[VC rac_valuesAndChangesForKeyPath:@"delegateSignal" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
        NSLog(@"delegate 已经指定");
    }];
    // 代替代理
    VC.delegateSignal = [RACSubject subject];
    [VC.delegateSignal subscribeNext:^(id x) {
        NSLog(@"第一种代理实现方式%@", x);
    }];
    [self presentViewController:VC animated:YES completion:^{
    }];
    [[VC rac_signalForSelector:@selector(noticeClick:)] subscribeNext:^(id x) {
        NSLog(@"第二种代理实现方式");
    }];
```
###### 3.通知和键值观察
3.1 通知
>    
```
 // 键盘通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"UIKeyboardWillShowNotification" object:nil] subscribeNext:^(id x) {
        debugLog(@"键盘弹起");
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"UIKeyboardWillHideNotification" object:nil] subscribeNext:^(id x) {
              debugLog(@"键盘收起");
    }];
```
```
// 普通的通知(接收)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"message" object:nil] subscribeNext:^(id x) {
        @strongify(self);
        self.tabBarController.selectedIndex = 3;
        GFBMessageVC *VC = [[UIStoryboard storyboardWithName:@"Message" bundle:nil]
            instantiateViewControllerWithIdentifier:@"GFBMessageVC"];
        [self.tabBarController.selectedViewController pushViewController:VC animated:NO];
    }];
// 发送
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Message" object:nil];
```

# 

3.1 键值观察
> 
```
// 键值观察
    [RACObserve(self.view, frame) subscribeNext:^(id x) {
        CGRect rect = [x CGRectValue];
        NSLog(@"%@",NSStringFromCGRect(rect));
    }];
```

###### 4.输入框输入监听
> 
```
// 使用KVO可以监听输入和直接赋值
    [RACObserve(self.cashInTF, text) subscribeNext:^(NSString *x) {
        @strongify(self);
        if ([x integerValue] >= 100) {
        }else {
        }
    }];
    [self.cashInTF.rac_textSignal subscribeNext:^(id x) {
        @strongify(self);
        if ([x integerValue] >= 100) {
        }else {
        }
    }];
```
# 

###### 5.定时器和延时调用
> 
```
    // 计时器
    _disposable = [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        NSLog(@"每隔一秒调用一次：%@",x);
        [_disposable dispose];
    }];
    // 延时执行
    [[RACScheduler mainThreadScheduler] afterDelay:0.3 schedule:^{
    }];
    [[RACScheduler currentScheduler] afterDelay:0.03 schedule:^{
    }];
```
# 

###### 5.数组和字典快速迭代
> 
```
// 数组
 NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    [array.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"遍历数组：%@", x);
    }];
    NSArray *newArray = [[array.rac_sequence map:^id(NSString *value) {
        return [value stringByAppendingString:@":map转换"];
    }] array];
    [newArray.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"map数组遍历：%@", x);
    }];
// 字典
    NSDictionary *dict = @{@"一":@"1",@"二":@"2",@"三":@"3",@"四":@"4",@"五":@"5"};
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(NSString *key, NSString *value) = x;
        NSLog(@"遍历字典：key:%@, value:%@", key, value);
    }];
```

###### 6.信号合并
6.1  combineLatest
> 
```
RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第一次信号输出"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第二次信号输出"];
        [subscriber sendCompleted];
        return nil;
    }];
    [[signal1 combineLatestWith:signal2] subscribeNext:^(id x) {
        NSLog(@"信号最新爆炸：%@,%@", x[0], x[1]);
    }];
```
>> 
```
[[RACSignal combineLatest:@[self.originalPasswordTF.rac_textSignal,self.passwordTF.rac_textSignal] reduce:^id(NSString *original,NSString *passNew){
        return @(original.length >= 6 &&  original.length <= 20 && passNew.length >= 6 &&  passNew.length <= 20);
    }] subscribeNext:^(id x) {
        if ([x integerValue]) {
        }else {
        }
    }];
```
# 

6.2 zip
```
RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第一次信号输出"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第二次信号输出"];
        [subscriber sendCompleted];
        return nil;
    }];
    [[signal1 zipWith:signal2] subscribeNext:^(id x) {
        NSLog(@"信号同时爆炸：%@,%@", x[0], x[1]);
    }];
```

###### 7.merge
```
// zip比较坑爹的是，需要压缩的所有新号有了subscribe，才会触发他的next,使用merge可以解决
RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第一次信号"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第二次信号"];
        [subscriber sendCompleted];
        return nil;
    }];
    [[signal1 merge:signal2] subscribeNext:^(id x) {
        NSLog(@"1或2有信号发布%@", x);
    }];
```
# 

###### 8.then
```
[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第一次信号成功执行下一步"];
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
      return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
          [subscriber sendNext:@"第二步执行"];
          [subscriber sendCompleted];
          return nil;
      }];
    }] subscribeNext:^(id x) {
        NSLog(@"最后获取信号数据:%@", x);
    }];
```
# 
###### 9.concat
```
RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第一次信号输出"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第二次信号输出"];
        [subscriber sendCompleted];
        return nil;
    }];
    [[signal1 concat:signal2] subscribeNext:^(id x) {
        NSLog(@"信号按顺序输出%@", x);
    }];
```
# 

###### 10.reduce 
```
RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第一次爆炸"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第二次爆炸"];
        [subscriber sendCompleted];
        return nil;
    }];
    [[RACSignal combineLatest:@[signal1, signal2] reduce:^id(NSString *v1, NSString *v2){
        return [NSString stringWithFormat:@"--->%@%@<---", v1,v2];
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
```






