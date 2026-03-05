#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

static double fakeLat = 39.9042;
static double fakeLng = 116.4074;
static BOOL spoofingEnabled = NO;

%hook CLLocation

- (CLLocationCoordinate2D)coordinate {
    if (spoofingEnabled) {
        CLLocationCoordinate2D coord;
        coord.latitude = fakeLat;
        coord.longitude = fakeLng;
        return coord;
    }
    return %orig;
}

- (double)latitude  { return spoofingEnabled ? fakeLat  : %orig; }
- (double)longitude { return spoofingEnabled ? fakeLng : %orig; }

%end

%hook UIWindow

- (void)becomeKeyWindow {
    %orig;

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fakeLocationLongPress:)];
    longPress.minimumPressDuration = 1.0;
    longPress.numberOfTouchesRequired = 2;
    [self addGestureRecognizer:longPress];
}

%new
- (void)fakeLocationLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topVC.presentedViewController) {
            topVC = topVC.presentedViewController;
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"虚拟定位"
                                                                       message:@"输入纬度,经度（例如 39.9042,116.4074）"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"纬度,经度";
        }];

        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *input = alert.textFields.firstObject.text;
            NSArray *parts = [input componentsSeparatedByString:@","];
            if (parts.count == 2) {
                fakeLat = [parts[0] doubleValue];
                fakeLng = [parts[1] doubleValue];
                spoofingEnabled = YES;
            }
        }]];

        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

        [topVC presentViewController:alert animated:YES completion:nil];
    }
}

%end
