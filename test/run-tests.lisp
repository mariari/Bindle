(in-package :bindle-test)

(defun run-tests ()
  (run! 'aliasing-test)
  (run! 'module-test)
  (run! 'expanders-test)
  (run! 'set-test)
  (run! 'diff-list-test))
