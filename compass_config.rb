http_path       = "/"
sass_dir        = "src/scss"
css_dir         = "htdocs/css"
images_dir      = "htdocs/img"
javascripts_dir = "htdocs/js"
output_style    = (environment == :production) ? :compressed : :nested
line_comments   = (environment == :production) ? false : true
