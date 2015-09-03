(defsystem :cl-observer
  :description "A simple observer system"
  :version "1.0"
  :author "Ryan Pavlik <rpavlik@gmail.com>"
  :license "MIT"

  :depends-on (:trivial-garbage)

  :serial t
  :components ((:file "package")
               (:file "observer")))
