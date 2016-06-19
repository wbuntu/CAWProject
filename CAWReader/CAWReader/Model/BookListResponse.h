//
//  BookListResponse.h
//  CAWReader
//
//  Created by wbuntu on 4/3/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

#import "BaseResponse.h"
#import "bookModel.h"
@interface BookListResponse : BaseResponse
@property (nonatomic,strong) NSArray<bookModel> *data;
@end
