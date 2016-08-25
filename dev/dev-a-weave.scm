; testing ...
(load "dev-a-tearup.scm")
(load "../a-pcd.scm")
(load "../a-advice.scm")
(load "../a-weave.scm")
(load "../a-advcomb.scm")


; AFTER...
; Test 1 - "after", no args, joinpoint = "b", advice is on "a" with "c" (i.e. no match - just run "a")
(display "Test 1:\n")
(define tval (tearup-e jp-b (e-weave (list (e-adv-after pcd01 "c" (e-applyBody "c"))) chi-a)))
(display "Result: ") (display (tval->val tval)) (newline)

; Test 2 - "after", no args, joinpoint = "a", advice is on "a" with "c"  (i.e. match - run "a" then "c")
(display "Test 2:\n")
(define tval (tearup-e jp-a (e-weave (list (e-adv-after pcd01 "c" (e-applyBody "c"))) chi-a)))
(display "Result: ") (display (tval->val tval)) (newline)

; Test 3 - "after", no args, joinpoint = "a", advice is on "a" with "c" and "d"  (i.e. match - run "a" then "c" then "d")
(display "Test 3:\n")
(define tval (tearup-e jp-a (e-weave (list (e-adv-after pcd01 "c" (e-applyBody "c")) (e-adv-after pcd01 "d" (e-applyBody "d"))) chi-a)))
(display "Result: ") (display (tval->val tval)) (newline)


; BEFORE...
; Test 4 - "before", no args, joinpoint = "b", advice is on "a" with "c" (i.e. no match - just run "a")
(display "Test 4:\n")
(define tval (tearup-e jp-b (e-weave (list (e-adv-before pcd01 "c" (e-applyBody "c"))) chi-a)))
(display "Result: ") (display (tval->val tval)) (newline)

; Test 5 - "before", no args, joinpoint = "a", advice is on "a" with "c"  (i.e. match - run "c" then "a")
(display "Test 5:\n")
(define tval (tearup-e jp-a (e-weave (list (e-adv-before pcd01 "c" (e-applyBody "c"))) chi-a)))
(display "Result: ") (display (tval->val tval)) (newline)

; Test 6 - "before", no args, joinpoint = "a", advice is on "a" with "c" and "d"  (i.e. match - run "d" then "c" then "a")
(display "Test 6:\n")
(define tval (tearup-e jp-a (e-weave (list (e-adv-before pcd01 "c" (e-applyBody "c")) (e-adv-before pcd01 "d" (e-applyBody "d"))) chi-a)))
(display "Result: ") (display (tval->val tval)) (newline)


; AROUND...
; Test 7 - "around", no args, joinpoint = "b", advice is on "a" with "c" (i.e. no match - just run "a")
(display "Test 7:\n")
(define tval (tearup-e jp-b (e-weave (list (e-adv-around pcd01 "c" (e-applyBody "c"))) chi-a)))
(display "Result: ") (display (tval->val tval)) (newline)

; Test 8 - "around", no args, joinpoint = "a", advice is on "a" with "c"  (i.e. match - just run "c")
(display "Test 8:\n")
(define tval (tearup-e jp-a (e-weave (list (e-adv-around pcd01 "c" (e-applyBody "c"))) chi-a)))
(display "Result: ") (display (tval->val tval)) (newline)

; Test 9 - "around", no args, joinpoint = "a", advice is on "a" with "c" and "d"  (i.e. match - just run "d")
(display "Test 9:\n")
(define tval (tearup-e jp-a (e-weave (list (e-adv-around pcd01 "c" (e-applyBody "c")) (e-adv-around pcd01 "d" (e-applyBody "d"))) chi-a)))
(display "Result: ") (display (tval->val tval)) (newline)


; MIXED...
; Test 10 - should give "d" then "c" (no "a" nor 2nd "c" nor 2nd "d")
(display "Test 10:\n")
(define tval (tearup-e jp-a (e-weave (list 
   (e-adv-before pcd01 "c" (e-applyBody "c")) (e-adv-around pcd01 "c" (e-applyBody "c")) (e-adv-before pcd02 "d" (e-applyBody "d")) (e-adv-before pcd01 "d" (e-applyBody "d"))
) chi-a)))
(display "Result: ") (display (tval->val tval)) (newline)





