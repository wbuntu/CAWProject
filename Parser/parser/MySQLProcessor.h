//
//  MySQLProcessor.h
//  parser
//
//  Created by wbuntu on 16/3/15.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MySQLProcessor : NSObject
+ (void)insertInitialBookData;
+ (void)updateBookInfoData;
+ (void)insertBookInfo;
@end
