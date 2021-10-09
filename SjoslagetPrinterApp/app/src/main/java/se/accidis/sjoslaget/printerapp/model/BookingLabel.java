package se.accidis.sjoslaget.printerapp.model;

import android.annotation.SuppressLint;

import com.squareup.moshi.Json;

import java.util.List;

public final class BookingLabel {
    @Json(name = "Reference")
    public String reference;

    @Json(name = "FullName")
    public String fullName;

    @Json(name = "SubCruise")
    public String subCruise;

    @Json(name = "Cabins")
    public List<NameCountPair> cabins;

    @Json(name = "Products")
    public List<NameCountPair> products;

    public String getCabinsText() {
        return concatNameCountPairs(cabins);
    }

    public String getProductsText() {
        return concatNameCountPairs(products);
    }

    public String getSubCruiseText() {
        switch (subCruise) {
            case "A":
                return "1";
            case "B":
                return "2";
            case "AB":
                return "1+2";
            default:
                return "";
        }
    }

    @SuppressLint("DefaultLocale")
    private static String concatNameCountPairs(List<NameCountPair> list) {
        if (null == list || list.isEmpty()) {
            return "-";
        }
        boolean first = true;
        final StringBuilder builder = new StringBuilder();
        for (NameCountPair pair : list) {
            if (first) {
                first = false;
            } else {
                builder.append(", ");
            }

            builder.append(String.format("%d x %s", pair.count, pair.name));
        }
        return builder.toString();
    }
}
