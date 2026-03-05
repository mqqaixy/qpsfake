#import <UIKit/UIKit.h>

%hook UIApplication

- (void)_run {
    %orig;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注入成功"
                                                                   message:@"插件已加载！"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

%end
