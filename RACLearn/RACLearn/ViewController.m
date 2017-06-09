//
//  ViewController.m
//  RACLearn
//
//  Created by qinfensky on 2016/10/26.
//  Copyright © 2016年 qinfensky. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "TowViewController.h"
#import "RACReturnSignal.h"
#import "LoginVM.h"

@interface ViewController ()

@property (strong, nonatomic) RACCommand *command;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (assign, nonatomic) int value;
@property (weak, nonatomic) IBOutlet UITextField *loginTF;
@property (weak, nonatomic) IBOutlet UITextField *pswTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBTN;
@property (strong, nonatomic) LoginVM *loginVM;

@end

@implementation ViewController
@synthesize command;

#pragma mark: - getter and setter
- (LoginVM *)loginVM {
    if (!_loginVM) {
        _loginVM = [[LoginVM alloc] init];
    }
    return _loginVM;
}

#pragma mark: - lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindMD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark: - private Methods
- (void)bindMD {
    
    RAC(self.loginVM.account, account) = self.loginTF.rac_textSignal;
    RAC(self.loginVM.account, psw) = self.pswTF.rac_textSignal;
    RAC(self.loginBTN, enabled) = self.loginVM.loginEnableSignal;
    @weakify(self);
    [[self.loginBTN rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.loginVM.loginCommand execute:nil];
    }];
    
}


- (void)test {
    //    [self siganlTest];
    //    [self subjectTest];
    //    [self replaySubjectTest];
    //    [self sequenceAndTupleTest];
    //    [self commandTest];
    //    [self muticasConnectionTest];
    //    [self liftSignalsTest];
    //    [self RACTest];
    //    [self singnalOfSingalsTest];
    //    [self concatTest];
    //    [self thenTest];
    //    [self mergeTest];
    //    [self zipTest];
    //    [self combineLatestTest];
    //    [self reduceTest];
    //    [self filterTest];
    //    [self ignoreTest];
    //    [self distinctUntilChangeTest];
    //    [self takeAndTakeLastTest];
    //    [self orderTest];
    //    [self timeOutTest];
    //    [self intervalTest];
    //    [self delayTest];
    //    [self retryTest];
    //    [self replayTest];
    //    [self throttleTest];
}

- (void)throttleTest {
    [[self.textField.rac_textSignal throttle:2] subscribeNext:^(id x) {
        NSLog(@"已过两秒间隔:%@", x);
    }];
}

- (void)replayTest {
    
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendNext:@"2"];
        return nil;
    }] replay];
    [signal subscribeNext:^(id x) {
        NSLog(@"第一个订阅：%@", x);
    }];
    [signal subscribeNext:^(id x) {
        NSLog(@"第二个订阅：%@", x);
    }];
    
}

- (void)retryTest {
    
    __block int i = 0;
    
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (i == 10) {
            [subscriber sendNext:@(i)];
        } else {
            [subscriber sendError:nil];
            i ++;
        }
        return nil;
    }] retry] subscribeNext:^(id x) {
        NSLog(@"当前值为正确%@", x);
    } ];
    
}

- (void)delayTest {
    
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1"];
        [subscriber sendCompleted];
        return nil;
    }] delay:2] subscribeNext:^(id x) {
        NSLog(@"已经延时两秒输出信号%@", x);
    }];
    
}

- (void)intervalTest {
    
    [[RACSignal interval:1 onScheduler:[RACScheduler currentScheduler]] subscribeNext:^(id x) {
        NSLog(@"每隔一秒调用一次：%@", x);
    }];
    
}

- (void)timeOutTest {
    
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return nil;
    }] timeout:3 onScheduler:[RACScheduler currentScheduler]]
    subscribeNext:^(id x) {
        NSLog(@"信号传递完毕%@", x);
    } error:^(NSError *error) {
        NSLog(@"信号传递错误%@", [error localizedDescription]);
    }];
    
}

- (void)orderTest {
    
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第一次信号发送"];
        [subscriber sendCompleted];
        return nil;
    }] doNext:^(id x) {
        NSLog(@"信号发送前准备");
    }] doCompleted:^{
        NSLog(@"信号发送即将完毕");
    }] subscribeNext:^(id x) {
        NSLog(@"信号内容:%@", x);
    }];
    
}

- (void)takeAndTakeLastTest {
    
    RACSubject *signal = [RACSubject subject];
    [[signal take:2] subscribeNext:^(id x) {
        NSLog(@"信号取前两次%@", x);
    }];
    [[signal takeLast:2] subscribeNext:^(id x) {
        NSLog(@"信号取最后两次%@", x);
    }];
    [[signal skip:1] subscribeNext:^(id x) {
        NSLog(@"信号跳过第一次%@", x);
    }];
    [signal sendNext:@"第一次"];
    [signal sendNext:@"第二次"];
    [signal sendNext:@"第三次"];
    [signal sendCompleted];
    
    [[self.textField.rac_textSignal takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
       NSLog(@"信号一直获取到当前对象销毁%@", x);
    }];
}

