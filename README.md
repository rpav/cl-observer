# cl-observer

This is a very trivial observer system for CL.

```lisp
(defvar *thing* (gensym))    ;; Something unique

(observer:add *thing*
              (lambda (subject &key x y)
                (format t "Notified: ~S (~A, ~A)~%" subject x y)))

(observer:observed-p *thing*) ;; => T

(observer:add *thing*
              (lambda (subject &key &allow-other-keys)
                (format t "Another observer!")))

(observer:notify *thing* :x 1 :y 2)

;; ->
;; Notified: #:SYM (1, 2)
;; Another observer!

(observer:clear *thing*)
(observer:observed-p *thing*) ;; => NIL

(observer:notify *thing* 42) ;; Nothing
```

Notifications are sent in no guaranteed order.  Both the observer and the subject are *weakly* referenced: make sure to keep references to **both**,
or they will go away.

Note, this shadows `CL:REMOVE` and has symbols `ADD`, `CLEAR`, and
`UPDATED`, so you probably don't want to import it.


## Customizing

Notifications are sent via the `OBSERVER:UPDATED` generic function:

  `observer:updated (OBSERVER SUBJECT &rest ARGS)`

Called when `SUBJECT` is the subject of `NOTIFY`, with `ARGS`.
Specialize on `OBSERVER` and/or `SUBJECT`.  By default,this is
specialized on functions, which will be called with `ARGS`.
