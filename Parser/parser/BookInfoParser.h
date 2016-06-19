//
//  BookInfoParser.h
//  parser
//
//  Created by wbuntu on 16/3/14.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookInfoParser : NSObject
+ (void)parseBook:(NSString *)bookPath toJSON:(NSString *)JSONPath withSFID:(NSInteger)sfid bookID:(NSInteger)bookId;
@end
