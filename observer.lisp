(in-package :observer)

 ;; Internal

(defvar *observed-objects*
  (tg:make-weak-hash-table :weakness :key :weakness-matters t))

(defun compare-weak-pointers (a b)
  (eq (tg:weak-pointer-value a)
      (tg:weak-pointer-value b)))

 ;; Methods

(defgeneric updated (observer subject &rest args)
  (:documentation "Called when `SUBJECT` is the subject of `NOTIFY`,
with `ARGS`.  Specialize on `OBSERVER` and/or `SUBJECT`.  By default,
this is specialized on functions, which will be called with `ARGS`.")
  (:method ((observer function) subject &rest args)
    (apply observer subject args)))


 ;; API

(defun add (thing observer)
  "Add `OBSERVER` as an observer of `THING`.  `OBSERVER` will be notified
via `NOTIFY` when the subject is `THING`."
  (pushnew (tg:make-weak-pointer observer)
           (gethash thing *observed-objects*)
           :test #'compare-weak-pointers)
  observer)

(defun remove (thing observer)
  "Remove `OBSERVER` from the notification list for `THING`.  It will
no longer be notified."
  (setf (gethash thing *observed-objects*)
        (cl:remove (tg:make-weak-pointer observer)
                   (gethash thing *observed-objects*)
                   :test #'compare-weak-pointers)))

;;; XXX - FIXME? - hash tables with :weakness :key seem to perform
;;; relatively poorly
(defun notify (thing &rest args)
  "Send notifications with the subject of `THING`, with arguments."
  (let (dirty)
    (dolist (wp (gethash thing *observed-objects*))
      (let ((object (tg:weak-pointer-value wp)))
        (if object
            (apply #'updated object thing args)
            (setf dirty t))))
    (when dirty
      (clean-observer-list thing))))

(defun clear (thing)
  "Remove `THING` as a subject that is being observed; all observers are
*silently* dropped."
  (remhash thing *observed-objects*))

(defun clean-observer-list (thing)
  (setf (gethash thing *observed-objects*)
        (remove-if-not (lambda (wp) (tg:weak-pointer-value wp))
                       (gethash thing *observed-objects*))))

(defun observed-p (thing)
  "Return `T` if `THING` is observed, or `NIL`."
  (clean-observer-list thing)
  (if (car (gethash thing *observed-objects*)) t nil))
