
context("Themes")

test_theme <- function(theme) {
  if(identical(theme, "custom"))
    return(NULL)
  test_that(paste(theme, "theme"), {
    # don't run on cran because pandoc is required
    skip_on_cran()

    # work in a temp directory
    dir <- tempfile()
    dir.create(dir)
    oldwd <- setwd(dir)
    on.exit(setwd(oldwd), add = TRUE)

    # create a draft of a presentation
    testdoc <- "testdoc.Rmd"
    rmarkdown::draft(testdoc,
                     system.file("rmarkdown", "templates", "revealjs_presentation",
                                 package = "revealjg"),
                     create_dir = FALSE,
                     edit = FALSE)

    # render it with the specified theme
    capture.output({
      output_file <- tempfile(fileext = ".html")
      output_format <- revealjs_presentation(theme = theme)
      rmarkdown::render(testdoc, 
                        output_format = output_format,
                        output_file = output_file)
      expect_true(file.exists(output_file))
    })
  })
}

# test all themes
sapply(revealjg:::revealjs_themes(), test_theme)
