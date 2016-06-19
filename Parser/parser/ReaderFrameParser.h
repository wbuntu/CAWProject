//
//  ReaderFrameParser.h
//  parser
//
//  Created by wbuntu on 16/3/14.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReaderFrameParser : NSObject
+ (void)parseChapter:(NSString *)chapterPath toJSON:(NSString *)JSONPath withCid:(NSInteger)cid;
@end
