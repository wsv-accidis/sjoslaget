package se.accidis.sjoslaget.printerapp;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.os.Handler;
import android.os.IBinder;
import android.support.annotation.Nullable;
import android.util.Log;

import com.brother.ptouch.sdk.Printer;

public final class PrinterRelayService extends Service {
    private static final String TAG = PrinterRelayService.class.getSimpleName();
    private final static int PRINTER_RELAY_INTERVAL = 1000;

    private final Handler mHandler = new Handler();
    private final Printer mPrinter = new Printer();
    private final Runnable mPrinterRelayRunnable = new PrinterRelayRunnable();

    private UsbManager mUsbManager;

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "Service created.");
        mHandler.post(mPrinterRelayRunnable);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "Service destroyed.");
        mHandler.removeCallbacks(mPrinterRelayRunnable);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "Service start command received.");
        return START_STICKY;
    }

    private final class PrinterRelayRunnable implements Runnable {
        @Override
        public void run() {
            if (null == mUsbManager) {
                mUsbManager = (UsbManager) getSystemService(Context.USB_SERVICE);
            }

            final UsbDevice usbDevice = mPrinter.getUsbDevice(mUsbManager);

            if (null != usbDevice) {
                Log.d(TAG, "Printer is still connected.");
                mHandler.postDelayed(mPrinterRelayRunnable, PRINTER_RELAY_INTERVAL);
            } else {
                // Abort abort
                Log.d(TAG, "Lost printer, service is stopping itself.");
                stopSelf();
            }
        }
    }
}
