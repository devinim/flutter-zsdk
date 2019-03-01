package tr.gen.devinim.flutterzsdk;

import android.content.Context;
import android.os.Looper;

import com.zebra.sdk.comm.BluetoothConnection;
import com.zebra.sdk.comm.Connection;
import com.zebra.sdk.comm.ConnectionException;
import com.zebra.sdk.printer.ZebraPrinterFactory;
import com.zebra.sdk.printer.ZebraPrinterLinkOs;
import com.zebra.sdk.printer.discovery.BluetoothDiscoverer;
import com.zebra.sdk.printer.discovery.DiscoveredPrinter;
import com.zebra.sdk.printer.discovery.DiscoveryHandler;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterZsdkPlugin
 */
public class FlutterZsdkPlugin implements MethodCallHandler {
    /**
     * Plugin registration.
     */

    private static final boolean DEBUG = true;

    public static void registerWith(Registrar registrar) {
        if (DEBUG) {
            System.out.println("FlutterZsdkPlugin registered with " + registrar.toString());
        }
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_zsdk");
        channel.setMethodCallHandler(new FlutterZsdkPlugin(registrar));
    }

    private Context context;


    public FlutterZsdkPlugin(Registrar registrar) {
        this.context = registrar.activeContext();

        if (DEBUG) {
//            Timer tm = new Timer();
//
//            TimerTask task = new TimerTask() {
//                @Override
//                public void run() {
//                    System.out.println("Timer runs");
//                    discoverBluetoothDevices(null);
//                }
//            };
//
//            TimerTask task2 = new TimerTask() {
//                @Override
//                public void run() {
//                    System.out.println("Timer runs");
//                    sendZplOverBluetooth("AC:3F:A4:5B:EB:1F");
//                }
//            };
//
//            tm.schedule(task, 6000);
//            tm.schedule(task2, 15000);
        }

    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (DEBUG) {
            System.out.print("onMethodCall: " + call.method + " ");
        }
        switch (call.method) {
            case "discoverBluetoothDevices":
                discoverBluetoothDevices(result);
                break;
            case "getDeviceProperties":
                if (DEBUG) {
                    System.out.println("with arguments: {mac:" + call.argument("mac") + "}");
                }
                getDeviceProperties((String) call.argument("mac"), result);
                break;
            case "sendZplOverBluetooth":
                if (DEBUG) {
                    System.out.println("with arguments: {mac:" + call.argument("mac") + ", data: " + call.argument("data") + "}");
                }
                sendZplOverBluetooth((String) call.argument("mac"), (String) call.argument("data"), result);
                break;
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            default:
                result.notImplemented();
        }

    }

    void discoverBluetoothDevices(Result result) {
        final ZebraBlDiscoverer discoverer = new ZebraBlDiscoverer(result);
        new Thread(new Runnable() {
            public void run() {
                Looper.prepare();
                try {
                    if (DEBUG) {
                        System.out.println("BluetoothDiscoverer.findPrinters");
                    }
                    BluetoothDiscoverer.findPrinters(FlutterZsdkPlugin.this.context, discoverer);
                } catch (ConnectionException e) {
                    e.printStackTrace();
                } finally {
                    Looper.myLooper().quit();
                }
            }
        }).start();
    }

    private void getDeviceProperties(String mac, Result result) {

        try {
            HashMap<String, HashMap<String, String>> props = new HashMap<>();

            Connection connection = new BluetoothConnection(mac);
            connection.open();

            ZebraPrinterLinkOs printer = ZebraPrinterFactory.getLinkOsPrinter(connection);

            if (DEBUG) {
                System.out.println("getDeviceProperties: ");
            }
            Set<String> availableSettings = printer.getAvailableSettings();
            Map<String, String> allSettingValues = printer.getAllSettingValues();

            for (String setting : availableSettings) {
                HashMap<String, String> m = new HashMap<>();

                String s = allSettingValues.get(setting);

                m.put("value", s);
                m.put("set", printer.getSettingRange(setting));

                props.put(setting, m);

                if (DEBUG) {
                    System.out.println("getDeviceProperties: " + setting + ": [" + printer.getSettingRange(setting) + "] => Value: " + s);
                }
            }
        } catch (Exception e) {
            result.error(e.getMessage(), null, null);
        }

    }

    private class ZebraBlDiscoverer implements DiscoveryHandler {

        private Result result;
        private HashMap<String, String> devices = new HashMap<>();

        public ZebraBlDiscoverer(Result result) {
            this.result = result;
        }

        @Override
        public void foundPrinter(DiscoveredPrinter discoveredPrinter) {
            if (DEBUG) {
                System.out.println("ZebraBlDiscoverer: Found Printer:" + discoveredPrinter.address + " || " + discoveredPrinter.toString());
                for (Map.Entry<String, String> me : discoveredPrinter.getDiscoveryDataMap().entrySet()) {
                    System.out.println(me.getKey() + " => " + me.getValue());
                }
            }
            devices.put(discoveredPrinter.address, discoveredPrinter.getDiscoveryDataMap().get("FRIENDLY_NAME"));
        }

        @Override
        public void discoveryFinished() {
            if (DEBUG) {
                System.out.println("ZebraBlDiscoverer: discoveryFinished");
            }
            result.success(devices);
        }

        @Override
        public void discoveryError(String s) {
            if (DEBUG) {
                System.out.println("ZebraBlDiscoverer: discoveryError:" + s);
            }
            result.error(s, null, null);
        }
    }


    private void sendZplOverBluetooth(final String mac, final String data, final Result result) {

        new Thread(new Runnable() {
            public void run() {
                try {
                    // Instantiate connection for given Bluetooth&reg; MAC Address.
                    Connection connection = new BluetoothConnection(mac);
                    // Initialize
                    Looper.prepare();

                    // Open the connection - physical connection is established here.
                    connection.open();

                    // Send the data to printer as a byte array.
                    connection.write(data.getBytes("UTF-8"));

                    // Make sure the data got to the printer before closing the connection
                    Thread.sleep(500);

                    // Close the connection to release resources.
                    connection.close();

                    result.success("wrote " + data.getBytes().length + "bytes");

                    Looper.myLooper().quit();
                } catch (Exception e) {
                    result.error(e.getMessage(), null, null);
                    // Handle communications error here.
                    e.printStackTrace();
                }
            }
        }).start();
    }
}
