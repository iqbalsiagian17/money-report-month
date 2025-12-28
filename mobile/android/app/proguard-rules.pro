# Flutter core
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.** { *; }

# AndroidX (for notifications and other core Android features)
-keep class androidx.** { *; }

# Google Play Core - fix "missing class" warning
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Hive (plugin classes)
-keep class io.flutter.plugins.** { *; }

# Keep all annotations
-keepattributes *Annotation*
