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


`附录说明`
# 一、常见类
    1、RACSiganl 信号类。
        RACEmptySignal ：空信号，用来实现 RACSignal 的 +empty 方法；
        RACReturnSignal ：一元信号，用来实现 RACSignal 的 +return: 方法；
        RACDynamicSignal ：动态信号，使用一个 block - 来实现订阅行为，我们在使用 RACSignal 的 +createSignal: 方法时创建的就是该类的实例；
        RACErrorSignal ：错误信号，用来实现 RACSignal 的 +error: 方法；
        RACChannelTerminal ：通道终端，代表 RACChannel 的一个终端，用来实现双向绑定。
    2、RACSubscriber 订阅者
    3、RACDisposable 用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。
        RACSerialDisposable ：作为 disposable 的容器使用，可以包含一个 disposable 对象，并且允许将这个 disposable 对象通过原子操作交换出来；
        RACKVOTrampoline ：代表一次 KVO 观察，并且可以用来停止观察；
        RACCompoundDisposable ：它可以包含多个 disposable 对象，并且支持手动添加和移除 disposable 对象
        RACScopedDisposable ：当它被 dealloc 的时候调用本身的 -dispose 方法。
    4、RACSubject 信号提供者，自己可以充当信号，又能发送信号。
        RACGroupedSignal ：分组信号，用来实现 RACSignal 的分组功能；
        RACBehaviorSubject ：重演最后值的信号，当被订阅时，会向订阅者发送它最后接收到的值；
        RACReplaySubject ：重演信号，保存发送过的值，当被订阅时，会向订阅者重新发送这些值。
    5、RACTuple 元组类,类似NSArray,用来包装值.
    6、RACSequence RAC中的集合类
    7、RACCommand RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程。
    8、RACMulticastConnection 用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理。
    9、RACScheduler RAC中的队列，用GCD封装的。
        RACImmediateScheduler ：立即执行调度的任务，这是唯一一个支持同步执行的调度器；
        RACQueueScheduler ：一个抽象的队列调度器，在一个 GCD 串行列队中异步调度所有任务；
        RACTargetQueueScheduler ：继承自 RACQueueScheduler ，在一个以一个任意的 GCD 队列为 target 的串行队列中异步调度所有任务；
        RACSubscriptionScheduler ：一个只用来调度订阅的调度器。
        

# 二、常见用法
    rac_signalForSelector : 代替代理
    rac_valuesAndChangesForKeyPath: KVO
    rac_signalForControlEvents:监听事件
    rac_addObserverForName 代替通知
    rac_textSignal：监听文本框文字改变
    rac_liftSelector:withSignalsFromArray:Signals:当传入的Signals(信号数组)，每一个signal都至少sendNext过一次，就会去触发第一个selector参数的方法。
    

# 三、常见宏
    RAC(TARGET, [KEYPATH, [NIL_VALUE]])：用于给某个对象的某个属性绑定
    RACObserve(self, name) ：监听某个对象的某个属性,返回的是信号。
    @weakify(Obj)和@strongify(Obj)
    RACTuplePack ：把数据包装成RACTuple（元组类）
    RACTupleUnpack：把RACTuple（元组类）解包成对应的数据
    RACChannelTo 用于双向绑定的一个终端

# 四、常用操作方法
    flattenMap map 用于把源信号内容映射成新的内容。
    concat 组合 按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号
    then 用于连接两个信号，当第一个信号完成，才会连接then返回的信号。
    merge 把多个信号合并为一个信号，任何一个信号有新值的时候就会调用
    zipWith 把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。
    combineLatest:将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号。
    reduce聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值

    filter:过滤信号，使用它可以获取满足条件的信号.
    ignore:忽略完某些值的信号.
    distinctUntilChanged:当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
    take:从开始一共取N次的信号
    takeLast:取最后N次的信号,前提条件，订阅者必须调用完成，因为只有完成，就知道总共有多少信号.
    takeUntil:(RACSignal *):获取信号直到某个信号执行完成
    skip:(NSUInteger):跳过几个信号,不接受。
    switchToLatest:用于signalOfSignals（信号的信号），有时候信号也会发出信号，会在signalOfSignals中，获取signalOfSignals发送的最新信号。

    doNext: 执行Next之前，会先执行这个Block
    doCompleted: 执行sendCompleted之前，会先执行这个Block
    timeout：超时，可以让一个信号在一定的时间后，自动报错。
    interval 定时：每隔一段时间发出信号
    delay 延迟发送next。
    retry重试 ：只要失败，就会重新执行创建信号中的block,直到成功.
    replay重放：当一个信号被多次订阅,反复播放内容
    throttle节流:当某个信号发送比较频繁时，可以使用节流，在某一段时间不发送信号内容，过了一段时间获取信号的最新内容发出。