- (void)distinctUntilChangeTest {
    
    [[self.textField.rac_textSignal distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"值已经明显改变:%@", x);
    }];
    
}

- (void)ignoreTest {
    [[self.textField.rac_textSignal ignore:@"3"] subscribeNext:^(id x) {
        NSLog(@"当前值已忽略3：%@", x);
    }];
}

- (void)filterTest {
    [[self.textField.rac_textSignal filter:^BOOL(NSString *value) {
        return value.length > 5;
    }] subscribeNext:^(id x) {
        NSLog(@"长度已经大于5");
    }];;
}

- (void)reduceTest {
    
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
}

- (void)combineLatestTest {
    
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
    
}

- (void)zipTest {
    
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
    
}

- (void)mergeTest {
    
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
    
}

- (void)thenTest {
    
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
    
}

- (void)concatTest {
    
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
    
    
}

- (void)singnalOfSingalsTest {
    // 信号中的信号
    
    RACSubject *signalOfsignal = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    [[signalOfsignal flattenMap:^RACStream *(id value) {
        return value;
    }] subscribeNext:^(id x) {
        NSLog(@"信号中的信号发出数据：%@",  x);
    }];
    [signalOfsignal sendNext:signal];
    [signal sendNext:@"信号爆炸"];

}

- (void)RACTest {
    // 用于给某个对象的某个属性绑定。
    RAC(self.label, text) = self.textField.rac_textSignal;
    [RACObserve(self, value) subscribeNext:^(id x) {
        NSLog(@"值改变了：%@",x);
    }];
    self.value = 10;
    self.value = 45;
    
    
    RACTuple *tuple = RACTuplePack(@"x1", @"y1");
    RACTupleUnpack(NSString *v1, NSString *v2) = tuple;
    NSLog(@"v1：%@, v2:%@ ", v1, v2);
    
    // bind方法使用步骤:
    // 1.传入一个返回值RACStreamBindBlock的block。
    // 2.描述一个RACStreamBindBlock类型的bindBlock作为block的返回值。
    // 3.描述一个返回结果的信号，作为bindBlock的返回值。
    // 注意：在bindBlock中做信号结果的处理。
    [[self.textField.rac_textSignal bind:^RACStreamBindBlock{
        return ^RACStream *(id value, BOOL *stop) {
            return [RACReturnSignal return:[NSString stringWithFormat:@"加强输出：%@", value]];
        };
        
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    [[self.textField.rac_textSignal flattenMap:^RACStream *(id value) {
        return [RACReturnSignal return:[NSString stringWithFormat:@"第二种加强方式输出%@", value]];
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    [[self.textField.rac_textSignal map:^id(id value) {
        return [NSString stringWithFormat:@"第三种加强方式输出%@",value];
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    [[[self.textField.rac_textSignal skip:1] map:^id(id value) {
        return [NSString stringWithFormat:@"第四种加强方式输出（跳过第一次信号）%@",value];
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    
}

- (void)liftSignalsTest {
    
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"请求1"];
            [subscriber sendCompleted];
        });
        
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"请求2"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    [self rac_liftSelector:@selector(updateData:withData2:) withSignalsFromArray:@[signal1, signal2]];
    
}

- (void)updateData:(id)data1 withData2:(id)data2 {
    NSLog(@"数据接收完毕:data1%@, data2%@",data1, data2);
}

- (void)muticasConnectionTest {
    // RACMulticastConnection使用步骤:
    // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
    // 2.创建连接 RACMulticastConnection *connect = [signal publish];
    // 3.订阅信号,注意：订阅的不在是之前的信号，而是连接的信号。 [connect.signal subscribeNext:nextBlock]
    // 4.连接 [connect connect]
    
    // RACMulticastConnection底层原理:
    // 1.创建connect，connect.sourceSignal -> RACSignal(原始信号)  connect.signal -> RACSubject
    // 2.订阅connect.signal，会调用RACSubject的subscribeNext，创建订阅者，而且把订阅者保存起来，不会执行block。
    // 3.[connect connect]内部会订阅RACSignal(原始信号)，并且订阅者是RACSubject
    // 3.1.订阅原始信号，就会调用原始信号中的didSubscribe
    // 3.2 didSubscribe，拿到订阅者调用sendNext，其实是调用RACSubject的sendNext
    // 4.RACSubject的sendNext,会遍历RACSubject所有订阅者发送信号。
    // 4.1 因为刚刚第二步，都是在订阅RACSubject，因此会拿到第二步所有的订阅者，调用他们的nextBlock
    
    
    // 需求：假设在一个信号中发送请求，每次订阅一次都会发送请求，这样就会导致多次请求。
    // 解决：使用RACMulticastConnection就能解决.
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求");
        [subscriber sendNext:@"请求成功"];
        return nil;
    }];
    
    RACMulticastConnection *connect = [signal publish];
    // 3.订阅信号，
    // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"第一次接受数据:%@", x);
    }];
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"第二次接受数据:%@", x);
    }];
    [connect connect];
    
    
}

- (void)commandTest {
    // 一、RACCommand使用步骤:
    // 1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
    // 2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
    // 3.执行命令 - (RACSignal *)execute:(id)input
    
    // 二、RACCommand使用注意:
    // 1.signalBlock必须要返回一个信号，不能传nil.
    // 2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
    // 3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
    // 4.RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的。
    
    // 三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
    // 1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
    // 2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。
    
    // 四、如何拿到RACCommand中返回信号发出的数据。
    // 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
    // 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
    
    // 五、监听当前命令是否正在执行executing
    
    // 六、使用场景,监听按钮点击，网络请求
    
    // 1.创建命令
    command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"执行命令");
        
        // 创建空信号,必须返回信号
        //        return [RACSignal empty];
        
        // 2.创建信号,用来传递数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            [subscriber sendNext:@"请求数据"];
            
            // 注意：数据传递完，最好调用sendCompleted，这时命令才执行完毕。
            [subscriber sendCompleted];
            
            return nil;
        }];
        
    }];

    // 3.订阅RACCommand中的信号
    [command.executionSignals subscribeNext:^(id x) {
        [x subscribeNext:^(id x) {
            NSLog(@"第一个接受者：%@", x);
        }];
    }];
    // 高级写法
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"第二个接受者：%@", x);
    }];
     // 4.监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
    [[command.executing skip:1] subscribeNext:^(id x) {
        if ([x boolValue]) {
            NSLog(@"执行中%@", x);
        } else {
            NSLog(@"执行完毕%@", x);
        }
    }];
    
    [command execute:@"任务开始"];
    
}

