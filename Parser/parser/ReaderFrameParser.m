//
//  ReaderFrameParser.m
//  parser
//
//  Created by wbuntu on 16/3/14.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import "ReaderFrameParser.h"
#import "chapterModel.h"
#import <AppKit/AppKit.h>
@implementation ReaderFrameParser
+ (void)parseChapter:(NSString *)chapterPath toJSON:(NSString *)JSONPath withCid:(NSInteger)cid
{
    @autoreleasepool {
        //初始化文档与节点
        NSError *err;
        NSData *data = [NSData dataWithContentsOfFile:chapterPath];
        ONOXMLDocument * doc= [ONOXMLDocument HTMLDocumentWithData:data
                                                             error:&err];
        if (err)
        {
            NSLog(@"%@",err);
        }
        ONOXMLElement *page = [doc.rootElement firstChildWithXPath:@"/html/body/div[@id='page']"];
        ONOXMLElement *menuTop = [page firstChildWithTag:@"ul"];
        ONOXMLElement *yuedu = [page firstChildWithTag:@"div"];
        if (!menuTop) {
            return;
        }
        ONOXMLElement *yueduMenu = [yuedu firstChildWithXPath:@"ul[@class='yuedu_menu']"];
        //抽取标题和对应书本的sfid
        NSString *title = [menuTop firstChildWithXPath:@"li[2]"].stringValue;
        
        //抽取上一章，下一章，目录等id
        NSArray<ONOXMLElement*> *tempArray = [yueduMenu childrenWithTag:@"a"];
        NSString *previous = [tempArray[0] valueForAttribute:@"href"];
        NSString *index = [tempArray[1] valueForAttribute:@"href"];
        NSString *next = [tempArray[2] valueForAttribute:@"href"];
        if ([previous isEqualToString:index])
        {
            previous = @"header";
        }
        else
        {
            previous = [[previous componentsSeparatedByString:@"/"] lastObject];
        }
        
        if ([next isEqualToString:index])
        {
            next = @"footer";
        }
        else
        {
            next = [[next componentsSeparatedByString:@"/"] lastObject];
        }
        
        index = [[index componentsSeparatedByString:@"/"] lastObject];
        //抽取文本内容
        NSMutableArray<NSString*> *content = [NSMutableArray<NSString *> new];
        NSMutableArray<imageModel> *images = [NSMutableArray<imageModel> new];
        [yuedu enumerateElementsWithXPath:@"p|img" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
            NSString *tag = element.tag;
            if ([tag isEqualToString:@"p"]) {
                [content addObject:element.stringValue];
            }
            else if ([tag isEqualToString:@"img"]){
                NSString *src = [element valueForAttribute:@"src"];
                NSString *im = [[src componentsSeparatedByString:@"/"] lastObject];
                NSString *temp = [NSString stringWithFormat:@"chapter-%@-%@",@(cid),im];
                NSString *temp2 = [NSString stringWithFormat:@"/Users/wbuntu/CAWReader/fullImages/%@",temp];
                if ([[NSFileManager defaultManager] fileExistsAtPath:temp2]) {
                    NSImage *image =  [[NSImage alloc] initWithContentsOfFile:temp2];
                    if (image) {
                        imageModel *mo = [imageModel new];
                        mo.imageName = temp;
                        NSImageRep *rep = [[image representations] firstObject];
                        mo.width = ceilf(rep.pixelsWide);
                        mo.height = ceilf(rep.pixelsHigh);
                        [content addObject:temp];
                        [images addObject:mo];
                    }
                }
            }
        }];
        chapterModel *model = [chapterModel new];
        model.cid = cid;
        model.title = title;
        model.previous = previous;
        model.index = index;
        model.next = next;
        model.content = content;
        model.images = images;
        [model.toJSONString writeToFile:JSONPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"%@",@(cid));
    }
}
@end