# 五、UI - Category（常用汇总）
    1、rac_prepareForReuseSignal： 需要复用时用
    相关UI: MKAnnotationView、UICollectionReusableView、UITableViewCell、UITableViewHeaderFooterView

    2、rac_buttonClickedSignal：点击事件触发信号
    相关UI：UIActionSheet、UIAlertView

    3、rac_command：button类、刷新类相关命令替换
    相关UI：UIBarButtonItem、UIButton、UIRefreshControl

    4、rac_signalForControlEvents: control event 触发
    相关UI：UIControl

    5、rac_gestureSignal UIGestureRecognizer 事件处理信号
    相关UI：UIGestureRecognizer

    6、rac_imageSelectedSignal 选择图片的信号
    相关UI：UIImagePickerController

    7、rac_textSignal
    相关UI：UITextField、UITextView

    8、可实现双向绑定的相关API
        rac_channelForControlEvents: key: nilValue:
        相关UI：UIControl类
        rac_newDateChannelWithNilValue:
        相关UI：UIDatePicker
        rac_newSelectedSegmentIndexChannelWithNilValue:
        相关UI：UISegmentedControl
        rac_newValueChannelWithNilValue:
        相关UI：UISlider、UIStepper
        rac_newOnChannel
        相关UI：UISwitch
        rac_newTextChannel
        相关UI：UITextField

# 六、Foundation - Category （常用汇总）
    1、NSArray
        rac_sequence 信号集合
    2、NSData
        rac_readContentsOfURL: options: scheduler: 比oc多出线程设置
    3、NSDictionary
        rac_sequence 不解释
        rac_keySequence key 集合
        rac_valueSequence value 集合
    4、NSEnumerator
        rac_sequence 不解释
    5、NSFileHandle
        rac_readInBackground 见名知意
    6、NSIndexSet
        rac_sequence 不解释
    7、NSInvocation
        rac_setArgument: atIndex: 设置参数
        rac_argumentAtIndex 取某个参数
        rac_returnValue 所关联方法的返回值
    8、NSNotificationCenter
        rac_addObserverForName: object:注册通知
    9、NSObject
        rac_willDeallocSignal 对象销毁时发动的信号
        rac_description debug用
        rac_observeKeyPath: options: observer: block:监听某个事件
        rac_liftSelector: withSignals: 全部信号都next在执行
        rac_signalForSelector: 代替某个方法
        rac_signalForSelector:(SEL)selector fromProtocol:代替代理
    9、NSOrderedSet
        rac_sequence 不解释
    10、NSSet
        rac_sequence 不解释
    11、NSString
        rac_keyPathComponents 获取一个路径所有的部分
        rac_keyPathByDeletingLastKeyPathComponent 删除路径最后一部分
        rac_keyPathByDeletingFirstKeyPathComponent 删除路径第一部分
        rac_sequence 不解释 (character)
        rac_readContentsOfURL: usedEncoding: scheduler: 比之OC多线程调用
    12、NSURLConnection
        rac_sendAsynchronousRequest 发起异步请求
    13、NSUserDefaults
        rac_channelTerminalForKey 用于双向绑定，此乃一端

# 
# 七、附录示例用法
## 1.RACSignal
```
// 1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 3.发送信号
        [subscriber sendNext:@"ws"];
        // 4.取消信号，如果信号想要被取消，就必须返回一个RACDisposable
        // 信号什么时候被取消：1.自动取消，当一个信号的订阅者被销毁的时候机会自动取消订阅，2.手动取消，
        //block什么时候调用：一旦一个信号被取消订阅就会调用
        //block作用：当信号被取消时用于清空一些资源
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"取消订阅");
        }];
    }];
    // 2. 订阅信号
    //subscribeNext
    // 把nextBlock保存到订阅者里面
    // 只要订阅信号就会返回一个取消订阅信号的类
    RACDisposable *disposable = [signal subscribeNext:^(id x) {
        // block的调用时刻：只要信号内部发出数据就会调用这个block
        NSLog(@"======%@", x);
    }];
    // 取消订阅
    [disposable dispose];
```
> 
    .核心：
        .核心：信号类
        .信号类的作用：只要有数据改变就会把数据包装成信号传递出去
        .只要有数据改变就会有信号发出
        .数据发出，并不是信号类发出，信号类不能发送数据
    .使用方法：
        .创建信号
        .订阅信号
    .实现思路：
        .当一个信号被订阅，创建订阅者，并把nextBlock保存到订阅者里面。
        .创建的时候会返回 [RACDynamicSignal createSignal:didSubscribe];
        .调用RACDynamicSignal的didSubscribe
        .发送信号[subscriber sendNext:value];
        .拿到订阅者的nextBlock调用

