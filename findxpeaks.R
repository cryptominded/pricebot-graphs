function(x, w, bw="SJ") {
   densx<-density(x, weights=w/sum(w), bw=bw)
   peaksx<-diff(sign(diff(densx$y))) == -2
   densx$x[peaksx]
}