- (void)sequenceAndTupleTest {
    
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
    
    
    
    NSDictionary *dict = @{@"一":@"1",@"二":@"2",@"三":@"3",@"四":@"4",@"五":@"5"};
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(NSString *key, NSString *value) = x;
        NSLog(@"遍历字典：key:%@, value:%@", key, value);
    }];
    
}

- (IBAction)gotoTowVC:(id)sender {
    
    TowViewController *VC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"TowViewController"];
    // KVO
    [[VC rac_valuesAndChangesForKeyPath:@"delegateSignal" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
        NSLog(@"delegate 已经指定");
    }];;
    VC.delegateSignal = [RACSubject subject];
    [VC.delegateSignal subscribeNext:^(id x) {
        NSLog(@"第二个控制器点击了通知按钮%@", x);
    }];
    [self presentViewController:VC animated:YES completion:^{
        
    }];
    // 代替代理
    [[VC rac_signalForSelector:@selector(noticeClick:)] subscribeNext:^(id x) {
        NSLog(@"第二种方式监听按钮点击了");
    }];
    
}

- (void)replaySubjectTest {
    // RACReplaySubject使用步骤:
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.可以先订阅信号，也可以先发送信号。
    // 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 2.2 发送信号 sendNext:(id)value
    
    // RACReplaySubject:底层实现和RACSubject不一样。
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    // 也就是先保存值，在订阅值。
    
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    [replaySubject sendNext:@"第一次信号来咯"];
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者：%@", x);
    }];
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者 %@", x);
    }];
    [replaySubject sendNext:@"第二次信号来咯"];
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第三个订阅者 %@", x);
    }];
    [replaySubject sendNext:@"第三次信号来咯"];
}

- (void)subjectTest {
    // RACSubject使用步骤
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 3.发送信号 sendNext:(id)value
    
    // RACSubject:底层实现和RACSignal不一样。
    // 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
    // 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    
    RACSubject *subject = [RACSubject subject];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者:%@", x);
    }];
    [subject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者:%@", x);
    }];
    [subject sendNext:@"信号来咯"];
}


- (void)siganlTest {
    // RACSignal使用步骤：
    // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
    // 2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 3.发送信号 - (void)sendNext:(id)value
    
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"第一次信号"];
        [subscriber sendNext:@"第二次信号"];
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"信号销毁");
        }];
    }];
    
    [signal subscribeNext:^(NSString *x) {
        NSLog(@"收到了信号内容:%@", x);
    }];
    
    
}




@end
