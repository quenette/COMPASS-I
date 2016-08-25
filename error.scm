; Misc error routines
; 
; Developed for guile scheme v 1.8.7
;
; TODO...
;  * Better than exiting would be to throw an exception
;  * Treat the 3rd arg as a variable argument list


(define error
   (lambda (f msg var)
      (display "In ")
      (display f)
      (display ": ")
      (display msg)
      (display ": ") ;hack
      (display var)  ;hack
      (display "\n")
      (exit)
))