## 2.RACSubject
常用于替代代理
- 注意：
RACSubject和RACReplaySubject的区别
RACSubject必须要先订阅信号之后才能发送信号， 而RACReplaySubject可以先发送信号后订阅.

## 3.RACSequence
常用于遍历字典和数组
```
NSString *path = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    NSArray *dictArr = [NSArray arrayWithContentsOfFile:path];
    [dictArr.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    } error:^(NSError *error) {
        NSLog(@"===error===");
    } completed:^{
        NSLog(@"ok---完毕");
    }];

也可以使用宏

NSDictionary *dict = @{@"key":@1, @"key2":@2};
    [dict.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
        NSString *key = x[0];
        NSString *value = x[1];
        // RACTupleUnpack宏：专门用来解析元组
        // RACTupleUnpack 等会右边：需要解析的元组 宏的参数，填解析的什么样数据
        // 元组里面有几个值，宏的参数就必须填几个
        RACTupleUnpack(NSString *key, NSString *value) = x;
        NSLog(@"%@ %@", key, value);
    } error:^(NSError *error) {
        NSLog(@"===error");
    } completed:^{
        NSLog(@"-----ok---完毕");
    }];
```

## 4.RACMulticastConnection
当有多个订阅者，但是我们只想发送一个信号的时候怎么办？这时我们就可以用RACMulticastConnection，来实现。代码示例如下
```
// 普通写法, 这样的缺点是：没订阅一次信号就得重新创建并发送请求，这样很不友好
 RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // didSubscribeblock中的代码都统称为副作用。
        // 发送请求---比如afn
        NSLog(@"发送请求啦");
        // 发送信号
        [subscriber sendNext:@"ws"];
        return nil;
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
```
```
// 比较好的做法。 使用RACMulticastConnection，无论有多少个订阅者，无论订阅多少次，我只发送一个。
// 1.发送请求，用一个信号内包装，不管有多少个订阅者，只想发一次请求
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"发送请求啦");
        // 发送信号
        [subscriber sendNext:@"ws"];
        return nil;
    }];
    //2. 创建连接类
    RACMulticastConnection *connection = [signal publish];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [connection.signal subscribeNext:^(id x) {
         NSLog(@"%@", x);
    }];
    [connection.signal subscribeNext:^(id x) {
         NSLog(@"%@", x);
    }];
    //3. 连接。只有连接了才会把信号源变为热信号
    [connection connect];
```

## 5.RACCommand
  - RACCommand:RAC中用于处理事件的类，可以把事件如何处理，事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程，比如看事件有没有执行完毕
  - 使用场景：监听按钮点击，网络请求
