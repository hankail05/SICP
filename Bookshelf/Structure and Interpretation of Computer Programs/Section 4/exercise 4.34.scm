#lang sicp
(define (lookup-variable-value-lazy var env)
  (define (env-loop env)
    (define (scan vars vals)
      (cond ((null? vars) (env-loop (enclosing-environment env)))
            ((eq? var (car vars)) (car vals))
            (else (scan (cdr vars) (cdr vals)))))
    (if (eq? env the-empty-environment)
        '()
        (let ((frame (first-frame env)))
          (scan (frame-variables frame)
                (frame-values frame)))))
  (env-loop env))

(define (setup-environment)
  (let ((initial-env (extend-environment (primitive-procedure-names)
                                         (primitive-procedure-objects)
                                         the-empty-environment)))
    (evaln '(begin (define (cons first rest) (lambda (m) (m first rest)))
                   (define (car z) (z (lambda (p q) p)))
                   (define (cdr z) (z (lambda (p q) q))))
           initial-env)
    (define-variable! 'true true initial-env)
    (define-variable! 'false false initial-env)
    initial-env))


(define (lazy-cons? procedure)
  (let ((env (procedure-environment procedure)))
    (and (not (null? (lookup-variable-value-lazy 'first env)))
         (not (null? (lookup-variable-value-lazy 'rest env))))))
(define (lazy-cons-print object)
  (define (inner object n)
    (if (not (null? object))
        (let ((env (procedure-environment object)))
          (let ((first (lookup-variable-value-lazy 'first env))
                (rest (lookup-variable-value-lazy 'rest env)))
            (cond ((> n 8) (display "..."))
                  (else (let ((first-forced (force-it first)))
                          (if (and (compound-procedure? first-forced) (lazy-cons? first-forced))
                              (lazy-cons-print first-forced)
                              (display first-forced)))
                        (display " ")
                        (inner (force-it rest) (inc n))))))
        (display "end")))
  (inner object 0))


(define (user-print object)
  (if (compound-procedure? object)
      (if (lazy-cons? object)
          (lazy-cons-print object)
          (display (list 'compound-procedure
                         (procedure-parameters object)
                         (procedure-body object)
                         '<procedure-env>)))
      (display object)))