function(x, w, n) {
   bw<-log(length(x))
   repeat {
      densx<-density(x, weights=w/sum(w), bw=bw)
      peaksx<-diff(sign(diff(densx$y))) == -2
      npeaks<-sum(peaksx)
      if (npeaks > (n+1)) {
         bw<-bw*1.25
      } else if (npeaks < (n-1)) { 
         bw<-bw/2
      } else {
         break;
      }
   }
   densx$x[peaksx]
}