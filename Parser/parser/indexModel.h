//
//  indexModel.h
//  parser
//
//  Created by wbuntu on 16/3/25.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol vChapter @end
@protocol volumeModel @end

@interface vChapter : JSONModel
@property (nonatomic,strong) NSString *chapterTitle;
@property (nonatomic,strong) NSString *chapterId;
@end

@interface volumeModel : JSONModel
@property (nonatomic,strong) NSString *volumeTitle;
@property (nonatomic,strong) NSArray<vChapter> *chapters;
@end

@interface indexModel : JSONModel
@property (nonatomic,assign) NSInteger bookid;
@property (nonatomic,assign) NSInteger sfid;
@property (nonatomic,strong) NSArray<volumeModel> *volumes;
@end
