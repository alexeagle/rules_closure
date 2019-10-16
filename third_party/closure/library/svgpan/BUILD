# DO NOT EDIT -- bazel run //closure/library:regenerate -- "$PWD"

package(default_visibility = ["//visibility:public"])

licenses(["notice"])

load("//closure:defs.bzl", "closure_js_library")

closure_js_library(
    name = "all_js",
    exports = [":svgpan"],
)

closure_js_library(
    name = "svgpan",
    srcs = ["@com_google_javascript_closure_library//:third_party/closure/goog/svgpan/svgpan.js"],
    lenient = True,
    deps = [
        "@com_google_javascript_closure_library//closure/goog/disposable",
        "@com_google_javascript_closure_library//closure/goog/events",
        "@com_google_javascript_closure_library//closure/goog/events:eventtype",
        "@com_google_javascript_closure_library//closure/goog/events:mousewheelhandler",
    ],
)
