# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# AwesomeNotifications rules
-keep class me.carda.awesome_notifications.** { *; }
-dontwarn me.carda.awesome_notifications.**

# LocalAuth / Biometric rules
-keep class androidx.biometric.** { *; }
-dontwarn androidx.biometric.**

# SharedPreferences rules
-keep class androidx.preference.** { *; }
-dontwarn androidx.preference.**

# Provider rules
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# Camera rules
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Audio/Speech rules
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Permission handler rules
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Flutter localization rules
-keep class androidx.localbroadcastmanager.** { *; }
-dontwarn androidx.localbroadcastmanager.**

# Timezone rules
-keep class org.threeten.** { *; }
-dontwarn org.threeten.**

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Preserve some attributes that may be required by reflection
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

# Flutter engine
-keep class io.flutter.embedding.** { *; }

# Gson rules (if used by any plugin)
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.** { *; }

# Generic rules for reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
