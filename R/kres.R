# S4 class for KRES model.
# 
# Author: Harlan
###############################################################################

setClass("kres",
    representation(nodeTree="list", nodes="character", cons="matrix",
        w="matrix", wChl="matrix", wExemp="matrix",
        minusAct="matrix", plusAct="matrix", 
        exempNodeIdx="numeric", exempActivated="numeric",
        exempChl="matrix", exempExemp="matrix",
        bias="matrix"))

setMethod("initialize", "kres", function(.Object, nodeTree, params) {
      # the strategy will be to build local copies of the various matrix
      # objects, then copy them all in at the end...
        
      # flatten nodeTree to nodes
      nodes <- unlist(nodeTree$nodes)
      nNodes <- length(nodes)
      
      # weight matrixes
      # row and column names, oh boy!
      w <- matrix(data=0, nrow=nNodes, ncol=nNodes, dimnames=list(nodes, nodes))
      wChl <- w 	# learnable weights
      wExemp <- w	# exemplar weights
      exempChl <- w	# learnable exemplar initial weight values, to be copied in later
      exempExemp <- w # fixed exemplar connections to input
      # cons matrix for logging
      cons <- w		# all possible connections
      
      # nested functions have to be defined before use. 
      
      # For a single connection, build representations
      buildCons <- function(con) {       
        # get the list of connected nodes
        to <- subtree(nodeTree, con["to"])
        from <- subtree(nodeTree, con["from"])
        
        print(sprintf('%s - %s', con["to"], con["from"]));
        
        # store exemplar nodes for later
        
        #browser()
        
        # now build the connections
        # full
        if (con["spread"] == "full") {
          outer(to, from, function(x, y) mapply(buildConsPair, x, y, list(con)));
        }
        else # one-to-one
        {
          mapply(buildConsPair, to, from, MoreArgs=list(con))
        }
      } # end buildCons
      
      # mapply requires MoreArgs to be a list, so con is always a list of 
      # length 1. Best to just convert back the vector here.
      buildConsPair <- function(a, b, con) {
        if (is.list(con))
          con <- con[[1]];

        if (a != b) {
          cons[a, b] <<- 1
          cons[b, a] <<- 1
          
          setWeights(a, b, con)
        }
        
        0 # to prevent outer() and mapply() from choking on NULL
      }
      
      setWeights <- function(a, b, con) {
        # first, figure out the weight value
        # switch() requires either integer indexes or strings, and we want
        #  strings here, so force character, but test later for number
        wval <- switch(as.character(con["init"]),
            inh = params$inWeight,
            exh = params$exWeight,
            rand = runif(1, -params$randWeight, params$randWeight),
            #otherwise:
            ifelse(is.numeric(con["init"]), con["init"], 0))
        
#        print(sprintf('wval = %f', wval))
        
        if (con["type"] == "exemp") {
          # actually, don't use wval for fixed exemplar nodes
          wval <- 0
          # instead, add this to exempExemp
          exempExemp[a,b] <<- 1
          exempExemp[b,a] <<- 1
        }
        
        if (con["type"] == "exempchl") {
          # for CHL connections to exemplar nodes, put wval into the
          # exempChl matrix, but then reset to 0, so it doesn't go into
          # the weight matrix yet.
          exempChl[a,b] <<- wval
          exempChl[b,a] <<- wval
          wval <- 0
        }
        
        # set the weights themselves
        w[a,b] <<- wval
        w[b,a] <<- wval
        
        if (con["type"] == "chl") {
          wChl[a,b] <<- 1
          wChl[b,a] <<- 1
        }
        
       
      }
      
      # back to the main body of kres::initialize()

      # activation matrixes
      
      # exemplar node stuff
      
      # construct weight matrix from the node tree
      lapply(nodeTree$cons, buildCons) # lots of side effects here
      
      # construct bias array
      bias <- matrix(data=0, nrow=nNodes, ncol=1, dimnames=list(nodes))
      
      # logging 

      
      .Object@w <- w
      .Object@wChl <- wChl
      .Object@wExemp <- wExemp
      .Object@exempChl <- exempChl
      .Object@exempExemp <- exempExemp
      .Object@nodeTree <- nodeTree  # train and test will need a copy
      .Object@nodes <- nodes
      .Object@bias <- bias
  
      .Object
    })

setGeneric("converge", function(.K, Xin, params) standardGeneric("converge"))

setMethod("converge", "kres", function(.K, Xin, params) {
      harmony <- 0
      dHarmony <- 1
      
      # net_input starts out as a vector of 0s
      net_input <- Xin * 0
      adj_input <- Xin * 0
      
      cycles <- 0
      
      # bleah, need accessors
      # do this out of the loop for speed, maybe
      gain <- params$gain
      alpha <- params$alpha
      bias <- .K@bias
      w <- .K@w
      
      
      # while harmony is high and we haven't done a ridiculous number of cycles
      while ((dHarmony > 0.00001) && (cycles < 1000000))
      { 
        # calculate total_input
        total_input <- net_input + Xin + t(bias)
      
        # do gain thing
        adj_input <- adj_input + (total_input - adj_input) / gain; 
      
        # calculate activation
        act <- 1 / (1 + exp(-alpha * adj_input))
        
        # calculate net_input
#        browser()
        net_input <- act %*% w
        
        # calculate harmony
        newHarmony <- sum(act * net_input);
        dHarmony <- abs(harmony - newHarmony);
        harmony <- newHarmony;
        
        cycles <- cycles + 1;
      }
          
      # return a list with the post-convergence activation and the convergence time in 
      # steps
      return(list(act=act, cycles=cycles))
    })


setGeneric("test", function(.K, Xin, Xout, params) standardGeneric("test"))

setMethod("test", "kres", function(.K, Xin, Xout, params) {
      # OK! Here's how this will work. First, converge with just Xin as input,
      # and save the activations. 
          
      convRet <- converge(.K, Xin, params)
      
      # Now, figure out the ensemble's prediction and error. 
          
      # Use the node tree in K to get the output nodes. Use those to figure out
      # which elements of K.minusAct belong in the output vector.
      # Then, do LCR on that to get.
      
#          outList = tree2leaves(subtree(K.nodeTree, 'O'));
#      outAct = zeros(size(outList));
#      for i = 1:length(outAct),
#      outAct(i) = K.minusAct(getNodeIdx(K, outList(i)));
#      end
#      
#      K.log.Outputs = outAct ./ sum(outAct);
#      out = K.log.Outputs;
#      
#      # and for logging...
#          K.log.Input = Xin + Xout;
      
      
      
    })


#SUBTREE Get the subtree of T rooted at head.
subtree <- function(T, head)
{
  if (is.null(names(T))) {
    # it's a list of leaves, so return a leaf or null
    if (head %in% T) { ret <- head } else { ret <- NULL }
  }
  else if (head %in% names(T)) {
    # it's at this level, so return it
    ret <- T[head]
  }
  else {
    # it's not here, so recurse
    ret <- unlist(lapply(T, function(x) subtree(x, head)))
           # unlist gets rid of the null calls!
  }
  ret
}