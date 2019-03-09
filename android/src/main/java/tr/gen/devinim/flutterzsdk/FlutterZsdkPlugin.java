package tr.gen.devinim.flutterzsdk;

import android.bluetooth.BluetoothAdapter;
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
            case "getBatteryLevel":
                if (DEBUG) {
                    System.out.println("with arguments: {mac:" + call.argument("mac") + "}");
                }
                getBatteryLevel((String) call.argument("mac"), result);
                break;
            case "isOnline":
                if (DEBUG) {
                    System.out.println("with arguments: {mac:" + call.argument("mac") + "}");
                }
                isOnline((String) call.argument("mac"), result);
                break;
            case "sendZplOverBluetooth":
                if (DEBUG) {
                    System.out.println("with arguments: {mac:" + call.argument("mac") + ", data: " + call.argument("data") + "}");
                }
                sendZplOverBluetooth((String) call.argument("mac"), (String) call.argument("data"), result);
                break;

            default:
                result.notImplemented();
        }

    }

    private class DiscoveryRunner extends Thread implements DiscoveryHandler {

        Result result;
        String endMac;

        private HashMap<String, String> devices = new HashMap<>();

        public void setResult(Result result) {
            this.result = result;
        }

        public void setEndMac(String mac) {
            this.endMac = mac;
        }

        public void run() {

            //  Looper.prepare();
            try {
                if (DEBUG) {
                    System.out.println("BluetoothDiscoverer.findPrinters");
                }
                BluetoothDiscoverer.findPrinters(FlutterZsdkPlugin.this.context, this);
            } catch (ConnectionException e) {
                e.printStackTrace();
            } finally {
                //    Looper.myLooper().quit();
            }

        }

        @Override
        public void foundPrinter(DiscoveredPrinter discoveredPrinter) {
            if (DEBUG) {
                System.out.println("ZebraBlDiscoverer: Found Printer:" + discoveredPrinter.address + " || " + discoveredPrinter.toString());
                for (Map.Entry<String, String> me : discoveredPrinter.getDiscoveryDataMap().entrySet()) {
                    System.out.println(me.getKey() + " => " + me.getValue());
                }
            }

            if (endMac != null) {
                if (DEBUG) {
                    System.out.println("Exit when found is true");
                }
                if (discoveredPrinter.address.equalsIgnoreCase(endMac)) {
                    if (DEBUG) {
                        System.out.println("Searched mac found. Finishing discovery");
                    }
                    devices.clear();
                    devices.put(discoveredPrinter.address, discoveredPrinter.getDiscoveryDataMap().get("FRIENDLY_NAME"));
                    discoveryFinished();
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
            //  BluetoothAdapter.getDefaultAdapter().cancelDiscovery();
        }

        @Override
        public void discoveryError(String s) {
            if (DEBUG) {
                System.out.println("ZebraBlDiscoverer: discoveryError:" + s);
            }
            result.error(s, null, null);
            if (DEBUG) {
                System.out.println("Trying to stop discovery ");
            }
            //  BluetoothAdapter.getDefaultAdapter().cancelDiscovery();
        }
    }

    private void isOnline(String mac, Result result) {
        DiscoveryRunner runner = new DiscoveryRunner();
        runner.setResult(result);
        runner.setEndMac(mac);
        runner.run();
    }

    private void discoverBluetoothDevices(Result result) {
        DiscoveryRunner runner = new DiscoveryRunner();
        runner.setResult(result);
        runner.run();
    }

    private void getBatteryLevel(String mac, Result result) {
        try {
            Connection connection = new BluetoothConnection(mac);
            connection.open();

            ZebraPrinterLinkOs printer = ZebraPrinterFactory.getLinkOsPrinter(connection);

            result.success(printer.getSettingValue("power.percent_full"));

        } catch (Exception e) {
            result.error(e.getMessage(), null, null);
        }
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
