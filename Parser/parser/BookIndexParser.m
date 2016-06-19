//
//  BookIndexParser.m
//  parser
//
//  Created by wbuntu on 16/3/26.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import "BookIndexParser.h"
#import "indexModel.h"
@implementation BookIndexParser
+ (void)parseBookIndex:(NSString *)bookIndexPath toJSON:(NSString *)JSONPath withSFID:(NSInteger)sfid bookID:(NSInteger)bookId
{
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfFile:bookIndexPath];
        ONOXMLDocument * doc= [ONOXMLDocument HTMLDocumentWithData:data
                                                             error:nil];
        ONOXMLElement *page = [doc.rootElement firstChildWithXPath:@"/html/body/div[@id='page']"];
        NSArray<ONOXMLElement *> *arr = [page childrenWithTag:@"div"];
        indexModel *index = [indexModel new];
        index.sfid = sfid;
        index.bookid = bookId;
        NSMutableArray<volumeModel> *volumes = [NSMutableArray<volumeModel> new];
        for (int i=0;i<arr.count;i+=2) {
            volumeModel *volume = [volumeModel new];
            
            ONOXMLElement *e = arr[i];
            NSString *title = e.stringValue;
            volume.volumeTitle = title;
            
            e = arr[i+1];
            NSMutableArray<vChapter> *chapters = [NSMutableArray<vChapter> new];
            ONOXMLElement *ul = [e firstChildWithTag:@"ul"];
            NSArray<ONOXMLElement *> *tempArray = [ul childrenWithTag:@"a"];
            for (ONOXMLElement *a in tempArray) {
                vChapter *chapter = [vChapter new];
                
                NSString *href = [a valueForAttribute:@"href"];
                NSString *chapterId = [[href componentsSeparatedByString:@"/"] objectAtIndex:2];
                chapter.chapterId = chapterId;
                
                ONOXMLElement *li = [a firstChildWithTag:@"li"];
                NSString *chapterTitle = li.stringValue;
                chapter.chapterTitle = chapterTitle;
                [chapters addObject:chapter];
            }
            volume.chapters = [chapters copy];
            [volumes addObject:volume];
        }
        index.volumes = [volumes copy];
        [index.toJSONString writeToFile:JSONPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"complete index %@",@(sfid));
    }
}
@end
