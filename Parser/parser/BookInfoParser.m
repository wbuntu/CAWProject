//
//  BookInfoParser.m
//  parser
//
//  Created by wbuntu on 16/3/14.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import "BookInfoParser.h"

@implementation BookInfoParser
+ (void)parseBook:(NSString *)bookPath toJSON:(NSString *)JSONPath withSFID:(NSInteger)sfid bookID:(NSInteger)bookId
{
    NSData *data = [NSData dataWithContentsOfFile:bookPath];
    ONOXMLDocument * doc= [ONOXMLDocument HTMLDocumentWithData:data
                                                         error:nil];
    ONOXMLElement *bookInfo = [doc.rootElement firstChildWithXPath:@"/html/body/div[@id='page']/div[@class='Content_Frame']/ul[@class='book_info']"];
    ONOXMLElement *ele = [bookInfo firstChildWithXPath:@"li[1]/span[@class='book_newtitle']"];
    NSString *title = ele.stringValue;
    
    ele = [bookInfo firstChildWithXPath:@"li[1]/div[@class='star-rating rating-xs rating-active']/div/div"];
    NSString *style = [ele valueForAttribute:@"style"];
    style = [style substringWithRange:NSMakeRange(7, 2)];
    NSString *rating = [NSString stringWithFormat:@"%.1f",[style floatValue]/10];
    
    ele = [bookInfo firstChildWithXPath:@"li[1]/div[@class='book_info2']"];
    NSArray<ONOXMLElement*> *tempArray = [ele childrenWithTag:@"span"];
    NSString *sort = tempArray[0].stringValue;
    NSString *status  = tempArray[1].stringValue;
    
    ele = [bookInfo firstChildWithXPath:@"li[1]/span[@class='book_info3']"];
    NSString *stringValue = ele.stringValue;
    NSString *updatetime = [stringValue substringFromIndex:stringValue.length-14];
    
    NSString *other = [[stringValue substringToIndex:stringValue.length-14] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *arr = [other componentsSeparatedByString:@"/"];
    NSString *author = arr[0];
    NSString *wordcount = arr[1];
    NSString *clickCount = arr[2];
    
    ele = [bookInfo firstChildWithXPath:@"li[2]/img"];
    NSString *cover = [ele valueForAttribute:@"src"];
    
    ele = [doc.rootElement firstChildWithXPath:@"/html/body/div[2]/div[2]/ul/li[2]"];
    NSString *intro = ele.stringValue;
    
    ele = [doc.rootElement firstChildWithXPath:@"/html/body/div[2]/div[2]/ul/li[3]"];
    NSArray *tArr = [ele childrenWithTag:@"span"];
    NSMutableArray<NSString*> *tagArray = [NSMutableArray new];
    for (ONOXMLElement *e in tArr) {
        [tagArray addObject:e.stringValue];
    }
    NSString *tags = [tagArray componentsJoinedByString:@","];
    
    bookModel *book = [bookModel new];
    book.bookid = bookId;
    book.sfid = sfid;
    book.title = title;
    book.rating = rating;
    book.sort = sort;
    book.status = status;
    book.updatetime = updatetime;
    book.author = author;
    book.wordcount = wordcount;
    book.clickcount = clickCount;
    book.cover = cover;
    book.intro = intro;
    book.tags = tags;
    [book.toJSONString writeToFile:JSONPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"complete book %@",@(sfid));
}
@end;
