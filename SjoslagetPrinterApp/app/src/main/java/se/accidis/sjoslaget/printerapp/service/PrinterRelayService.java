package se.accidis.sjoslaget.printerapp.service;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.os.Handler;
import android.os.IBinder;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.brother.ptouch.sdk.LabelInfo;
import com.brother.ptouch.sdk.Printer;
import com.brother.ptouch.sdk.PrinterInfo;

import se.accidis.sjoslaget.printerapp.util.LocalBroadcasts;
import se.accidis.sjoslaget.printerapp.util.SjoslagetApiClient;

public final class PrinterRelayService extends Service {
    private static final String TAG = PrinterRelayService.class.getSimpleName();
    private final static int PRINTER_RELAY_INTERVAL = 1000;

    private final Handler mHandler = new Handler();
    private final Printer mPrinter = new Printer();
    private final Runnable mPrinterRelayRunnable = new PrinterRelayRunnable();
    private final PrinterRelayTaskCompletionListener mTaskCompletionListener = new PrinterRelayTaskCompletionListener();

    private SjoslagetApiClient mApiClient;
    private LocalBroadcastManager mBroadcasts;
    private UsbManager mUsbManager;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "Service created.");

        mApiClient = new SjoslagetApiClient(this);
        mBroadcasts = LocalBroadcastManager.getInstance(this);
        mUsbManager = (UsbManager) getSystemService(Context.USB_SERVICE);

        configurePrinter();

        mHandler.post(mPrinterRelayRunnable);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "Service destroyed.");

        mBroadcasts.sendBroadcast(new Intent(LocalBroadcasts.ACTION_SERVICE_STOPPING));
        mHandler.removeCallbacks(mPrinterRelayRunnable);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return START_STICKY;
    }

    private void configurePrinter() {
        // Lots of hardcoded printer settings here, it would be nice to just autodetect these
        final PrinterInfo printerInfo = new PrinterInfo();
        printerInfo.printerModel = PrinterInfo.Model.QL_810W;
        printerInfo.port = PrinterInfo.Port.USB;
        printerInfo.labelNameIndex = LabelInfo.QL700.W29H90.ordinal();
        printerInfo.workPath = getCacheDir().getPath();

        mPrinter.setPrinterInfo(printerInfo);
    }

    private final class PrinterRelayRunnable implements Runnable {
        @Override
        public void run() {
            final UsbDevice usbDevice = mPrinter.getUsbDevice(mUsbManager);
            if (null != usbDevice && mUsbManager.hasPermission(usbDevice)) {
                final PrinterRelayTask task = new PrinterRelayTask(getApplicationContext(), mPrinter, mApiClient, mTaskCompletionListener);
                task.execute();
            } else {
                Log.d(TAG, "Printer disconnected, service is stopping itself.");
                stopSelf();
            }
        }
    }

    private final class PrinterRelayTaskCompletionListener implements PrinterRelayTask.CompletionListener {
        @Override
        public void onCompleted() {
            mHandler.postDelayed(mPrinterRelayRunnable, PRINTER_RELAY_INTERVAL);
        }
    }
}