```
// 普通做法
// RACCommand: 处理事件
    // 不能返回空的信号
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //block调用，执行命令的时候就会调用
        NSLog(@"%@",input); // input 为执行命令传进来的参数
        // 这里的返回值不允许为nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行命令产生的数据"];
            return nil;
        }];
    }];

    // 如何拿到执行命令中产生的数据呢？
    // 订阅命令内部的信号
    // ** 方式一：直接订阅执行命令返回的信号

    // 2.执行命令
    RACSignal *signal =[command execute:@2]; // 这里其实用到的是replaySubject 可以先发送命令再订阅
    // 在这里就可以订阅信号了
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
```
```
// 一般做法
 // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        //block调用，执行命令的时候就会调用
        NSLog(@"%@",input); // input 为执行命令传进来的参数
        // 这里的返回值不允许为nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行命令产生的数据"];
            return nil;
        }];
    }];

    // 方式二：
    // 订阅信号
    // 注意：这里必须是先订阅才能发送命令
    // executionSignals：信号源，信号中信号，signalofsignals:信号，发送数据就是信号
    [command.executionSignals subscribeNext:^(RACSignal *x) {
        [x subscribeNext:^(id x) {
            NSLog(@"%@", x);
        }];
//        NSLog(@"%@", x);
    }];

    // 2.执行命令
    [command execute:@2];
```
```
// 高级做法
// 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // block调用：执行命令的时候就会调用
        NSLog(@"%@", input);
        // 这里的返回值不允许为nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"发送信号"];
            return nil;
        }];
    }];

    // 方式三
    // switchToLatest获取最新发送的信号，只能用于信号中信号。
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 2.执行命令
    [command execute:@3];
```
```
// switchToLatest--用于信号中信号
// 创建信号中信号
    RACSubject *signalofsignals = [RACSubject subject];
    RACSubject *signalA = [RACSubject subject];
     // 订阅信号
//    [signalofsignals subscribeNext:^(RACSignal *x) {
//        [x subscribeNext:^(id x) {
//            NSLog(@"%@", x);
//        }];
//    }];
    // switchToLatest: 获取信号中信号发送的最新信号
    [signalofsignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [signalofsignals sendNext:signalA];
    [signalA sendNext:@4];
```
```
// 监听事件有没有完成
 //注意：当前命令内部发送数据完成，一定要主动发送完成
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        // block调用：执行命令的时候就会调用
        NSLog(@"%@", input);
        // 这里的返回值不允许为nil
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            // 发送数据
            [subscriber sendNext:@"执行命令产生的数据"];

            // *** 发送完成 **
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    // 监听事件有没有完成
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue] == YES) { // 正在执行
            NSLog(@"当前正在执行%@", x);
        }else {
            // 执行完成/没有执行
            NSLog(@"执行完成/没有执行");
        }
    }];

    // 2.执行命令
    [command execute:@1];
```

## 6.RAC-组合
```
// 思路--- 就是把输入框输入值的信号都聚合成按钮是否能点击的信号。
- (void)combineLatest {

    RACSignal *combinSignal = [RACSignal combineLatest:@[self.accountField.rac_textSignal, self.pwdField.rac_textSignal] reduce:^id(NSString *account, NSString *pwd){ //reduce里的参数一定要和combineLatest数组里的一一对应。
        // block: 只要源信号发送内容，就会调用，组合成一个新值。
        NSLog(@"%@ %@", account, pwd);
        return @(account.length && pwd.length);
    }];

    //    // 订阅信号
    //    [combinSignal subscribeNext:^(id x) {
    //        self.loginBtn.enabled = [x boolValue];
    //    }];    // ----这样写有些麻烦，可以直接用RAC宏
    RAC(self.loginBtn, enabled) = combinSignal;
}
```
```
- (void)zipWith {
    //zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元祖，才会触发压缩流的next事件。
    // 创建信号A
    RACSubject *signalA = [RACSubject subject];
    // 创建信号B
    RACSubject *signalB = [RACSubject subject];
    // 压缩成一个信号
    // **-zipWith-**: 当一个界面多个请求的时候，要等所有请求完成才更新UI
    // 等所有信号都发送内容的时候才会调用
    RACSignal *zipSignal = [signalA zipWith:signalB];
    [zipSignal subscribeNext:^(id x) {
        NSLog(@"%@", x); //所有的值都被包装成了元组
    }];

    // 发送信号 交互顺序，元组内元素的顺序不会变，跟发送的顺序无关，而是跟压缩的顺序有关[signalA zipWith:signalB]---先是A后是B
    [signalA sendNext:@1];
    [signalB sendNext:@2];

}
```
```
// 任何一个信号请求完成都会被订阅到
// merge:多个信号合并成一个信号，任何一个信号有新值就会调用
- (void)merge {
    // 创建信号A
    RACSubject *signalA = [RACSubject subject];
    // 创建信号B
    RACSubject *signalB = [RACSubject subject];
    //组合信号
    RACSignal *mergeSignal = [signalA merge:signalB];
    // 订阅信号
    [mergeSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号---交换位置则数据结果顺序也会交换
    [signalB sendNext:@"下部分"];
    [signalA sendNext:@"上部分"];
}
```
```
// then --- 使用需求：有两部分数据：想让上部分先进行网络请求但是过滤掉数据，然后进行下部分的，拿到下部分数据
- (void)then {
    // 创建信号A
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"----发送上部分请求---afn");

        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted]; // 必须要调用sendCompleted方法！
        return nil;
    }];

    // 创建信号B，
    RACSignal *signalsB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        NSLog(@"--发送下部分请求--afn");
        [subscriber sendNext:@"下部分数据"];
        return nil;
    }];
    // 创建组合信号
    // then;忽略掉第一个信号的所有值
    RACSignal *thenSignal = [signalA then:^RACSignal *{
        // 返回的信号就是要组合的信号
        return signalsB;
    }];

    // 订阅信号
    [thenSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];

}
```
```
// concat----- 使用需求：有两部分数据：想让上部分先执行，完了之后再让下部分执行（都可获取值）
- (void)concat {
    // 组合

    // 创建信号A
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        //        NSLog(@"----发送上部分请求---afn");

        [subscriber sendNext:@"上部分数据"];
        [subscriber sendCompleted]; // 必须要调用sendCompleted方法！
        return nil;
    }];

    // 创建信号B，
    RACSignal *signalsB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求
        //        NSLog(@"--发送下部分请求--afn");
        [subscriber sendNext:@"下部分数据"];
        return nil;
    }];


    // concat:按顺序去链接
    //**-注意-**：concat，第一个信号必须要调用sendCompleted
    // 创建组合信号
    RACSignal *concatSignal = [signalA concat:signalsB];
    // 订阅组合信号
    [concatSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];

}
```

