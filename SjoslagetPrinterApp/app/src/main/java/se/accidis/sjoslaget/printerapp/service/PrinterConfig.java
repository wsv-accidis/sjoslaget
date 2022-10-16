package se.accidis.sjoslaget.printerapp.service;

import android.content.Context;

import com.brother.ptouch.sdk.LabelInfo;
import com.brother.ptouch.sdk.Printer;
import com.brother.ptouch.sdk.PrinterInfo;

import se.accidis.sjoslaget.printerapp.R;

public final class PrinterConfig {
    public static final String PRINT_CHARSET = "ISO-8859-1";

    private final Printer mPrinter;
    private final String mWorkPath;
    private boolean mHasInitialConfig = false;
    private int mTemplateIndex;
    private int mLabelIndex;

    PrinterConfig(Printer printer, Context context) {
        mPrinter = printer;
        mWorkPath = context.getCacheDir().getPath();
    }

    public int getTemplateIndex() {
        return mTemplateIndex;
    }

    public void configurePrePrint() throws PrinterException {
        final LabelInfo labelInfo = mPrinter.getLabelInfo();
        if (mLabelIndex != labelInfo.labelNameIndex) {
            final PrinterInfo printerInfo = mPrinter.getPrinterInfo();
            mLabelIndex = labelInfo.labelNameIndex;
            mTemplateIndex = selectTemplateByLabelType(mLabelIndex);

            printerInfo.labelNameIndex = mLabelIndex;

            if (!mPrinter.setPrinterInfo(printerInfo)) {
                throw new PrinterException("Failed to configure printer.", R.string.error_communication);
            }
        }
    }

    public void ensureConfigured() throws PrinterException {
        if (!mHasInitialConfig) {
            configureInitial();
        }
    }

    private void configureInitial() throws PrinterException {
        final PrinterInfo printerInfo = new PrinterInfo();

        // Model and port are hardcoded for now - otherwise we'd need a UI to configure them
        printerInfo.printerModel = PrinterInfo.Model.QL_810W;
        printerInfo.port = PrinterInfo.Port.USB;

        // Doesn't matter what we set here as long as it's valid
        printerInfo.labelNameIndex = LabelInfo.QL700.W62.ordinal();

        // This must be set to a writeable folder for the printer driver to work in
        printerInfo.workPath = mWorkPath;

        if (!mPrinter.setPrinterInfo(printerInfo)) {
            throw new PrinterException("Failed to configure printer.", R.string.error_communication);
        }

        mHasInitialConfig = true;
    }

    private static int selectTemplateByLabelType(int labelIndex) throws PrinterException {
        /*
         * These values are configured in the printer's flash using the
         * P-Touch Transfer Manager utility
         *
         * We ony support 62 mm continuous
         */
        if (labelIndex == LabelInfo.QL700.W62.ordinal()
                || labelIndex == LabelInfo.QL700.W62RB.ordinal()) {
            return 1;
        } else {
            throw new PrinterException("No supported labels in printer.", R.string.error_labels);
        }
    }
}
