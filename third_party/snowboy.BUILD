package(default_visibility = ["//visibility:public"])

licenses(["notice"])

cc_library(
    name = "snowboy",
    includes = [
        "include",
    ],
    hdrs = glob([
        "*.h",
    ]),
    linkopts = [
        "-L/usr/local/apollo/snowboy/lib -lsnowboy-detect",
    ],
    deps = [
        "@caffe//:lib",
    ]
)
