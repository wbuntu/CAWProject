//
//  LiabraryIndexResponse.h
//  CAWReader
//
//  Created by wbuntu on 5/9/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

#import "BaseResponse.h"
#import "bookModel.h"

@interface LiabraryIndexResponseComponent : JSONModel
@property (nonatomic,strong) NSArray<bookModel> *hot;
@property (nonatomic,strong) NSArray<bookModel> *recommend;
@property (nonatomic,strong) NSArray<bookModel> *complete;
@end

@interface LiabraryIndexResponse : BaseResponse
@property (nonatomic,strong) LiabraryIndexResponseComponent *data;
@end
