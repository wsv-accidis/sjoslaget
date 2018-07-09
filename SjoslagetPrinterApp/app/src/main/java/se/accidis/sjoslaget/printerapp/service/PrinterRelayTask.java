package se.accidis.sjoslaget.printerapp.service;

import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.brother.ptouch.sdk.Printer;
import com.brother.ptouch.sdk.PrinterInfo;
import com.brother.ptouch.sdk.PrinterStatus;

import java.util.Collections;
import java.util.List;

import se.accidis.sjoslaget.printerapp.model.BookingLabel;
import se.accidis.sjoslaget.printerapp.util.LocalBroadcasts;
import se.accidis.sjoslaget.printerapp.util.SjoslagetApiClient;

public final class PrinterRelayTask extends AsyncTask<Void, Void, Void> {
    private static final String TAG = PrinterRelayTask.class.getSimpleName();

    // This is the key assigned in the "Brother P-touch Transfer Manager" for the template to use
    private static final int PRINT_TEMPLATE_KEY = 1;
    // The printer doesn't support UTF-8 directly so we need to convert
    private static final String PRINT_CHARSET = "ISO-8859-1";

    private final SjoslagetApiClient mApiClient;
    private LocalBroadcastManager mBroadcasts;
    private CompletionListener mCompletionListener;
    private Printer mPrinter;

    PrinterRelayTask(Context context, Printer printer, SjoslagetApiClient apiClient, CompletionListener completionListener) {
        mApiClient = apiClient;
        mBroadcasts = LocalBroadcastManager.getInstance(context);
        mPrinter = printer;
        mCompletionListener = completionListener;
    }

    @Override
    protected Void doInBackground(Void... ignored) {
        List<BookingLabel> toPrint = pollPrinterQueue();
        for (BookingLabel label : toPrint) {
            Log.i(TAG, "Printing label ...");
            printLabel(label);
        }
        return null;
    }

    @Override
    protected void onPostExecute(Void ignored) {
        super.onPostExecute(ignored);

        if (null != mCompletionListener) {
            mCompletionListener.onCompleted();
        }
    }

    private List<BookingLabel> pollPrinterQueue() {
        try {
            return mApiClient.tryAuthenticateAndPollPrinterQueue();
        } catch (Exception e) {
            Log.e(TAG, "Exception while trying to authenticate and poll the printer queue.", e);
            return Collections.emptyList();
        }
    }

    private void printLabel(BookingLabel label) {
        mBroadcasts.sendBroadcast(new Intent(LocalBroadcasts.ACTION_PRINTING_STARTED));
        try {
            if (!mPrinter.startCommunication()) {
                Log.e(TAG, "Printer.startCommunication failed.");
                return;
            }

            mPrinter.startPTTPrint(PRINT_TEMPLATE_KEY, PRINT_CHARSET);
            mPrinter.replaceTextName(label.reference, "Reference");
            mPrinter.replaceTextName(label.fullName, "FullName");
            mPrinter.replaceTextName(label.getCabinsText(), "Cabins");
            mPrinter.replaceTextName(label.getProductsText(), "Products");

            final PrinterStatus status = mPrinter.flushPTTPrint();

            if (status.errorCode != PrinterInfo.ErrorCode.ERROR_NONE) {
                Log.e(TAG, String.format("Printer returned error code: %s", status.errorCode.toString()));
            } else {
                Log.d(TAG, "Printer returned success.");
            }

            if (!mPrinter.endCommunication()) {
                Log.e(TAG, "Printer.endCommunication failed.");
            }
        } catch (Exception e) {
            Log.e(TAG, "Exception while trying to print.", e);
        } finally {
            mBroadcasts.sendBroadcast(new Intent(LocalBroadcasts.ACTION_PRINTING_DONE));
        }
    }

    public interface CompletionListener {
        void onCompleted();
    }
}