## 7.RAC-常用宏
```
 // RAC:把一个对象的某个属性绑定一个信号,只要发出信号,就会把信号的内容给对象的属性赋值
    // 给label的text属性绑定了文本框改变的信号
    RAC(self.label, text) = self.textField.rac_textSignal;
//    [self.textField.rac_textSignal subscribeNext:^(id x) {
//        self.label.text = x;
//    }];
```
```
/**
 *  KVO
 *  RACObserveL:快速的监听某个对象的某个属性改变
 *  返回的是一个信号,对象的某个属性改变的信号
 */
 [RACObserve(self.view, center) subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
```
```
//例 textField输入的值赋值给label，监听label文字改变,
    RAC(self.label, text) = self.textField.rac_textSignal;
    [RACObserve(self.label, text) subscribeNext:^(id x) {
        NSLog(@"====label的文字变了");
    }];
```
```
/**
 *  循环引用问题
 */
 @weakify(self)
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        NSLog(@"%@",self.view);
        return nil;
    }];
    _signal = signal;
使用 @weakify(self)和@strongify(self)来避免循环引用
```
```
/**
 * 元祖
 * 快速包装一个元组
 * 把包装的类型放在宏的参数里面,就会自动包装
 */
 RACTuple *tuple = RACTuplePack(@1,@2,@4);
    // 宏的参数类型要和元祖中元素类型一致， 右边为要解析的元祖。
    RACTupleUnpack_(NSNumber *num1, NSNumber *num2, NSNumber * num3) = tuple;// 4.元祖
    // 快速包装一个元组
    // 把包装的类型放在宏的参数里面,就会自动包装
    NSLog(@"%@ %@ %@", num1, num2, num3);
```

## 8.RAC-过滤
```
// 跳跃 ： 如下，skip传入2 跳过前面两个值
// 实际用处： 在实际开发中比如 后台返回的数据前面几个没用，我们想跳跃过去，便可以用skip
 RACSubject *subject = [RACSubject subject];
    [[subject skip:2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
```
```
//distinctUntilChanged:-- 如果当前的值跟上一次的值一样，就不会被订阅到
    RACSubject *subject = [RACSubject subject];
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@2]; // 不会被订阅
```
```
// take:可以屏蔽一些值,去掉前面几个值---这里take为2 则只拿到前两个值
RACSubject *subject = [RACSubject subject];
    [[subject take:2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
```
```
//takeLast:和take的用法一样，不过他取的是最后的几个值，如下，则取的是最后两个值
//注意点:takeLast 一定要调用sendCompleted，告诉他发送完成了，这样才能取到最后的几个值
RACSubject *subject = [RACSubject subject];
    [[subject takeLast:2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject sendCompleted];
```
```
// takeUntil:---给takeUntil传的是哪个信号，那么当这个信号发送信号或sendCompleted，就不能再接受源信号的内容了。
 RACSubject *subject = [RACSubject subject];
    RACSubject *subject2 = [RACSubject subject];
    [[subject takeUntil:subject2] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject2 sendNext:@3];  // 1
//    [subject2 sendCompleted]; // 或2
    [subject sendNext:@4];
```
```
// ignore: 忽略掉一些值
 //ignore:忽略一些值
    //ignoreValues:表示忽略所有的值
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    // 2.忽略一些值
    RACSignal *ignoreSignal = [subject ignore:@2]; // ignoreValues:表示忽略所有的值
    // 3.订阅信号
    [ignoreSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 4.发送数据
    [subject sendNext:@2];
```
```
// 一般和文本框一起用，添加过滤条件
// 只有当文本框的内容长度大于5，才获取文本框里的内容
    [[self.textField.rac_textSignal filter:^BOOL(id value) {
        // value 源信号的内容
        return [value length] > 5;
        // 返回值 就是过滤条件。只有满足这个条件才能获取到内容
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
```

