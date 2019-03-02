#import <Flutter/Flutter.h>

@interface FlutterZsdkPlugin : NSObject<FlutterPlugin>

- (void)discoverBluetoothDevices:(FlutterResult)result;

- (void)getDeviceProperties:(NSString*) serial result:(FlutterResult)result;

- (void)sendZplOverBluetooth:(NSString *)serial data:(NSString*)data result:(FlutterResult)result;

@end
