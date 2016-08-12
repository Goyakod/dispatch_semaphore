//
//  ViewController.m
//  barrierDemo
//
//  Created by pro on 16/8/11.
//  Copyright © 2016年 goyakod. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionTaskDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)request
{
    
    NSURLSession * mySession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    /**
     *  随便写一个请求地址,以下是我胡诌的
     */
    NSURL *url = [NSURL URLWithString:@"https://123.234.98.1/dgsa/12rsdgdsg"];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    request.HTTPMethod= @"POST";
    
    [request addValue:@"application/x-www-form-urlencoded"forHTTPHeaderField:@"Content-Type"];
    
    /**
     *  你的请求参数，以下是我胡诌的
     */
    NSString * paramStr = @"username=******&password=******";
    
    request.HTTPBody= [paramStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *task = [mySession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            
            NSLog(@"request");
            
        }else{
            NSLog(@"request error:%@----",error.description);
        }
        
    }];
    
    [task resume];

}

- (void)getToken:(dispatch_semaphore_t)semaphore
{
    
    NSURLSession * mySession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    /**
     *  随便写一个请求地址,以下是我胡诌的
     */
    NSURL *url = [NSURL URLWithString:@"https://123.234.98.1/dgsa/12rsdgdsg"];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    
    request.HTTPMethod= @"POST";
    
    [request addValue:@"application/x-www-form-urlencoded"forHTTPHeaderField:@"Content-Type"];
    /**
     *  你的请求参数，以下是我胡诌的
     */
    NSString * paramStr = @"username=******&password=******";
    
    request.HTTPBody= [paramStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *task = [mySession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            
            NSLog(@"get Token");
            //发送信号量:
            dispatch_semaphore_signal(semaphore);
            
        }else{
            NSLog(@"token error:%@",error.description);
        }
        
    }];
    
    [task resume];
    
}

- (IBAction)buttonPress:(UIButton *)sender
{
    dispatch_queue_t queque = dispatch_queue_create("GoyakodCreated", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queque, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [self getToken:semaphore];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [self request];
    });
    
    NSLog(@"main thread");
}

#pragma mark - NSURLSessionTaskDelegate
//只要请求的地址是HTTPS的, 就会调用这个代理方法
//challenge:质询
//NSURLAuthenticationMethodServerTrust:服务器信任
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if (![challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) return;
    /*
     NSURLSessionAuthChallengeUseCredential 使用证书
     NSURLSessionAuthChallengePerformDefaultHandling  忽略证书 默认的做法
     NSURLSessionAuthChallengeCancelAuthenticationChallenge 取消请求,忽略证书
     NSURLSessionAuthChallengeRejectProtectionSpace 拒绝,忽略证书
     */
    
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}


@end
