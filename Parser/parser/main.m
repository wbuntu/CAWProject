//
//  main.m
//  parser
//
//  Created by cygnuswu on 16/3/14.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MySQLProcessor.h"
#import "JSONDownloader.h"
#import "BookInfoParser.h"
#import "ReaderFrameParser.h"
#import "BookIndexParser.h"
#import "chapterModel.h"
#import <AppKit/AppKit.h>
int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        NSFileManager *manager = [NSFileManager defaultManager];
//        NSOperationQueue *queue = [NSOperationQueue new];
//        queue.maxConcurrentOperationCount = 512;
//        for (int i=94048; i<641281; i++) {
//            NSString *temp2 = [NSString stringWithFormat:@"/Users/wbuntu/CAWReader/renewContentJSON/%d.json",i];
//            NSString *temp = [NSString stringWithFormat:@"/Users/wbuntu/CAWReader/content/%d.html",i];
//            if ([manager fileExistsAtPath:temp]) {
//                [queue addOperationWithBlock:^{
//                        [ReaderFrameParser parseChapter:temp toJSON:temp2 withCid:i];
//                }];
//            }
//        }
    }
    [[NSRunLoop currentRunLoop] run];
    return 0;
}
