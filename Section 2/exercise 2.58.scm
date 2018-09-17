#lang sicp
(define (=number? vari cons) (and (number? vari) (= vari cons)))
(define (variable? x) (symbol? x))
(define (same-variable? x1 x2) (and (variable? x1) (variable? x2) (eq? x1 x2)))
(define (make-sum a1 a2)
  (cond ((=number? a1 0) a2)
        ((=number? a2 0) a1)
        ((and (number? a1) (number? a2)) (+ a1 a2))
        (else (list a1 '+ a2))))
(define (make-product m1 m2)
  (cond ((or (=number? m1 0) (=number? m2 0)) 0)
        ((=number? m1 1) m2)
        ((=number? m2 1) m1)
        ((and (number? m1) (number? m2)) (* m1 m2))
        (else (list m1 '* m2))))
(define (sum? x) (and (pair? x) (eq? (cadr x) '+)))
(define (addend s) (car s))
(define (augend s)
  (cond ((null? (cdddr s)) (caddr s))
        (else (next s))))
(define (product? x) (and (pair? x) (eq? (cadr x) '*)))
(define (multiplier p) (car p))
(define (multiplicand p)
  (cond ((null? (cdddr p)) (caddr p))
        (else (next p))))

(define (next exp)
  (if (sum? (cddr exp))
      (make-sum (caddr exp) (cadddr (cdr exp)))
      (make-product (caddr exp) (cadddr (cdr exp)))))

(define (deriv exp var)
  (cond ((number? exp) 0)
        ((variable? exp)
         (if (same-variable? exp var) 1 0))
        ((sum? exp)
         (make-sum (deriv (addend exp) var)
                   (deriv (augend exp) var)))
        ((product? exp)
         (make-sum
          (make-product (multiplier exp)
                        (deriv (multiplicand exp) var))
          (make-product (deriv (multiplier exp) var)
                        (multiplicand exp))))
        (else
         (error "unknown expression type -- DERIV" exp))))

(deriv '(x + (3 * (x + y + 2))) 'x)