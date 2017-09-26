# Workaround: a patched version of Closure Compiler that works with Angular

load(":repositories.bzl", "closure_repositories")
load("//closure/private:java_import_external.bzl", "java_import_external")

def patched_closure_repositories(**kwargs):

  # Closure compiler release doesn't work for Angular.
  # Use a release from @gregmagolan instead.
  java_import_external(
    name = "com_google_javascript_closure_compiler",
    extra_build_file_content = "\n".join([
        "java_binary(",
        "    name = \"main\",",
        "    main_class = \"com.google.javascript.jscomp.CommandLineRunner\",",
        "    output_licenses = [\"unencumbered\"],",
        "    runtime_deps = [",
        "        \":com_google_javascript_closure_compiler\",",
        "        \"@args4j\",",
        "    ],",
        ")",
    ]),
    jar_sha256 = "2605af95caba8ca77fe3f7ee405de4292b18d931fef9ad37a9a5cffe49f2dccf",
    jar_urls = [
        "https://github.com/gregmagolan/closure-compiler/raw/baa48b3f168f0d28c5c013a198018d120cfe4fe7/compiler.jar"
    ],
    licenses = ["reciprocal"],  # MPL v1.1 (Rhino AST), Apache 2.0 (JSCompiler)
    deps = [
        "@com_google_code_findbugs_jsr305",
        "@com_google_code_gson",
        "@com_google_guava",
        "@com_google_protobuf_java",
    ],
  )

  closure_repositories(omit_com_google_javascript_closure_compiler = True, **kwargs)
