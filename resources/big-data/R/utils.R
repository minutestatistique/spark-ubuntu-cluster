#' Package loading / installing
#'
#' Checks if a package is installed, in which case, loads it or else, installs it then loads it.
#'
#' @param p package
#' 
#' @return None
#'
#' @examples
#' MyRequire(data.table)
#'
#' @export
MyRequire <- function(p) {
  p_name <- as.character(substitute(p))
  suppressWarnings(
    if (!require(p_name, character.only = TRUE)) {
      install.packages(p_name)
    }
  )
  require(p_name, character.only = TRUE)
}
