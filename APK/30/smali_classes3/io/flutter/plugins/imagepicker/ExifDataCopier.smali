.class Lio/flutter/plugins/imagepicker/ExifDataCopier;
.super Ljava/lang/Object;
.source "ExifDataCopier.java"


# direct methods
.method constructor <init>()V
    .locals 0

    .line 12
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static setIfNotNull(Landroidx/exifinterface/media/ExifInterface;Landroidx/exifinterface/media/ExifInterface;Ljava/lang/String;)V
    .locals 1

    .line 142
    invoke-virtual {p0, p2}, Landroidx/exifinterface/media/ExifInterface;->getAttribute(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    if-eqz v0, :cond_0

    .line 143
    invoke-virtual {p0, p2}, Landroidx/exifinterface/media/ExifInterface;->getAttribute(Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    invoke-virtual {p1, p2, p0}, Landroidx/exifinterface/media/ExifInterface;->setAttribute(Ljava/lang/String;Ljava/lang/String;)V

    :cond_0
    return-void
.end method


# virtual methods
.method copyExif(Landroidx/exifinterface/media/ExifInterface;Landroidx/exifinterface/media/ExifInterface;)V
    .locals 3
    .annotation system Ldalvik/annotation/Throws;
        value = {
            Ljava/io/IOException;
        }
    .end annotation

    const/16 v0, 0x69

    .line 27
    new-array v0, v0, [Ljava/lang/String;

    const/4 v1, 0x0

    const-string v2, "ImageDescription"

    aput-object v2, v0, v1

    const/4 v1, 0x1

    const-string v2, "Make"

    aput-object v2, v0, v1

    const/4 v1, 0x2

    const-string v2, "Model"

    aput-object v2, v0, v1

    const/4 v1, 0x3

    const-string v2, "Software"

    aput-object v2, v0, v1

    const/4 v1, 0x4

    const-string v2, "DateTime"

    aput-object v2, v0, v1

    const/4 v1, 0x5

    const-string v2, "Artist"

    aput-object v2, v0, v1

    const/4 v1, 0x6

    const-string v2, "Copyright"

    aput-object v2, v0, v1

    const/4 v1, 0x7

    const-string v2, "ExposureTime"

    aput-object v2, v0, v1

    const/16 v1, 0x8

    const-string v2, "FNumber"

    aput-object v2, v0, v1

    const/16 v1, 0x9

    const-string v2, "ExposureProgram"

    aput-object v2, v0, v1

    const/16 v1, 0xa

    const-string v2, "SpectralSensitivity"

    aput-object v2, v0, v1

    const/16 v1, 0xb

    const-string v2, "PhotographicSensitivity"

    aput-object v2, v0, v1

    const/16 v1, 0xc

    const-string v2, "ISOSpeedRatings"

    aput-object v2, v0, v1

    const/16 v1, 0xd

    const-string v2, "OECF"

    aput-object v2, v0, v1

    const/16 v1, 0xe

    const-string v2, "SensitivityType"

    aput-object v2, v0, v1

    const/16 v1, 0xf

    const-string v2, "StandardOutputSensitivity"

    aput-object v2, v0, v1

    const/16 v1, 0x10

    const-string v2, "RecommendedExposureIndex"

    aput-object v2, v0, v1

    const/16 v1, 0x11

    const-string v2, "ISOSpeed"

    aput-object v2, v0, v1

    const/16 v1, 0x12

    const-string v2, "ISOSpeedLatitudeyyy"

    aput-object v2, v0, v1

    const/16 v1, 0x13

    const-string v2, "ISOSpeedLatitudezzz"

    aput-object v2, v0, v1

    const/16 v1, 0x14

    const-string v2, "ExifVersion"

    aput-object v2, v0, v1

    const/16 v1, 0x15

    const-string v2, "DateTimeOriginal"

    aput-object v2, v0, v1

    const/16 v1, 0x16

    const-string v2, "DateTimeDigitized"

    aput-object v2, v0, v1

    const/16 v1, 0x17

    const-string v2, "OffsetTime"

    aput-object v2, v0, v1

    const/16 v1, 0x18

    const-string v2, "OffsetTimeOriginal"

    aput-object v2, v0, v1

    const/16 v1, 0x19

    const-string v2, "OffsetTimeDigitized"

    aput-object v2, v0, v1

    const/16 v1, 0x1a

    const-string v2, "ShutterSpeedValue"

    aput-object v2, v0, v1

    const/16 v1, 0x1b

    const-string v2, "ApertureValue"

    aput-object v2, v0, v1

    const/16 v1, 0x1c

    const-string v2, "BrightnessValue"

    aput-object v2, v0, v1

    const/16 v1, 0x1d

    const-string v2, "ExposureBiasValue"

    aput-object v2, v0, v1

    const/16 v1, 0x1e

    const-string v2, "MaxApertureValue"

    aput-object v2, v0, v1

    const/16 v1, 0x1f

    const-string v2, "SubjectDistance"

    aput-object v2, v0, v1

    const/16 v1, 0x20

    const-string v2, "MeteringMode"

    aput-object v2, v0, v1

    const/16 v1, 0x21

    const-string v2, "LightSource"

    aput-object v2, v0, v1

    const/16 v1, 0x22

    const-string v2, "Flash"

    aput-object v2, v0, v1

    const/16 v1, 0x23

    const-string v2, "FocalLength"

    aput-object v2, v0, v1

    const/16 v1, 0x24

    const-string v2, "MakerNote"

    aput-object v2, v0, v1

    const/16 v1, 0x25

    const-string v2, "UserComment"

    aput-object v2, v0, v1

    const/16 v1, 0x26

    const-string v2, "SubSecTime"

    aput-object v2, v0, v1

    const/16 v1, 0x27

    const-string v2, "SubSecTimeOriginal"

    aput-object v2, v0, v1

    const/16 v1, 0x28

    const-string v2, "SubSecTimeDigitized"

    aput-object v2, v0, v1

    const/16 v1, 0x29

    const-string v2, "FlashpixVersion"

    aput-object v2, v0, v1

    const/16 v1, 0x2a

    const-string v2, "FlashEnergy"

    aput-object v2, v0, v1

    const/16 v1, 0x2b

    const-string v2, "SpatialFrequencyResponse"

    aput-object v2, v0, v1

    const/16 v1, 0x2c

    const-string v2, "FocalPlaneXResolution"

    aput-object v2, v0, v1

    const/16 v1, 0x2d

    const-string v2, "FocalPlaneYResolution"

    aput-object v2, v0, v1

    const/16 v1, 0x2e

    const-string v2, "FocalPlaneResolutionUnit"

    aput-object v2, v0, v1

    const/16 v1, 0x2f

    const-string v2, "ExposureIndex"

    aput-object v2, v0, v1

    const/16 v1, 0x30

    const-string v2, "SensingMethod"

    aput-object v2, v0, v1

    const/16 v1, 0x31

    const-string v2, "FileSource"

    aput-object v2, v0, v1

    const/16 v1, 0x32

    const-string v2, "SceneType"

    aput-object v2, v0, v1

    const/16 v1, 0x33

    const-string v2, "CFAPattern"

    aput-object v2, v0, v1

    const/16 v1, 0x34

    const-string v2, "CustomRendered"

    aput-object v2, v0, v1

    const/16 v1, 0x35

    const-string v2, "ExposureMode"

    aput-object v2, v0, v1

    const/16 v1, 0x36

    const-string v2, "WhiteBalance"

    aput-object v2, v0, v1

    const/16 v1, 0x37

    const-string v2, "DigitalZoomRatio"

    aput-object v2, v0, v1

    const/16 v1, 0x38

    const-string v2, "FocalLengthIn35mmFilm"

    aput-object v2, v0, v1

    const/16 v1, 0x39

    const-string v2, "SceneCaptureType"

    aput-object v2, v0, v1

    const/16 v1, 0x3a

    const-string v2, "GainControl"

    aput-object v2, v0, v1

    const/16 v1, 0x3b

    const-string v2, "Contrast"

    aput-object v2, v0, v1

    const/16 v1, 0x3c

    const-string v2, "Saturation"

    aput-object v2, v0, v1

    const/16 v1, 0x3d

    const-string v2, "Sharpness"

    aput-object v2, v0, v1

    const/16 v1, 0x3e

    const-string v2, "DeviceSettingDescription"

    aput-object v2, v0, v1

    const/16 v1, 0x3f

    const-string v2, "SubjectDistanceRange"

    aput-object v2, v0, v1

    const/16 v1, 0x40

    const-string v2, "ImageUniqueID"

    aput-object v2, v0, v1

    const/16 v1, 0x41

    const-string v2, "CameraOwnerName"

    aput-object v2, v0, v1

    const/16 v1, 0x42

    const-string v2, "BodySerialNumber"

    aput-object v2, v0, v1

    const/16 v1, 0x43

    const-string v2, "LensSpecification"

    aput-object v2, v0, v1

    const/16 v1, 0x44

    const-string v2, "LensMake"

    aput-object v2, v0, v1

    const/16 v1, 0x45

    const-string v2, "LensModel"

    aput-object v2, v0, v1

    const/16 v1, 0x46

    const-string v2, "LensSerialNumber"

    aput-object v2, v0, v1

    const/16 v1, 0x47

    const-string v2, "GPSVersionID"

    aput-object v2, v0, v1

    const/16 v1, 0x48

    const-string v2, "GPSLatitudeRef"

    aput-object v2, v0, v1

    const/16 v1, 0x49

    const-string v2, "GPSLatitude"

    aput-object v2, v0, v1

    const/16 v1, 0x4a

    const-string v2, "GPSLongitudeRef"

    aput-object v2, v0, v1

    const/16 v1, 0x4b

    const-string v2, "GPSLongitude"

    aput-object v2, v0, v1

    const/16 v1, 0x4c

    const-string v2, "GPSAltitudeRef"

    aput-object v2, v0, v1

    const/16 v1, 0x4d

    const-string v2, "GPSAltitude"

    aput-object v2, v0, v1

    const/16 v1, 0x4e

    const-string v2, "GPSTimeStamp"

    aput-object v2, v0, v1

    const/16 v1, 0x4f

    const-string v2, "GPSSatellites"

    aput-object v2, v0, v1

    const/16 v1, 0x50

    const-string v2, "GPSStatus"

    aput-object v2, v0, v1

    const/16 v1, 0x51

    const-string v2, "GPSMeasureMode"

    aput-object v2, v0, v1

    const/16 v1, 0x52

    const-string v2, "GPSDOP"

    aput-object v2, v0, v1

    const/16 v1, 0x53

    const-string v2, "GPSSpeedRef"

    aput-object v2, v0, v1

    const/16 v1, 0x54

    const-string v2, "GPSSpeed"

    aput-object v2, v0, v1

    const/16 v1, 0x55

    const-string v2, "GPSTrackRef"

    aput-object v2, v0, v1

    const/16 v1, 0x56

    const-string v2, "GPSTrack"

    aput-object v2, v0, v1

    const/16 v1, 0x57

    const-string v2, "GPSImgDirectionRef"

    aput-object v2, v0, v1

    const/16 v1, 0x58

    const-string v2, "GPSImgDirection"

    aput-object v2, v0, v1

    const/16 v1, 0x59

    const-string v2, "GPSMapDatum"

    aput-object v2, v0, v1

    const/16 v1, 0x5a

    const-string v2, "GPSDestLatitudeRef"

    aput-object v2, v0, v1

    const/16 v1, 0x5b

    const-string v2, "GPSDestLatitude"

    aput-object v2, v0, v1

    const/16 v1, 0x5c

    const-string v2, "GPSDestLongitudeRef"

    aput-object v2, v0, v1

    const/16 v1, 0x5d

    const-string v2, "GPSDestLongitude"

    aput-object v2, v0, v1

    const/16 v1, 0x5e

    const-string v2, "GPSDestBearingRef"

    aput-object v2, v0, v1

    const/16 v1, 0x5f

    const-string v2, "GPSDestBearing"

    aput-object v2, v0, v1

    const/16 v1, 0x60

    const-string v2, "GPSDestDistanceRef"

    aput-object v2, v0, v1

    const/16 v1, 0x61

    const-string v2, "GPSDestDistance"

    aput-object v2, v0, v1

    const/16 v1, 0x62

    const-string v2, "GPSProcessingMethod"

    aput-object v2, v0, v1

    const/16 v1, 0x63

    const-string v2, "GPSAreaInformation"

    aput-object v2, v0, v1

    const/16 v1, 0x64

    const-string v2, "GPSDateStamp"

    aput-object v2, v0, v1

    const/16 v1, 0x65

    const-string v2, "GPSDifferential"

    aput-object v2, v0, v1

    const/16 v1, 0x66

    const-string v2, "GPSHPositioningError"

    aput-object v2, v0, v1

    const/16 v1, 0x67

    const-string v2, "InteroperabilityIndex"

    aput-object v2, v0, v1

    const/16 v1, 0x68

    const-string v2, "Orientation"

    aput-object v2, v0, v1

    .line 28
    invoke-static {v0}, Ljava/util/Arrays;->asList([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    .line 134
    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    if-eqz v1, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    .line 135
    invoke-static {p1, p2, v1}, Lio/flutter/plugins/imagepicker/ExifDataCopier;->setIfNotNull(Landroidx/exifinterface/media/ExifInterface;Landroidx/exifinterface/media/ExifInterface;Ljava/lang/String;)V

    goto :goto_0

    .line 138
    :cond_0
    invoke-virtual {p2}, Landroidx/exifinterface/media/ExifInterface;->saveAttributes()V

    return-void
.end method
