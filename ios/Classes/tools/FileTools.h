#import <Foundation/Foundation.h>

@interface FileTools : NSObject

// 获取文件或文件夹大小
+ (NSString *)getFilePathSize:(NSString *)props;


// 解压文件
+ (NSString *)unZipFile:(NSString *)props;

@end


