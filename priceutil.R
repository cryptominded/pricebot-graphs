function() {
   list(
      avg.fromOHCL=     
         function(o, c, h, l) {
            (3*o + 5*c + h + l)/10  # bias towards close
         })
}