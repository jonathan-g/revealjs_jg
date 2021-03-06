globalVariables(c(".", "extension", "value"))

#' Convert to a reveal.js presentation
#'
#' Format for converting from R Markdown to a reveal.js presentation.
#'
#' @inheritParams rmarkdown::beamer_presentation
#' @inheritParams rmarkdown::pdf_document
#' @inheritParams rmarkdown::html_document
#'
#' @param center \code{TRUE} to vertically center content on slides
#' @param controls \code{TRUE} to show navigation controls on slides
#' @param width \code{NULL} to override default width (pixels)
#' @param height \code{NULL} to override default height (pixels)
#' @param margin \code{NULL} to override default margin around the slides.
#' @param slide_level Level of heading to denote individual slides. If
#'   \code{slide_level} is 2 (the default), a two-dimensional layout will be
#'   produced, with level 1 headers building horizontally and level 2 headers
#'   building vertically. It is not recommended that you use deeper nesting of
#'   section levels with reveal.js.
#' @param theme Visual theme ("simple", "sky", "beige", "serif", "solarized",
#'   "blood", "moon", "night", "black", "league" or "white").
#' @param custom_theme Custom theme, not included in reveal.js distribution
#' @param custom_theme_dark Does the custom theme use a dark-mode?
#' @param transition Slide transition ("default", "none", "fade", "slide",
#'   "convex", "concave" or "zoom")
#' @param custom_transition Custom slide transition, not included in reveal.js
#'   distribuion.
#' @param background_transition Slide background-transition ("default", "none",
#'   "fade", "slide", "convex", "concave" or "zoom")
#' @param custom_background_transition Custom background-transition, not
#'   included in reveal.js distribuion.
#' @param reveal_options Additional options to specify for reveal.js (see
#'   \href{https://github.com/hakimel/reveal.js#configuration}{https://github.com/hakimel/reveal.js#configuration}
#'   for details).
#' @param reveal_plugins Reveal plugins to include. Available plugins include
#'   "notes", "search", "zoom", "chalkboard", and "menu". Note that
#'   \code{self_contained} must be set to \code{FALSE} in order to use Reveal
#'   plugins.
#' @param reveal_version Version of reveal.js to use.
#' @param reveal_location Location to search for reveal.js (Expects to find
#' reveal.js distribution at
#' \code{file.path(reveal_location, paste0('revealjs-', reveal_version))}
#' @param template Pandoc template to use for rendering. Pass "default" to use
#'   the rmarkdown package default template; pass \code{NULL} to use pandoc's
#'   built-in template; pass a path to use a custom template that you've
#'   created. Note that if you don't use the "default" template then some
#'   features of \code{revealjs_presentation} won't be available (see the
#'   Templates section below for more details).
#' @param custom_asset_path Path to custom theme css.
#' @param resource_location Optional custom path to reveal.js templates and skeletons
#' @param tex_extensions LaTeX extensions for MathJax
#' @param tex_defs LaTeX macro definitions for MathJax
#' @param md_extensions Pandoc markdown extensions
#' @param mathjax_scale Scale (in percent) for MathJax. Default = 100
#' @param extra_dependencies Additional function arguments to pass to the base R
#'   Markdown HTML output formatter [rmarkdown::html_document_base()].
#' @param custom_plugins Add custom plugins to the list of supported plugins.
#' @param no_postprocess Omit the post-processing step.
#' @param ... Ignored
#'
#' @return R Markdown output format to pass to \code{\link{render}}
#'
#' @details
#'
#' In reveal.js presentations you can use level 1 or level 2 headers for slides.
#' If you use a mix of level 1 and level 2 headers then a two-dimensional layout
#' will be produced, with level 1 headers building horizontally and level 2
#' headers building vertically.
#'
#' For additional documentation on using revealjs presentations see
#' \href{https://github.com/jonathan-g/revealjg}{https://github.com/jonathan-g/revealjg}.
#'
#' @examples
#' \dontrun{
#'
#' library(rmarkdown)
#' library(revealjg)
#'
#' # simple invocation
#' render("pres.Rmd", revealjs_presentation())
#'
#' # specify an option for incremental rendering
#' render("pres.Rmd", revealjs_presentation(incremental = TRUE))
#' }
#'
#'
#' @export
revealjs_presentation <- function(incremental = FALSE,
                                  center = FALSE,
                                  width = NULL,
                                  height = NULL,
                                  margin = NULL,
                                  slide_level = 2,
                                  fig_width = 8,
                                  fig_height = 6,
                                  fig_retina = if (!fig_caption) 2,
                                  fig_caption = FALSE,
                                  smart = TRUE,
                                  self_contained = TRUE,
                                  theme = "simple",
                                  custom_theme = NULL,
                                  custom_theme_dark = FALSE,
                                  custom_asset_path = NULL,
                                  transition = "default",
                                  custom_transition = NULL,
                                  background_transition = "default",
                                  custom_background_transition = NULL,
                                  reveal_options = NULL,
                                  reveal_plugins = NULL,
                                  reveal_version = "3.8.0",
                                  reveal_location = "default",
                                  resource_location = "default",
                                  controls = FALSE,
                                  highlight = "default",
                                  mathjax = "default",
                                  mathjax_scale = NULL,
                                  tex_extensions = NULL,
                                  tex_defs = NULL,
                                  template = "default",
                                  css = NULL,
                                  includes = NULL,
                                  md_extensions = NULL,
                                  keep_md = FALSE,
                                  lib_dir = NULL,
                                  pandoc_args = NULL,
                                  extra_dependencies = NULL,
                                  custom_plugins = NULL,
                                  no_postprocess = FALSE,
                                  ...) {

  # function to lookup reveal resource
  reveal_resources <- function() {
    if(identical(resource_location, "default")) {
      system.file("rmarkdown/templates/revealjs_presentation/resources",
                  package = "revealjg")
    } else {
      resource_location
    }
  }

  # base pandoc options for all reveal.js output
  args <- c()

  # template path and assets
  if (identical(template, "default")) {
    default_template <- file.path(reveal_resources(), "default.html")
    args <- c(args, "--template", pandoc_path_arg(default_template))
  } else {
    if(!file.exists(template)) {
      t <-  file.path(reveal_resources(), template)
      if (! file.exists(t)) {
        t <- file.path(reveal_resources(), 'templates', template)
      }
      if (file.exists(t)) template <- t
    }
    args <- c(args, "--template",
              pandoc_path_arg(template))
  }

  # incremental
  if (incremental)
    args <- c(args, "--incremental")

  # centering
  jsbool <- function(value) ifelse(value, "true", "false")
  args <- c(args, pandoc_variable_arg("center", jsbool(center)))

  # controls
  args <- c(args, pandoc_variable_arg("controls", jsbool(controls)))

  # width and height
  if (! is.null(width))
    args <- c(args, "--variable", paste0("revealjs-width=", width))
  if (! is.null(height))
    args <- c(args, "--variable", paste0("revealjs-height=", height))
  if (! is.null(margin))
    args <- c(args, "--variable", paste0("revealjs-margin=", margin))

  # slide level
  args <- c(args, "--slide-level", as.character(slide_level))

  # theme
  theme <- match.arg(theme, revealjs_themes())
  theme_dark <- FALSE
  if (identical(theme, "custom")) {
    if (is.null(custom_theme))
    {
      stop("Missing custom_theme in YAML header")
    } else {
      theme <- NULL
      theme_dark <- custom_theme_dark
    }
  } else {
    if (identical(theme, "default"))
      theme <- "simple"
    else if (identical(theme, "dark"))
      theme <- "black"
    if (theme %in% c("black", "blood", "moon", "night"))
      theme_dark <- TRUE
  }
  if (theme_dark) {
    args <- c(args, pandoc_variable_arg("theme-dark", 'true'))
  }
  if (is.null(theme)) {
    args <- c(args, pandoc_variable_arg('local-theme', custom_theme))
  } else {
    args <- c(args, pandoc_variable_arg("theme", theme))
  }


  # transition
  transition <- match.arg(transition, revealjs_transitions())
  if (identical(transition, "custom")) {
    if (is.null(custom_transition)) {
      stop("Missing custom_transition in YAML header")
    }
    else {
      transition <- custom_transition
    }
  }
  args <- c(args, pandoc_variable_arg("transition", transition))

  # background_transition
  background_transition <- match.arg(background_transition, revealjs_transitions())
  if (identical(background_transition, 'custom')) {
    if (is.null(custom_background_transition)) {
      stop("Missing custom_background_transition in YAML header")
    } else {
      background_transition <- custom_background_transition
    }
  }
  args <- c(args, pandoc_variable_arg("backgroundTransition", background_transition))

  # use history
  args <- c(args, pandoc_variable_arg("history", "true"))

  # use hash
  args <- c(args, pandoc_variable_arg("hash", "true"))

  # mathjax-scale
  if (! is.null(mathjax_scale)) {
    args <- c(args, pandoc_variable_arg("mathjax-scale", mathjax_scale))
  }

  # additional reveal options
  if (is.list(reveal_options)) {

    add_reveal_option <- function(option, value) {
      if (is.logical(value))
        value <- jsbool(value)
      else if (is.character(value))
        value <- paste0("'", value, "'")
      args <<- c(args, pandoc_variable_arg(option, value))
    }

    for (option in names(reveal_options)) {
      # special handling for nested options
      if (option %in% c("chalkboard", "menu")) {
        nested_options <- reveal_options[[option]]
        for (nested_option in names(nested_options)) {
          add_reveal_option(paste0(option, "-", nested_option),
                            nested_options[[nested_option]])
        }
      }
      # standard top-level options
      else {
        add_reveal_option(option, reveal_options[[option]])
      }
    }
  }

  # reveal plugins
  if (is.character(reveal_plugins)) {
    message("plugins = [", str_c(reveal_plugins, collapse = ", "), "]")
    # validate that we need to use self_contained for plugins
    if (self_contained)
      stop("Using reveal_plugins requires self_contained: false")

    # validate specified plugins are supported
    supported_plugins <- c("notes", "search", "zoom", "chalkboard", "menu")
    if (!is.null(custom_plugins)) {
      supported_plugins <- c(supported_plugins, custom_plugins)
    }
    invalid_plugins <- setdiff(reveal_plugins, supported_plugins)
    if (length(invalid_plugins) > 0)
      stop("The following plugin(s) are not supported: ",
           paste(invalid_plugins, collapse = ", "), call. = FALSE)

    # add plugins
    sapply(reveal_plugins, function(plugin) {
      args <<- c(args, pandoc_variable_arg(paste0("plugin-", plugin), "1"))
      # if (plugin %in% c("chalkboard", "menu")) {
      #   extra_dependencies <<- append(extra_dependencies,
      #                                 list(rmarkdown::html_dependency_font_awesome()))
      # }
    })
  }

  # TeX extensions for MathJax
  if (! is.null(tex_extensions)) {
    args <- c(args, sapply(tex_extensions, function(ext) {
      pandoc_variable_arg('tex-extensions', ext)
    }))
  }

  # TeX macro definitions for MathJax
  if (! is.null(tex_defs)) {
    args <- c(args, sapply(tex_defs, function(x) {
      pandoc_variable_arg('tex-defs',
                          gsub('\\','\\\\',
                               paste0(x$name, ': "', x$def, '"'),
                               fixed=TRUE))
    }))
  }

  # content includes
  args <- c(args, includes_to_pandoc_args(includes))

  # additional css
  for (css_file in css)
    args <- c(args, "--css", pandoc_path_arg(css_file))


  markdown_extensions <- tibble::tibble(
    extension = c("implicit_figures", "smart", "markdown_in_html_blocks"),
    value = c(fig_caption, smart, TRUE)
  )

  # message("Base extensions = [", str_c(markdown_extensions, collapse = ", "), "]")

  if(! is.null(md_extensions)) {
    user_md_extensions = str_extract_all(md_extensions, "([+-])([A-Za-z0-9_]+)") %>%
      simplify() %>% tibble(extension = .) %>%
      mutate(value = str_detect(extension, '^\\+'), extension = str_sub(extension, 2))

    # message("User extensions = [", str_c(md_extensions, collapse = ", "), "]")
    # message("Processed User extensions = [", str_c(user_md_extensions, collapse = ", "), "]")

    markdown_extensions <- markdown_extensions %>%
      filter(! extension %in% user_md_extensions$extension) %>%
      bind_rows(user_md_extensions)
  }

  markdown_extensions <- markdown_extensions %>%
    transmute(string = str_c(ifelse(value, "+", "-"), extension)) %>%
    simplify() %>% str_c(collapse = "")

  # message("Merged extensions = [", str_c(markdown_extensions, collapse = ", "), "]")

  # pre-processor for arguments that may depend on the name of the
  # the input file (e.g. ones that need to copy supporting files)
  pre_processor <- function(metadata, input_file, runtime, knit_meta, files_dir,
                            output_dir) {

    # we don't work with runtime shiny
    if (identical(runtime, "shiny")) {
      stop("revealjs_presentation is not compatible with runtime 'shiny'",
           call. = FALSE)
    }

    # use files_dir as lib_dir if not explicitly specified
    if (is.null(lib_dir))
      lib_dir <- files_dir

    # extra args
    args <- c()

    # reveal.js
    reveal_home <- paste0("reveal.js-", reveal_version)
    if (identical(reveal_location, "default")) {
      revealjs_path <- system.file(reveal_home, package = "revealjg")
      if (identical(revealjs_path, '')) {
        message('Empty revealjs_path')
        revealjs_path <- file.path(lib_dir, reveal_home)
      }
    } else {
      revealjs_path <- file.path(reveal_location, reveal_home)
    }
    if (identical(custom_asset_path, "default")) {
      custom_asset_path <-  revealjs_path
    }
    if (!self_contained || identical(.Platform$OS.type, "windows")) {
      message("revealjs_path = ", revealjs_path,
              ", custom_asset_path = ", custom_asset_path,
              "current directory = ", getwd(), ", output_dir = ",
              output_dir)
      revealjs_path <- relative_to(
        output_dir, render_supporting_files(revealjs_path, lib_dir))
      custom_asset_path <- relative_to(output_dir, custom_asset_path)
      message("revealjs_path = ", revealjs_path,
              ", custom_asset_path = ", custom_asset_path,
              "current directory = ", getwd(), ", output_dir = ",
              output_dir)
    }else  {
      revealjs_path <- pandoc_path_arg(revealjs_path)
      custom_asset_path <- pandoc_path_arg(custom_asset_path)
    }
    args <- c(args, pandoc_variable_arg("revealjs-url", revealjs_path))
    args <- c(args, pandoc_variable_arg("local-asset-url", custom_asset_path))

    # highlight
    args <- c(args, pandoc_highlight_args(highlight, default = "pygments"))

    # return additional args
    args
  }

  if (no_postprocess) {
    postprocessor = NULL
  } else {
    postprocessor = revealjg_postprocessor
  }

  # return format
  output_format(
    knitr = knitr_options_html(fig_width, fig_height, fig_retina, keep_md),
    pandoc = pandoc_options(to = "revealjs",
                            from = rmarkdown_format(markdown_extensions),
                            args = args),
    keep_md = keep_md,
    clean_supporting = self_contained,
    pre_processor = pre_processor,
    post_processor = postprocessor,
    base_format = html_document_base(smart = FALSE, lib_dir = lib_dir,
                                     self_contained = self_contained,
                                     mathjax = mathjax,
                                     pandoc_args = pandoc_args,
                                     extra_dependencies = extra_dependencies,
                                     ...))
}


revealjs_themes <- function() {
  c("default",
    "dark",
    "beige",
    "black",
    "blood",
    "league",
    "moon",
    "night",
    "serif",
    "simple",
    "sky",
    "solarized",
    "white",
    "custom")
}


revealjs_transitions <- function() {
  c(
    "default",
    "none",
    "fade",
    "slide",
    "convex",
    "concave",
    "zoom",
    "custom"
  )
}


