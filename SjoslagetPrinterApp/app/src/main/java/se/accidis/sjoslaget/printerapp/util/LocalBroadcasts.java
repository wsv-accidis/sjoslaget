package se.accidis.sjoslaget.printerapp.util;

import android.content.IntentFilter;

public final class LocalBroadcasts {
    public static final String ACTION_PRINTING_DONE = "printing-done";
    public static final String ACTION_PRINTING_STARTED = "printing-started";
    public static final String ACTION_SERVICE_STOPPING = "service-stopping";

    public static IntentFilter createIntentFilter() {
        final IntentFilter filter = new IntentFilter();
        filter.addAction(ACTION_PRINTING_DONE);
        filter.addAction(ACTION_PRINTING_STARTED);
        filter.addAction(ACTION_SERVICE_STOPPING);
        return filter;
    }

    private LocalBroadcasts() {
    }
}
