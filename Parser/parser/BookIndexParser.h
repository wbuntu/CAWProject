//
//  BookIndexParser.h
//  parser
//
//  Created by wbuntu on 16/3/26.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookIndexParser : NSObject
+ (void)parseBookIndex:(NSString *)bookIndexPath toJSON:(NSString *)JSONPath withSFID:(NSInteger)sfid bookID:(NSInteger)bookId;
@end
