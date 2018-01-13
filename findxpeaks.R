function(x, w, bw) {
   densx<-density(x, weights=w/sum(w), bw="SJ")
   peaksx<-diff(sign(diff(densx$y))) == -2
   densx$x[peaksx]
}