//
//  JSONDownloader.m
//  parser
//
//  Created by wbuntu on 16/3/15.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import "JSONDownloader.h"

@implementation JSONDownloader
+ (void)downloadJPLatest
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer  = [AFHTTPRequestSerializer serializer];
    int i = 0;
    while (i<492) {
        NSString *index = [@(i) stringValue];
        NSDictionary *dic = @{@"op":@"jpnovels",
                              @"index":index,
                              @"listype":@"latest",
                              @"_":@"1458034097484"};
    
        [manager GET:@"http://m.sfacg.com/API/HTML5.ashx" parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            str = [str stringByRemovingPercentEncoding];
            NSLog(@"%@",str);
            if (str.length < 40) {
                NSLog(@"%d %@",i,str);
            }
            NSError *err;
            [str writeToFile:[NSString stringWithFormat:@"jp%d.txt",i] atomically:YES encoding:NSUTF8StringEncoding error:&err];
            NSLog(@"write %d",i);
            if (err)
                NSLog(@"%@",err);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
        i++;
    }
}
+ (void)downloadLatest
{
//    NSMutableArray *tA = [NSMutableArray array];
//    for (int i=0; i<492; i++) {
//        NSString *file = [NSString stringWithFormat:@"jp%d.txt",i];
//        BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:file];
//        if (!exist) {
//            NSLog(@"%d",i);
//            [tA addObject:@(i)];
//        }
//    }
//    NSLog(@"count %lu",(unsigned long)tA.count);
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer  = [AFHTTPRequestSerializer serializer];
    int i = 0;
    while (i<492) {
        NSString *index = [@(i) stringValue];
        NSDictionary *dic = @{@"index":index,
                              @"_":@"0"};
        [manager GET:@"http://m.sfacg.com/API/HTML5.ashx?op=latest" parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            str = [str stringByRemovingPercentEncoding];
            NSError *err;
            [str writeToFile:[NSString stringWithFormat:@"%d.txt",i] atomically:YES encoding:NSUTF8StringEncoding error:&err];
            NSLog(@"%d",i);
            if (err)
                NSLog(@"%@",err);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
        i++;
    }
}
@end
