# Copyright 2016 The Closure Rules Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Utilities for compiling Closure Templates to JavaScript.
"""

load("//closure/compiler:closure_js_aspect.bzl", "closure_js_aspect")
load("//closure/compiler:closure_js_library.bzl", "closure_js_library")
load("//closure/private:defs.bzl", "SOY_FILE_TYPE", "unfurl")

_SOYTOJSSRCCOMPILER = "@com_google_template_soy//:SoyToJsSrcCompiler"

def _impl(ctx):
    args = ["--outputPathFormat=%s/{INPUT_DIRECTORY}/{INPUT_FILE_NAME}.js" %
            ctx.configuration.genfiles_dir.path]
    if ctx.attr.soy_msgs_are_external:
        args += ["--googMsgsAreExternal"]
    if ctx.attr.should_generate_soy_msg_defs:
        args += ["--shouldGenerateGoogMsgDefs"]
    if ctx.attr.bidi_global_dir:
        args += ["--bidiGlobalDir=%s" % ctx.attr.bidi_global_dir]
    if ctx.attr.plugin_modules:
        args += ["--pluginModules=%s" % ",".join(ctx.attr.plugin_modules)]
    for arg in ctx.attr.defs:
        if not arg.startswith("--") or (" " in arg and "=" not in arg):
            fail("Please use --flag=value syntax for defs")
        args += [arg]
    inputs = []
    for f in ctx.files.srcs:
        args.append("--srcs=" + f.path)
        inputs.append(f)
    if ctx.file.globals:
        args += ["--compileTimeGlobalsFile", ctx.file.globals.path]
        inputs.append(ctx.file.globals)
    for dep in unfurl(ctx.attr.deps, provider = "closure_js_library"):
        for f in dep.closure_js_library.descriptors.to_list():
            args += ["--protoFileDescriptors=%s" % f.path]
            inputs.append(f)
    ctx.actions.run(
        inputs = inputs,
        outputs = ctx.outputs.outputs,
        executable = ctx.executable.compiler,
        arguments = args,
        mnemonic = "SoyCompiler",
        progress_message = "Generating %d SOY v2 JS file(s)" % len(
            ctx.attr.outputs,
        ),
    )

_closure_js_template_library = rule(
    implementation = _impl,
    output_to_genfiles = True,
    attrs = {
        "srcs": attr.label_list(allow_files = SOY_FILE_TYPE),
        "deps": attr.label_list(
            aspects = [closure_js_aspect],
            providers = ["closure_js_library"],
        ),
        "outputs": attr.output_list(),
        "globals": attr.label(allow_single_file = True),
        "plugin_modules": attr.label_list(),
        "should_generate_soy_msg_defs": attr.bool(),
        "bidi_global_dir": attr.int(default = 1, values = [1, -1]),
        "soy_msgs_are_external": attr.bool(),
        "compiler": attr.label(cfg = "host", executable = True, mandatory = True),
        "defs": attr.string_list(),
    },
)

def closure_js_template_library(
        name,
        srcs,
        deps = [],
        suppress = [],
        testonly = None,
        globals = None,
        plugin_modules = None,
        should_generate_soy_msg_defs = None,
        bidi_global_dir = None,
        soy_msgs_are_external = None,
        defs = [],
        **kwargs):
    compiler = str(Label(_SOYTOJSSRCCOMPILER))
    js_srcs = [src + ".js" for src in srcs]
    _closure_js_template_library(
        name = name + "_soy_js",
        srcs = srcs,
        deps = deps,
        outputs = js_srcs,
        testonly = testonly,
        visibility = ["//visibility:private"],
        globals = globals,
        plugin_modules = plugin_modules,
        should_generate_soy_msg_defs = should_generate_soy_msg_defs,
        bidi_global_dir = bidi_global_dir,
        soy_msgs_are_external = soy_msgs_are_external,
        compiler = compiler,
        defs = defs,
    )

    deps = deps + [
        str(Label("@com_google_javascript_closure_library//closure/goog/array")),
        str(Label("@com_google_javascript_closure_library//closure/goog/asserts")),
        str(Label("@com_google_javascript_closure_library//closure/goog/debug")),
        str(Label("@com_google_javascript_closure_library//closure/goog/format")),
        str(Label("@com_google_javascript_closure_library//closure/goog/html:safehtml")),
        str(Label("@com_google_javascript_closure_library//closure/goog/html:safescript")),
        str(Label("@com_google_javascript_closure_library//closure/goog/html:safestyle")),
        str(Label("@com_google_javascript_closure_library//closure/goog/html:safestylesheet")),
        str(Label("@com_google_javascript_closure_library//closure/goog/html:safeurl")),
        str(Label("@com_google_javascript_closure_library//closure/goog/html:trustedresourceurl")),
        str(Label("@com_google_javascript_closure_library//closure/goog/html:uncheckedconversions")),
        str(Label("@com_google_javascript_closure_library//closure/goog/i18n:bidi")),
        str(Label("@com_google_javascript_closure_library//closure/goog/i18n:bidiformatter")),
        str(Label("@com_google_javascript_closure_library//closure/goog/i18n:numberformat")),
        str(Label("@com_google_javascript_closure_library//closure/goog/object")),
        str(Label("@com_google_javascript_closure_library//closure/goog/soy:all_js")),
        str(Label("@com_google_javascript_closure_library//closure/goog/string")),
        str(Label("@com_google_javascript_closure_library//closure/goog/string:const")),
        str(Label("@com_google_javascript_closure_library//closure/goog/uri")),
        str(Label("//closure/templates:soy_jssrc")),
    ]

    closure_js_library(
        name = name,
        srcs = js_srcs,
        deps = deps,
        testonly = testonly,
        suppress = suppress + [
            "analyzerChecks",
            "reportUnknownTypes",
            "strictCheckTypes",
            "unusedLocalVariables",
        ],
        **kwargs
    )
