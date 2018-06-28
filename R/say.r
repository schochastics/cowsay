#' Sling messages and warnings with flair
#'
#' @export
#'
#' @param what (character) What do you want to say? See details.
#' @param by (character) Type of thing, one of cow, chicken, poop, cat, facecat,
#' bigcat, longcat, shortcat, behindcat, longtailcat, anxiouscat, grumpycat,
#' smallcat, ant, pumpkin, ghost, spider, rabbit, pig, snowman, frog, hypnotoad,
#' signbunny, stretchycat, fish, trilobite, shark, buffalo, clippy, mushroom, 
#' monkey, egret, or rms for Richard Stallman.
#' Alternatively, use "random" to have your message spoken by a random 
#' character.
#' We use \code{\link{match.arg}} internally, so you can use unique parts of
#' words that don't conflict with others, like "g" for "ghost" because there's 
#' no other animal that starts with "g".
#' @param type (character) One of message (default), warning, or string 
#' (returns string)
#' @param color (character) If \code{type} is "message", a 
#' \href{https://github.com/r-lib/crayon}{\code{crayon}}-suported text color.
#' @param length (integer) Length of longcat. Ignored if other animals used.
#' @param fortune An integer specifying the row number of fortunes.data. 
#' Alternatively which can be a character and grep is used to try to find a 
#' suitable row.
#' @param ... Further args passed on to \code{\link[fortunes]{fortune}}
#'
#' @details You can put in any phrase you like, OR you can type in one of a few
#' special phrases that do particular things. They are:
#'
#' \itemize{
#'  \item catfact A random cat fact from https://catfact.ninja
#'  \item fortune A random quote from an R coder, from fortunes library
#'  \item time Print the current time
#'  \item rms Prints a random 'fact' about Richard Stallman from the 
#'  \code{\link[rmsfact]{rmsfact}}
#'  package. Best paired with \code{by = "rms"}.
#' }
#'
#' Note that if you choose \code{by='hypnotoad'} the quote is forced to be, 
#' as you could imagine, 'All Glory to the HYPNO TOAD!'. For reference see
#' http://knowyourmeme.com/memes/hypnotoad
#'
#' Signbunny: It's not for sure known who invented signbunny, but this article
#' http://www.vox.com/2014/9/18/6331753/sign-bunny-meme-explained thinks
#' they found the first use in this tweet:
#' https://twitter.com/wei_bluebear/status/329101645780770817
#'
#' Trilobite: from http://www.retrojunkie.com/asciiart/animals/dinos.htm (site 
#' down though)
#'
#' Note to Windows users: there are some animals (shortcat, longcat, fish, 
#' signbunny, stretchycat, anxiouscat, longtailcat, grumpycat, mushroom) that 
#' are not available because they use non-ASCII characters that don't display 
#' properly in R on Windows.
#'
#' @examples
#' say()
#' say("what")
#' say("meow", "cat", color = "blue")
#' say('time')
#' say('time', "poop", color = "bold")
#' say("who you callin chicken", "chicken")
#' say("ain't that some shit", "poop")
#' say("icanhazpdf?", "cat")
#' say("boo!", "pumpkin")
#' say("hot diggity", "frog")
#' say("fortune", "spider")
#' say("fortune", "facecat")
#' say("fortune", "behindcat")
#' say("fortune", "smallcat")
#' say("fortune", "monkey")
#' say("fortune", "egret")
#' say("rms", "rms")
#'
#' # Vary type of output, default calls message()
#' say("hell no!")
#' say("hell no!", type="warning")
#' say("hell no!", type="string")
#'
#' # Using fortunes
#' say(what="fortune")
#' ## you don't have to pass anything to the `what` parameter if `fortune` is 
#' ## not null
#' say(fortune=10)
#' say(fortune=100)
#' say(fortune='whatever')
#' say(fortune=7)
#' say(fortune=45)
#'
#' # Using catfacts
#' # say("catfact", "cat")
#'
#' # The hypnotoad
#' say(by="hypnotoad")
#'
#' # Trilobite
#' say(by='trilobite')
#'
#' # Shark
#' say('Q: What do you call a solitary shark\nA: A lone shark', by='shark')
#'
#' # Buffalo
#' say('Q: What do you call a single buffalo?\nA: A buffalonely', by='buffalo')
#'
#' # Clippy
#' say(fortune=59, by="clippy")

say <- function(what="Hello world!", by="cat", 
                type="message", 
                what_color=NULL, by_color=NULL,  
                length=18, fortune=NULL, ...) {

  if (length(what) > 1) {
    stop("what has to be of length 1", call. = FALSE)
  }

  if (what == "catfact") {
    check4jsonlite()
    what <- 
      jsonlite::fromJSON(
        'https://catfact.ninja/fact')$fact
    by <- 'cat'
  }

  who <- get_who(by, length = length)

  if (!is.null(fortune)) what <- "fortune"

  if (what == "time")
    what <- as.character(Sys.time())
  if (what == "fortune") {
    if ( is.null(fortune) ) fortune <- sample(1:360, 1)
    what <- fortune(which = fortune, ...)
    what <- what[!is.na(what)] # remove missing pieces (e.g. "context")
    what <- gsub("<x>", "\n", paste(as.character(what), collapse = "\n "))
  }

  if (by == "hypnotoad") {
    what <- "All Glory to the HYPNO TOAD!"
  }
  
  if (what == "rms") {
    what <- rmsfact::rmsfact()
  }  
  
  if ( what %in% c("arresteddevelopment", "doctorwho", "dexter", "futurama", "holygrail", "simpsons", "starwars", "loremipsum")) {
    check4jsonlite()
    what <- 
      jsonlite::fromJSON(
        paste0('http://api.chrisvalleskey.com/fillerama/get.php?count=1&format=json&show=', what))$db$quote
  }
  
  if (!is.null(what_color)) {
    what_color <- crayon::make_style(what_color)
  } else {
    what_color <- function(x) x
  }
  
  if (!is.null(by_color)) {
    by_color <- crayon::make_style(by_color)
  } else {
    by_color <- function(x) x
  }
  
  what_pos_start <- 
    regexpr('%s', animals[["cat"]])[1] 
    
  what_pos_end <- what_pos_start + 2
  
  str <- paste0(by_color(substr(who, 1, what_pos_start)),
                what_color(what),
                by_color(substr(who, what_pos_end, nchar(who))))
  
  switch(type,
         message = message(str),
         warning = warning(str),
         string = sprintf(str))
}
