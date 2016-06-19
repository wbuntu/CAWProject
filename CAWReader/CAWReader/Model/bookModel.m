//
//  bookModel.m
//  parser
//
//  Created by wbuntu on 16/3/14.
//  Copyright © 2016年 wbuntu. All rights reserved.
//

#import "bookModel.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
@implementation bookModel
- (NSString *)subIntro
{
    if (!_subIntro) {
        if (!_intro) {
            return nil;
        }else{
            NSString *temp = [_intro stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (temp.length == 0) {
                return nil;
            }
        }
        UIFont *font = [UIFont systemFontOfSize:16];
        NSMutableParagraphStyle *paragraphStyles = [[NSMutableParagraphStyle alloc] init];
        paragraphStyles.firstLineHeadIndent = font.pointSize
        ;
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 100;
        NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyles,
                                                     NSFontAttributeName:font};
        NSAttributedString *attStr = [[NSAttributedString alloc]initWithString:_intro attributes:attributes];
        CGRect textFrame = CGRectMake(0, 0, width, MAXFLOAT);
        CFAttributedStringRef cfAttStr = (__bridge CFAttributedStringRef)attStr;
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(cfAttStr);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textFrame);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        NSArray *lines = (NSArray*)CTFrameGetLines(frame);
        _numberOfLines = lines.count;
        if (lines.count > 6) {
            id line = lines[5];
            CTLineRef lineRef = (__bridge CTLineRef)line;
            CFRange ra = CTLineGetStringRange(lineRef);
            _subIntro = [_intro substringWithRange:NSMakeRange(0, ra.location+ra.length-2)];
            _subIntro = [_subIntro stringByAppendingString:@"..."];
        }
        else{
            _subIntro = _intro;
        }
        CFRelease(frame);
        CGPathRelease(path);
        CFRelease(framesetter);
    }
    return _subIntro;
}
- (NSString *)cellIntro
{
    if (!_cellIntro) {
        if (!_intro) {
            return nil;
        }else{
            NSString *temp = [_intro stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (temp.length == 0) {
                return nil;
            }
        }
        UIFont *font = [UIFont systemFontOfSize:16];
        NSMutableParagraphStyle *paragraphStyles = [[NSMutableParagraphStyle alloc] init];
        paragraphStyles.firstLineHeadIndent = font.pointSize
        ;
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 8;
        NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyles,
                                     NSFontAttributeName:font};
        NSAttributedString *attStr = [[NSAttributedString alloc]initWithString:_intro attributes:attributes];
        CGRect textFrame = CGRectMake(0, 0, width, MAXFLOAT);
        CFAttributedStringRef cfAttStr = (__bridge CFAttributedStringRef)attStr;
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(cfAttStr);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, textFrame);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        NSArray *lines = (NSArray*)CTFrameGetLines(frame);
        _numberOfCellIntroLines = lines.count;
        if (lines.count > 5) {
            id line = lines[4];
            CTLineRef lineRef = (__bridge CTLineRef)line;
            CFRange ra = CTLineGetStringRange(lineRef);
            _cellIntro = [_intro substringWithRange:NSMakeRange(0, ra.location+ra.length-2)];
            _cellIntro = [_cellIntro stringByAppendingString:@"..."];
        }
        else{
            _cellIntro = _intro;
        }
        CFRelease(frame);
        CGPathRelease(path);
        CFRelease(framesetter);
    }
    return _cellIntro;
}
- (BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    bookModel *book = (bookModel *)object;
    if (self.bookid == book.bookid){
        return YES;
    }
    
    return NO;
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end
