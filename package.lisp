(defpackage #:observer
  (:use #:cl #:asdf #:tg)
  (:shadow cl:remove)
  (:export add remove notify clear observed-p updated))

