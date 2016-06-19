//
//  chapterModel.h
//  parser
//
//  Created by wbuntu on 16/3/25.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@interface imageModel : JSONModel
@property (nonatomic,strong) NSString *imageName;
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;
@end

@protocol imageModel @end
@interface chapterModel : JSONModel
@property (nonatomic,assign) NSInteger cid;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *previous;
@property (nonatomic,strong) NSString *index;
@property (nonatomic,strong) NSString *next;
@property (nonatomic,strong) NSArray<NSString *> *content;
@property (nonatomic,strong) NSArray<imageModel> *images;
@end