## 9.RAC-映射
- RAC的映射在实际开发中有什么用呢？比如我们想要拦截服务器返回的数据，给数据拼接特定的东西或想对数据进行操作从而更改返回值，类似于这样的情况下，我们便可以考虑用RAC的映射，实例代码如下

```
- (void)map {
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    // 绑定信号
    RACSignal *bindSignal = [subject map:^id(id value) {

        // 返回的类型就是你需要映射的值
        return [NSString stringWithFormat:@"ws:%@", value]; //这里将源信号发送的“123” 前面拼接了ws：
    }];
    // 订阅绑定信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    // 发送信号
    [subject sendNext:@"123"];
```
```
- (void)flatMap {
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    // 绑定信号
    RACSignal *bindSignal = [subject flattenMap:^RACStream *(id value) {
        // block：只要源信号发送内容就会调用
        // value: 就是源信号发送的内容
        // 返回信号用来包装成修改内容的值
        return [RACReturnSignal return:value];

    }];

    // flattenMap中返回的是什么信号，订阅的就是什么信号(那么，x的值等于value的值，如果我们操纵value的值那么x也会随之而变)
    // 订阅信号
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];

    // 发送数据
    [subject sendNext:@"123"];

}
```
```
- (void)flattenMap2 {
    // flattenMap 主要用于信号中的信号
    // 创建信号
    RACSubject *signalofSignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];

    // 订阅信号
    //方式1
    //    [signalofSignals subscribeNext:^(id x) {
    //
    //        [x subscribeNext:^(id x) {
    //            NSLog(@"%@", x);
    //        }];
    //    }];
    // 方式2
    //    [signalofSignals.switchToLatest  ];
    // 方式3
    //   RACSignal *bignSignal = [signalofSignals flattenMap:^RACStream *(id value) {
    //
    //        //value:就是源信号发送内容
    //        return value;
    //    }];
    //    [bignSignal subscribeNext:^(id x) {
    //        NSLog(@"%@", x);
    //    }];
    // 方式4--------也是开发中常用的
    [[signalofSignals flattenMap:^RACStream *(id value) {
        return value;
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];

    // 发送信号
    [signalofSignals sendNext:signal];
    [signal sendNext:@"123"];
}
```

## 10.RAC-bind
```
// 1.创建信号
    RACSubject *subject = [RACSubject subject];
    // 2.绑定信号
   RACSignal *bindSignal = [subject bind:^RACStreamBindBlock{
       // block调用时刻：只要绑定信号订阅就会调用。不做什么事情，
        return ^RACSignal *(id value, BOOL *stop){
            // 一般在这个block中做事 ，发数据的时候会来到这个block。
            // 只要源信号（subject）发送数据，就会调用block
            // block作用：处理源信号内容
            // value:源信号发送的内容，
            value = @3; // 如果在这里把value的值改了，那么订阅绑定信号的值即44行的x就变了
            NSLog(@"接受到源信号的内容：%@", value);
            //返回信号，不能为nil,如果非要返回空---则empty或 alloc init。
        return [RACReturnSignal return:value]; // 把返回的值包装成信号
        };
    }];

    // 3.订阅绑定信号
    [bindSignal subscribeNext:^(id x) {

        NSLog(@"接收到绑定信号处理完的信号:%@", x);
    }];
    // 4.发送信号
    [subject sendNext:@"123"];
```
> 
bind（绑定）的使用思想和Hook的一样---> 都是拦截API从而可以对数据进行操作，，而影响返回数据。
发送信号的时候会来到30行的block。在这个block里我们可以对数据进行一些操作，那么35行打印的value和订阅绑定信号后的value就会变了











