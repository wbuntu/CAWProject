//
//  bookModel.h
//  parser
//
//  Created by wbuntu on 16/3/14.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@protocol bookModel

@end

@interface bookModel : JSONModel
@property (nonatomic,assign) NSInteger bookid;
@property (nonatomic,assign) NSInteger sfid;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *rating;
@property (nonatomic,strong) NSString *sort;
@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSString *author;
@property (nonatomic,strong) NSString *wordcount;
@property (nonatomic,strong) NSString *clickcount;
@property (nonatomic,strong) NSString *updatetime;
@property (nonatomic,strong) NSString *intro;
@property (nonatomic,strong) NSString *subIntro;
@property (nonatomic,strong) NSString *cellIntro;
@property (nonatomic,assign) NSUInteger numberOfLines;
@property (nonatomic,assign) NSUInteger numberOfCellIntroLines;
@property (nonatomic,strong) NSString *tags;
@property (nonatomic,strong) NSString *cover;
@end