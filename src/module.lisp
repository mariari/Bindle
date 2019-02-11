(defpackage #:module
  (:documentation
   "provides the defmodule macro that gives module functors along with
anonymous modules, module signatures, and other life improvements to CL
package system")
  (:use #:cl #:error-type)
  (:export #:defmodule))

(in-package module)

;;;; Types--------------------------------------------------------------------------------
(defstruct sig-contents
  "a container that holds declarations of the fields below... going to be under
utilized until type checking occurs. Others present the user with a way of saying
just export these symbols"
  (vals    '() :type list)
  (funs    '() :type list)
  (macros  '() :type list)
  (includes '() :type list)
  (others   '() :type list))

;;;; Main function------------------------------------------------------------------------
(defmacro defmodule (&body terms)
  `(,@terms))

;;;; Helper Functions---------------------------------------------------------------------

(declaim (ftype (function (symbol symbol) string) update-inner-module-name))
(defun update-inner-module-name (outer-module inner-module)
  (concatenate 'string
               (symbol-name outer-module)
               "."
               (symbol-name inner-module)))


(declaim (ftype (function (list) either-error) parse-sig))
(defun parse-sig (xs)
  "parses the signature of a module functor, and returns either an error
or an okay with the sig-contents"
  (let ((sig-conts (make-sig-contents)))
    (mapc (lambda (x)
            ;; we symbol-name it, as we get namespace issues if not
            ;; ie if we try to call this outside, it'll see macro as
            ;; common-lisp::module, which breaks the case macro
            (if (not (listp x))
                (push x (sig-contents-others sig-conts))
                (macrolet ((push-val (f)
                             `(push (cadr x) (,f sig-conts))))
                  (let ((sym (symbol-name (car x))))
                    (cond
                      ((equal sym "VAL")     (push-val sig-contents-vals))
                      ((equal sym "FUN")     (push-val sig-contents-funs))
                      ((equal sym "MACRO")   (push-val sig-contents-macros))
                      ((equal sym "INCLUDE") (push-val sig-contents-includes))
                      (t (return-from parse-sig
                           (list :error
                                 (concatenate 'string
                                              "the module signature includes a "
                                              sym
                                              " please change it to val, macro, fun or include")))))))))
          xs)
    (list :ok sig-conts)))
