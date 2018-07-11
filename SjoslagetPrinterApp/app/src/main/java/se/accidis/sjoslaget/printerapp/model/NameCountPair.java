package se.accidis.sjoslaget.printerapp.model;

import com.squareup.moshi.Json;

public final class NameCountPair {
    @Json(name = "Name")
    public String name;

    @Json(name = "Count")
    public int count;
}
