#lang sicp
(define (prime? n)
  (define (smallest-divisor n)
    (define (square x) (* x x))
    (define (find-divisor n test-divisor)
      (cond ((> (square test-divisor) n) n)
            ((divides? test-divisor n) test-divisor)
            (else (find-divisor n (+ test-divisor 1)))))
    (define (divides? a b)
      (= (remainder b a) 0))
    (find-divisor n 2))
  (= n (smallest-divisor n)))

(define (fast-prime? n times)
  (define (square x) (* x x))
  (define (miller-rabin-test n)
    (define (nontrivial root)
      (cond ((and (not (or (= root 1) (= root (- n 1)))) (= (remainder (square root) n) 1)) 0)
            (else (square root))))
    (define (expmod base exp m)
      (cond ((= exp 0) 1)
            ((even? exp)
             (remainder (nontrivial (expmod base (/ exp 2) m))
                        m))
            (else
             (remainder (* base (expmod base (- exp 1) m))
                        m))))
    (define (try-it a)
      (= (expmod a (- n 1) n) 1))
    (try-it (+ 1 (random (- n 1)))))
  (cond ((= times 0) true)
        ((miller-rabin-test n) (fast-prime? n (- times 1)))
        (else false)))

(define (carmichael-test n)
  (cond ((and (prime? n) (fast-prime? n 100)) (display "prime"))
        ((and (not (prime? n)) (not (fast-prime? n 100))) (display "composite"))
        (else (display "fooled"))))

(carmichael-test 561)
(newline)
(carmichael-test 1105)
(newline)
(carmichael-test 1729)
(newline)
(carmichael-test 2465)
(newline)
(carmichael-test 2821)
(newline)
(carmichael-test 6601)