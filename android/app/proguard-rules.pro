# Proguard / R8 Code Obfuscation configurations for MechaniQ Security

-keep class com.mechaniq.app.** { *; }
-dontwarn okhttp3.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-keepnames class * implements java.io.Serializable

# Protect local database queries and schema models
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}