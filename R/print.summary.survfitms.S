print.summary.survfitms <- function(x, 
				  digits = max(options()$digits - 4, 3), ...) {
    savedig <- options(digits=digits)
    on.exit(options(savedig))

    if (!is.null(cl<- x$call)) {
	cat("Call: ")
	dput(cl)
	cat("\n")
	}
    tsum <- function(x) {
        if (is.matrix(x)) rowSums(x) else x
    }
    omit <- x$na.action
    if (length(omit)) 
	    cat(naprint(omit), "\n")
    if (x$type == 'mright' || is.null(x$n.enter)) {
	mat <- cbind(x$time, tsum(x$n.risk), tsum(x$n.event), x$prev)
	cnames <- c("time", "n.risk", "n.event")
        }

    else if (x$type == 'mcounting') {
	mat <- cbind(x$time, tsum(x$n.risk), tsum(x$n.event), x$prev,)
	cnames <- c("time", "n.risk", "n.event")
        }

    if (is.matrix(x$prev)) ncurve <- ncol(x$prev)
    else	           ncurve <- 1
    if (ncurve==1) {                 #only 1 curve
	cnames <- c(cnames, "P")
	if (!is.null(x$std.err)) {
	    if (is.null(x$lower)) {
		mat <- cbind(mat, x$std.err)
		cnames <- c(cnames, "std.err")
	        }
	    else {
		mat <- cbind(mat, x$std.err, x$lower, x$upper)
		cnames <- c(cnames, 'std.err',
			    paste("lower ", x$conf.int*100, "% CI", sep=''),
			    paste("upper ", x$conf.int*100, "% CI", sep=''))
	        }	
	    }
        }
    else cnames <- c(cnames, paste0("P(", x$states[1:ncurve], ")"))

    if (!is.null(x$start.time)) {
	mat.keep <- mat[,1] >= x$start.time
	mat <- mat[mat.keep,,drop=FALSE]
	if (is.null(dim(mat)))
		stop(paste("No information available using start.time =", x$start.time, "."))
        }
    if (!is.matrix(mat)) mat <- matrix(mat, nrow=1)
    if (!is.null(mat)) {
	dimnames(mat) <- list(rep("", nrow(mat)), cnames)
	if (is.null(x$strata)) print(mat)
	else  { #print it out one strata at a time
	    strata <- x$strata
	    if (!is.null(x$start.time))
		    strata <- strata[mat.keep]
	    for (i in levels(strata)) {
		who <- (strata==i)
		cat("               ", i, "\n")
		print(mat[who,])
		cat("\n")
 	        }
	    }
        }
    else 
	stop("There are no events to print.  Please use the option ",
	    "censored=TRUE with the summary function to see the censored ",
	    "observations.")
    invisible(x)
    }
